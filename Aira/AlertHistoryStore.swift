//
//  AlertHistoryStore.swift
//  Aira
//

import Foundation
import Combine


struct AsthmaAlertLog: Identifiable {


    let id = UUID()

    let date: Date

    let score: Double

    let label: String

    let triggers: [RiskTrigger]
}





final class AlertHistoryStore: ObservableObject {


    static let shared =
    AlertHistoryStore()



    @Published private(set)
    var alerts: [AsthmaAlertLog] = []



    private init() {}






    func saveIfNeeded(
        result: RiskResult
    ) {


        // Only High + Critical

        guard result.score < 40 else {

            return
        }






        let todayAlert =
        alerts.first {


            Calendar.current
                .isDate(
                    $0.date,
                    inSameDayAs: Date()
                )
        }





        let oldTriggers =
        todayAlert?
            .triggers
            .map { $0.name }
            .sorted()



        let newTriggers =
        result.triggers
            .filter {

                $0.deduction > 0
            }
            .map {

                $0.name
            }
            .sorted()






        // prevent duplicate

        if oldTriggers == newTriggers {

            return
        }






        let alert =
        AsthmaAlertLog(

            date:
                Date(),


            score:
                result.score,


            label:
                result.score < 25
                ? "Critical Risk"
                : "High Risk",


            triggers:
                result.triggers
                    .filter {

                        $0.deduction > 0
                    }
        )






        alerts.insert(
            alert,
            at: 0
        )
    }
}
