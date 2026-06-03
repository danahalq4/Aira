//
//  TrendsStore.swift
//  Aira
//

import Foundation
import Combine


struct DailyAsthmaScore: Identifiable {

    let id = UUID()

    let day: String

    let score: Double
}



final class TrendsStore: ObservableObject {


    static let shared = TrendsStore()


    @Published var triggers: [RiskTrigger] = []

    @Published var weeklyScores: [DailyAsthmaScore] = []


    private init() {}



    func update(
        score: Double,
        triggers: [RiskTrigger]
    ) {


        self.triggers = triggers


        saveTodayScore(
            score
        )
    }





    private func saveTodayScore(
        _ score: Double
    ) {


        let formatter = DateFormatter()

        formatter.dateFormat = "EEE"


        let today =
        formatter
            .string(from: Date())
            .uppercased()



        weeklyScores
            .removeAll {

                $0.day == today
            }



        weeklyScores
            .append(

                DailyAsthmaScore(

                    day: today,

                    score: score
                )
            )



        // آخر 7 أيام فقط

        if weeklyScores.count > 7 {

            weeklyScores.removeFirst()
        }
    }
}
