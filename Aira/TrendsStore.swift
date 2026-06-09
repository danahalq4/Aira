//
//  TrendsStore.swift
//  Aira
//

import Foundation
import Combine


struct DailyAsthmaScore:
    Identifiable,
    Codable {


    let id: UUID

    let date: Date

    let day: String

    let score: Double





    init(
        id: UUID = UUID(),

        date: Date = Date(),

        day: String,

        score: Double
    ) {


        self.id =
        id



        self.date =
        Calendar
            .current
            .startOfDay(
                for: date
            )



        self.day =
        day



        self.score =
        score
    }
}






final class TrendsStore: ObservableObject {


    static let shared =
    TrendsStore()



    @Published var triggers: [RiskTrigger] = []



    @Published var weeklyScores: [DailyAsthmaScore] = [] {

        didSet {

            saveToStorage()
        }
    }





    private let storageKey =
    "weeklyAsthmaScores"






    private init() {


        loadFromStorage()
    }








    func update(
        score: Double,
        triggers: [RiskTrigger]
    ) {


        self.triggers =
        triggers



        saveTodayScore(
            score
        )
    }









    private func saveTodayScore(
        _ score: Double
    ) {


        let calendar =
        Calendar.current



        let todayDate =
        calendar.startOfDay(
            for: Date()
        )



        let formatter =
        DateFormatter()


        formatter.locale =
        Locale(identifier: "en_US_POSIX")

        formatter.dateFormat =
        "EEE"

        let todayName =
        formatter
            .string(
                from: todayDate
            )
            .uppercased()







        // لو نفس اليوم موجود حدثه

        weeklyScores
            .removeAll {

                calendar.isDate(
                    $0.date,
                    inSameDayAs:
                        todayDate
                )
            }






        weeklyScores.append(

            DailyAsthmaScore(

                date:
                    todayDate,

                day:
                    todayName,

                score:
                    score
            )
        )







        // خذ آخر 7 أيام فقط

        weeklyScores =
        weeklyScores

            .filter {


                guard let diff =
                    calendar.dateComponents(
                        [.day],
                        from:
                            $0.date,
                        to:
                            todayDate
                    )
                    .day

                else {

                    return false
                }


                return diff < 7
            }



            .sorted {

                $0.date <
                $1.date
            }
    }









    private func saveToStorage() {


        if let data =
            try? JSONEncoder()
            .encode(
                weeklyScores
            ) {


            UserDefaults
                .standard
                .set(
                    data,
                    forKey:
                        storageKey
                )
        }
    }









    private func loadFromStorage() {


        guard

            let data =
                UserDefaults
                .standard
                .data(
                    forKey:
                        storageKey
                ),


            let saved =
                try? JSONDecoder()
                .decode(
                    [DailyAsthmaScore].self,
                    from:
                        data
                )


        else {

            return
        }



        weeklyScores =
        saved
    }
}
