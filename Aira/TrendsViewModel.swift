//
//  TrendsViewModel.swift
//  Aira
//

import Foundation
import SwiftUI
import Combine

final class TrendsViewModel: ObservableObject {

    @Published var selectedPeriod: TrendPeriod = .week
    @Published private(set) var topTriggers: [TopTrigger] = []
    @Published private(set) var weeklyData: [DailySymptomData] = []

    init() {
        loadStaticWeeklyData()
        loadHealthTriggers()
    }

    // MARK: - Weekly bar chart (static for now)

    private func loadStaticWeeklyData() {
        weeklyData = [
            DailySymptomData(day: "MON", severity: 0.04, isHighSeverity: false),
            DailySymptomData(day: "TUE", severity: 0.04, isHighSeverity: false),
            DailySymptomData(day: "WED", severity: 0.04, isHighSeverity: false),
            DailySymptomData(day: "THU", severity: 0.04, isHighSeverity: false),
            DailySymptomData(day: "FRI", severity: 0.62, isHighSeverity: false),
            DailySymptomData(day: "SAT", severity: 0.62, isHighSeverity: true),
            DailySymptomData(day: "SUN", severity: 0.46, isHighSeverity: false)
        ]
    }

    // MARK: - HealthKit top triggers

    private func loadHealthTriggers() {
        Task { @MainActor in
            try? await HealthKitService.shared.requestAuthorization()
            let health = await HealthKitService.shared.fetchAll()
            self.topTriggers = buildTriggers(from: health)
        }
    }

    private func buildTriggers(from health: HealthData) -> [TopTrigger] {
        var triggers: [TopTrigger] = []

        // Sleep
        if let sleep = health.sleepHours {
            let pct = max(0, min(1, (8 - sleep) / 8))   // lower sleep = higher percentage
            triggers.append(TopTrigger(
                icon: "moon.zzz.fill",
                title: "Sleep",
                subtitle: String(format: "%.1f hrs last night", sleep),
                percentage: pct,
                iconColor: Color("ColorB"),
                level: health.sleepLevel
            ))
        } else {
            // No HealthKit data — show placeholder
            triggers.append(TopTrigger(
                icon: "moon.zzz.fill",
                title: "Sleep",
                subtitle: "No data",
                percentage: 0.0,
                iconColor: Color("ColorB"),
                level: .low
            ))
        }

        // Heart Rate
        if let hr = health.restingHeartRate {
            let pct = max(0, min(1, (hr - 60) / 60))
            triggers.append(TopTrigger(
                icon: "heart.fill",
                title: "Heart Rate",
                subtitle: String(format: "%.0f bpm", hr),
                percentage: pct,
                iconColor: Color("ColorR"),
                level: health.heartRateLevel
            ))
        } else {
            triggers.append(TopTrigger(
                icon: "heart.fill",
                title: "Heart Rate",
                subtitle: "No data",
                percentage: 0.0,
                iconColor: Color("ColorR"),
                level: .low
            ))
        }

        // Steps
        if let steps = health.steps {
            let pct = max(0, min(1, steps / 20000))
            triggers.append(TopTrigger(
                icon: "figure.walk",
                title: "Activity",
                subtitle: String(format: "%.0f steps today", steps),
                percentage: pct,
                iconColor: Color("ColorG"),
                level: health.stepsLevel
            ))
        } else {
            triggers.append(TopTrigger(
                icon: "figure.walk",
                title: "Activity",
                subtitle: "No data",
                percentage: 0.0,
                iconColor: Color("ColorG"),
                level: .low
            ))
        }

        // Respiratory Rate (if available)
        if let rr = health.respiratoryRate {
            let pct = max(0, min(1, (rr - 12) / 12))
            triggers.append(TopTrigger(
                icon: "lungs.fill",
                title: "Resp. Rate",
                subtitle: String(format: "%.0f br/min", rr),
                percentage: pct,
                iconColor: Color("ColorY"),
                level: health.respiratoryLevel
            ))
        }

        return triggers.sorted { $0.percentage > $1.percentage }
    }
}
