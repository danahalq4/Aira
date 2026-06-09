//
//  TrendsViewModel.swift
//  Aira
//

import Foundation
import SwiftUI
import Combine


final class TrendsViewModel: ObservableObject {


    @Published private(set)
    var topTriggers: [TopTrigger] = []



    @Published private(set)
    var weeklyData: [DailyAsthmaScore] = [

        DailyAsthmaScore(day: "MON", score: 0),
        DailyAsthmaScore(day: "TUE", score: 0),
        DailyAsthmaScore(day: "WED", score: 0),
        DailyAsthmaScore(day: "THU", score: 0),
        DailyAsthmaScore(day: "FRI", score: 0),
        DailyAsthmaScore(day: "SAT", score: 0),
        DailyAsthmaScore(day: "SUN", score: 0)
    ]



    private var cancellables =
    Set<AnyCancellable>()





    init() {


        observeTriggers()


        loadWeeklyScores()
    }






    private func observeTriggers() {


        TrendsStore.shared
            .$triggers

            .map { triggers in


                triggers

                    .filter {
                        $0.deduction > 0
                    }

                    .sorted {
                        $0.deduction >
                        $1.deduction
                    }

                    .prefix(3)

                    .map { trigger in


                        TopTrigger(

                            icon:
                                trigger.icon,

                            title:
                                trigger.name,

                            subtitle:
                                trigger.displayValue,

                            percentage:
                                min(
                                    1,
                                    Double(trigger.deduction) / 25
                                ),

                            level:
                                trigger.level
                        )
                    }
            }

            .assign(
                to: &$topTriggers
            )
    }








    private func loadWeeklyScores() {


        TrendsStore.shared
            .$weeklyScores


            .map { saved in


                let days = [
                    "MON",
                    "TUE",
                    "WED",
                    "THU",
                    "FRI",
                    "SAT",
                    "SUN"
                ]


                return days.map { day in


                    saved.first {

                        $0.day == day

                    } ??

                    DailyAsthmaScore(
                        day: day,
                        score: 0
                    )
                }
            }


            .assign(
                to: &$weeklyData
            )
    }
}
