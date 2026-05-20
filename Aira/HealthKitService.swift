//
//  HealthKitService.swift
//  Aira
//
//  Requires "Privacy - Health Share Usage Description" in Info.plist
//

import HealthKit

struct HealthData {
    let sleepHours: Double?         // last night
    let restingHeartRate: Double?   // bpm
    let steps: Double?              // today's steps
    let respiratoryRate: Double?    // breaths/min

    // MARK: Trigger levels for Trends top triggers

    var sleepLevel: TriggerLevel {
        guard let h = sleepHours else { return .low }
        if h < 5 { return .high }
        if h < 7 { return .moderate }
        return .low
    }

    var heartRateLevel: TriggerLevel {
        guard let hr = restingHeartRate else { return .low }
        if hr > 100 { return .high }
        if hr > 80  { return .moderate }
        return .low
    }

    var stepsLevel: TriggerLevel {
        guard let s = steps else { return .low }
        if s > 15000 { return .high }
        if s > 8000  { return .moderate }
        return .low
    }

    var respiratoryLevel: TriggerLevel {
        guard let r = respiratoryRate else { return .low }
        if r > 20 { return .high }
        if r > 16 { return .moderate }
        return .low
    }
}

final class HealthKitService {

    static let shared = HealthKitService()
    private let store = HKHealthStore()
    private init() {}

    // MARK: - Permission

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let types: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        ]

        try await store.requestAuthorization(toShare: [], read: types)
    }

    // MARK: - Fetch All

    func fetchAll() async -> HealthData {
        async let sleep = fetchSleep()
        async let hr    = fetchLatestQuantity(.heartRate, unit: HKUnit(from: "count/min"))
        async let steps = fetchTodaySteps()
        async let rr    = fetchLatestQuantity(.respiratoryRate, unit: HKUnit(from: "count/min"))

        return await HealthData(
            sleepHours:      sleep,
            restingHeartRate: hr,
            steps:           steps,
            respiratoryRate: rr
        )
    }

    // MARK: - Sleep

    private func fetchSleep() async -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }

        let now   = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let pred  = HKQuery.predicateForSamples(withStart: start, end: now)
        let sort  = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type,
                                      predicate: pred,
                                      limit: 50,
                                      sortDescriptors: [sort]) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
                ]
                let totalSeconds = samples
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }

                continuation.resume(returning: totalSeconds > 0 ? totalSeconds / 3600 : nil)
            }
            store.execute(query)
        }
    }

    // MARK: - Today Steps

    private func fetchTodaySteps() async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return nil }

        let start = Calendar.current.startOfDay(for: Date())
        let pred  = HKQuery.predicateForSamples(withStart: start, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type,
                                          quantitySamplePredicate: pred,
                                          options: .cumulativeSum) { _, stats, _ in
                let value = stats?.sumQuantity()?.doubleValue(for: .count())
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    // MARK: - Latest Quantity (HR, RR)

    private func fetchLatestQuantity(_ identifier: HKQuantityTypeIdentifier,
                                     unit: HKUnit) async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type,
                                      predicate: nil,
                                      limit: 1,
                                      sortDescriptors: [sort]) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?
                    .quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }
}
