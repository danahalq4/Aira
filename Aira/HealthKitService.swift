//
//  HealthKitService.swift
//  Aira
//

import HealthKit


struct HealthData {

    let sleepHours: Double?
    let restingHeartRate: Double?
    let steps: Double?
    let respiratoryRate: Double?


    var sleepLevel: TriggerLevel {

        guard let h = sleepHours else { return .low }

        if h < 5 {
            return .high
        }

        if h < 7 {
            return .moderate
        }

        return .low
    }


    var heartRateLevel: TriggerLevel {

        guard let hr = restingHeartRate else { return .low }

        if hr > 100 {
            return .high
        }

        if hr > 80 {
            return .moderate
        }

        return .low
    }


    var stepsLevel: TriggerLevel {

        guard let s = steps else { return .low }

        if s < 2000 {
            return .moderate
        }

        return .low
    }


    var respiratoryLevel: TriggerLevel {

        guard let r = respiratoryRate else { return .low }

        if r > 20 {
            return .high
        }

        if r > 16 {
            return .moderate
        }

        return .low
    }
}





final class HealthKitService {


    static let shared = HealthKitService()


    private let store = HKHealthStore()


    private init() {}





    // MARK: Permission

    func requestAuthorization() async throws {


        guard HKHealthStore.isHealthDataAvailable()
        else { return }



        let types: Set<HKObjectType> = [


            HKObjectType.categoryType(
                forIdentifier: .sleepAnalysis
            )!,


            HKObjectType.quantityType(
                forIdentifier: .restingHeartRate
            )!,


            HKObjectType.quantityType(
                forIdentifier: .stepCount
            )!,


            HKObjectType.quantityType(
                forIdentifier: .respiratoryRate
            )!
        ]



        try await store.requestAuthorization(
            toShare: [],
            read: types
        )
    }







    // MARK: Fetch All

    func fetchAll() async -> HealthData {


        async let sleep =
        fetchSleep()



        async let heart =
        fetchLatestQuantity(
            .restingHeartRate,
            unit: HKUnit.count()
                .unitDivided(
                    by: .minute()
                )
        )



        async let steps =
        fetchTodaySteps()



        async let resp =
        fetchLatestQuantity(
            .respiratoryRate,
            unit: HKUnit.count()
                .unitDivided(
                    by: .minute()
                )
        )



        let result =
        await HealthData(

            sleepHours: sleep,

            restingHeartRate: heart,

            steps: steps,

            respiratoryRate: resp
        )


        print(
            """
            🩺 HEALTH VALUES
            Sleep: \(result.sleepHours ?? -1)
            Heart: \(result.restingHeartRate ?? -1)
            Steps: \(result.steps ?? -1)
            Resp: \(result.respiratoryRate ?? -1)
            """
        )


        return result
    }







    // MARK: Sleep

    private func fetchSleep() async -> Double? {


        guard let type =
        HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )

        else { return nil }



        let start =
        Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: Date()
        )!



        let predicate =
        HKQuery.predicateForSamples(
            withStart: start,
            end: Date()
        )



        return await withCheckedContinuation { cont in


            let query =
            HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: 100,
                sortDescriptors: nil
            ) { _, samples, _ in



                let sleepSamples =
                samples as? [HKCategorySample] ?? []



                let seconds =
                sleepSamples.reduce(0.0) {


                    if $1.value !=
                        HKCategoryValueSleepAnalysis.awake.rawValue {


                        return $0 +
                        $1.endDate
                            .timeIntervalSince(
                                $1.startDate
                            )
                    }


                    return $0
                }



                cont.resume(
                    returning:
                        seconds > 0
                    ? seconds / 3600
                    : nil
                )
            }


            store.execute(query)
        }
    }








    // MARK: Steps

    private func fetchTodaySteps() async -> Double? {


        guard let type =
        HKQuantityType.quantityType(
            forIdentifier: .stepCount
        )

        else { return nil }



        let start =
        Calendar.current
            .startOfDay(for: Date())



        let predicate =
        HKQuery.predicateForSamples(
            withStart: start,
            end: Date()
        )



        return await withCheckedContinuation { cont in


            let query =
            HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in


                cont.resume(
                    returning:
                    result?
                    .sumQuantity()?
                    .doubleValue(for: .count())
                )
            }


            store.execute(query)
        }
    }







    // MARK: Latest Quantity

    private func fetchLatestQuantity(
        _ id: HKQuantityTypeIdentifier,
        unit: HKUnit
    ) async -> Double? {



        guard let type =
        HKQuantityType.quantityType(
            forIdentifier: id
        )

        else { return nil }




        let sort =
        NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )



        return await withCheckedContinuation { cont in


            let query =
            HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in



                let value =
                (samples?.first as? HKQuantitySample)?
                    .quantity
                    .doubleValue(for: unit)



                cont.resume(
                    returning: value
                )
            }



            store.execute(query)
        }
    }
}
