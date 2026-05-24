//import Foundation
import WatchConnectivity
import SwiftData

final class WatchConnectivityManager: NSObject {

    static let shared = WatchConnectivityManager()

    var modelContext: ModelContext?

    var onScoreReceived: ((Double, String, [RiskTrigger]) -> Void)?

    private override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Watch ➔ iPhone

    func sendSymptomToPhone(symptom: String, severity: String) {
        let data: [String: Any] = [
            "type": "symptomLog",
            "symptom": symptom,
            "severity": severity,
            "date": Date()
        ]

        WCSession.default.transferUserInfo(data)
        print("WATCH QUEUED USER INFO:", data)

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(data, replyHandler: nil) { error in
                print("SEND MESSAGE FAILED:", error.localizedDescription)
            }
            print("WATCH SENT MESSAGE:", data)
        } else {
            print("PHONE NOT REACHABLE, SAVED TO QUEUE")
        }
    }

    // MARK: - iPhone ➔ Watch

    func sendScoreToWatch(result: RiskResult) {
        let triggerDicts = result.triggers.map { trigger in
            [
                "name": trigger.name,
                "icon": trigger.icon,
                "level": trigger.level.rawValue,
                "displayValue": trigger.displayValue,
                "deduction": trigger.deduction,
                "reasonText": trigger.reasonText
            ] as [String: Any]
        }

        let scoreData: [String: Any] = [
            "type": "riskScoreUpdate",
            "score": result.score,
            "label": result.label,
            "triggers": triggerDicts
        ]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(scoreData, replyHandler: nil) { error in
                print("SEND SCORE TO WATCH FAILED:", error.localizedDescription)
            }
        }

        do {
            try WCSession.default.updateApplicationContext(scoreData)
            print("IPHONE SENT SCORE PACKAGE:", scoreData)
        } catch {
            print("IPHONE FAILED TO UPDATE CONTEXT:", error.localizedDescription)
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("WC activation error:", error.localizedDescription)
        } else {
            print("WC ACTIVATED:", activationState.rawValue)
        }

        let context = session.receivedApplicationContext
        if !context.isEmpty {
            routeIncomingData(context)
        } else {
            print("Application context data is nil")
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        routeIncomingData(userInfo)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        routeIncomingData(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        routeIncomingData(applicationContext)
    }

    private func routeIncomingData(_ data: [String: Any]) {
        guard let type = data["type"] as? String else { return }

        switch type {
        case "symptomLog":
            saveReceivedSymptom(data)

        case "riskScoreUpdate":
            handleReceivedScore(data)

        default:
            break
        }
    }

    private func saveReceivedSymptom(_ data: [String: Any]) {
        guard let symptom = data["symptom"] as? String,
              let severity = data["severity"] as? String,
              let date = data["date"] as? Date else {
            print("RECEIVED BUT DATA INVALID:", data)
            return
        }

        guard let modelContext else {
            print("IPHONE RECEIVED BUT MODELCONTEXT IS NIL")
            return
        }

        let newLog = SymptomLog(
            date: date,
            name: symptom,
            severityRaw: severity
        )

        modelContext.insert(newLog)

        do {
            try modelContext.save()
            print("IPHONE SAVED WATCH SYMPTOM:", symptom, severity)
        } catch {
            print("FAILED TO SAVE:", error.localizedDescription)
        }
    }

    private func handleReceivedScore(_ data: [String: Any]) {
        guard let score = data["score"] as? Double,
              let label = data["label"] as? String,
              let triggerDicts = data["triggers"] as? [[String: Any]] else {
            print("SCORE DATA INVALID:", data)
            return
        }

        let triggers: [RiskTrigger] = triggerDicts.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let icon = dict["icon"] as? String,
                  let levelRaw = dict["level"] as? String,
                  let displayValue = dict["displayValue"] as? String,
                  let deduction = dict["deduction"] as? Int,
                  let reasonText = dict["reasonText"] as? String,
                  let level = TriggerLevel(rawValue: levelRaw) else {
                return nil
            }

            return RiskTrigger(
                name: name,
                icon: icon,
                level: level,
                displayValue: displayValue,
                deduction: deduction,
                reasonText: reasonText
            )
        }

        print("WATCH RECEIVED SCORE:", score, label)

        DispatchQueue.main.async {
            self.onScoreReceived?(score, label, triggers)
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
