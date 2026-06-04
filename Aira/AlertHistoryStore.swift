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




        print(
            "📥 TRY SAVE ALERT:",
            result.score
        )






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


            .map {

                $0.name
            }


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










        // Prevent duplicate alerts today

        if oldTriggers == newTriggers {


            print(
                "⚠️ SAME ALERT - NOT SAVED AGAIN"
            )


            return
        }









        let alert =
        AsthmaAlertLog(


            date:
                Date(),



            score:
                result.score,



            label:
                alertLabel(
                    score:
                        result.score
                ),



            triggers:
                result.triggers

                    .filter {


                        $0.deduction > 0
                    }
        )










        // Save in history

        alerts.insert(

            alert,

            at: 0
        )










        // MARK: - Notification


        if alert.score < 25 {


            NotificationService.shared
                .sendAlert(

                    title:
                        "🚨 Critical Asthma Alert",


                    message:
                        "Multiple asthma triggers are elevated. Take precautions and check your recommendations."
                )



        } else {



            NotificationService.shared
                .sendAlert(

                    title:
                        "⚠️ High Asthma Risk",


                    message:
                        "Your asthma risk is high today. Check your triggers and recommendations."
                )
        }










        print(
            "🚨 ALERT SAVED"
        )



        print(
            "TYPE:",
            alert.label
        )



        print(
            "SCORE:",
            alert.score
        )



        print(
            "TRIGGERS:",
            alert.triggers.map {
                $0.name
            }
        )
    }











    private func alertLabel(
        score: Double
    ) -> String {


        if score < 25 {


            return "Critical Risk"



        } else {


            return "High Risk"
        }
    }
}
