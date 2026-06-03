//
//  TrendsViewModel.swift
//  Aira
//

import Foundation
import SwiftUI
import Combine


final class TrendsViewModel: ObservableObject {


    // MARK: - Published


    @Published private(set)
    var topTriggers: [TopTrigger] = []


    @Published private(set)
    var weeklyData: [DailyAsthmaScore] = []



    private var cancellables =
    Set<AnyCancellable>()





    // MARK: - Init


    init() {


        observeTriggers()


        loadWeeklyScores()
    }








    // MARK: - Weekly Top Triggers


    private func observeTriggers() {



        TrendsStore.shared
            .$triggers



            .map { triggers in



                triggers



                    // بس اللي نقصت السكور

                    .filter {

                        $0.deduction > 0
                    }



                    // الأعلى تأثير خلال الأسبوع

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









    // MARK: - Weekly Score


    private func loadWeeklyScores() {



        TrendsStore.shared
            .$weeklyScores


            .assign(
                to: &$weeklyData
            )
    }
}
