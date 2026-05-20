//
//  WatchConnectivityManager .swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 21/05/2026.
//
import Foundation
import WatchConnectivity
import SwiftData

final class WatchConnectivityManager: NSObject {

    static let shared = WatchConnectivityManager()

    var modelContext: ModelContext?

    private override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

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
                print("SEND MESSAGE FAILED:", error)
            }
            print("WATCH SENT MESSAGE:", data)
        } else {
            print("PHONE NOT REACHABLE, SAVED TO QUEUE")
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
            print("WC activation error:", error)
        } else {
            print("WC ACTIVATED:", activationState.rawValue)
        }
    }

    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String : Any]
    ) {
        saveReceivedSymptom(userInfo)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any]
    ) {
        saveReceivedSymptom(message)
    }

    private func saveReceivedSymptom(_ data: [String: Any]) {
        guard data["type"] as? String == "symptomLog",
              let symptom = data["symptom"] as? String,
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
            print("FAILED TO SAVE:", error)
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
