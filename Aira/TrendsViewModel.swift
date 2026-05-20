//
//  TrendsViewModel.swift
//  Aira
//

import Foundation
import SwiftUI
import Combine
import SwiftData
import CoreLocation

final class TrendsViewModel: ObservableObject {

    @Published private(set) var topTriggers: [TopTrigger] = []
    @Published private(set) var weeklyData: [DailySymptomData] = []

    // SwiftData context injected from the view
    var modelContext: ModelContext?

    private let locationManager = CLLocationManager()

    init() {
        loadWeeklySymptomData()
        Task { await loadAllTriggers() }
    }

    // MARK: - Weekly bar chart from SwiftData

    func loadWeeklySymptomData() {
        guard let context = modelContext else {
            loadFallbackWeeklyData()
            return
        }

        let calendar = Calendar.current
        let today = Date()

        // Build last 7 days starting from Sunday
        var days: [DailySymptomData] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // MON, TUE etc.

        for offset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }

            // Fetch symptoms logged on this day
            let predicate = #Predicate<SymptomLog> {
                $0.date >= dayStart && $0.date < dayEnd
            }
            let descriptor = FetchDescriptor<SymptomLog>(predicate: predicate)
            let logs = (try? context.fetch(descriptor)) ?? []

            let count = Double(logs.count)
            let maxExpected = 5.0 // normalise against 5 symptoms = full bar
            let severity = min(1.0, count / maxExpected)
            let isHigh = severity >= 0.6

            let label = formatter.string(from: date).uppercased().prefix(3)
            days.append(DailySymptomData(day: String(label), severity: severity, isHighSeverity: isHigh))
        }

        DispatchQueue.main.async {
            self.weeklyData = days
        }
    }

    private func loadFallbackWeeklyData() {
        weeklyData = [
            DailySymptomData(day: "SUN", severity: 0.55, isHighSeverity: false),
            DailySymptomData(day: "MON", severity: 0.55, isHighSeverity: true),
            DailySymptomData(day: "TUE", severity: 0.55, isHighSeverity: true),
            DailySymptomData(day: "WED", severity: 0.55, isHighSeverity: true),
            DailySymptomData(day: "THU", severity: 0.04, isHighSeverity: false),
            DailySymptomData(day: "FRI", severity: 0.55, isHighSeverity: false),
            DailySymptomData(day: "SAT", severity: 0.55, isHighSeverity: false)
        ]
    }

    // MARK: - Load all triggers (Ambee + HealthKit)

    @MainActor
    private func loadAllTriggers() async {
        let location = await resolveLocation()

        // Fetch all sources in parallel
        async let pollenTask   = fetchPollen(location: location)
        async let aqiTask      = fetchAQI(location: location)
        async let weatherTask  = fetchWeather(location: location)
        async let healthTask   = fetchHealth()

        let (pollen, aqi, weather, health) = await (pollenTask, aqiTask, weatherTask, healthTask)

        // Build symptom count per day to use as ranking weight
        let symptomWeight = symptomCountWeight()

        var triggers: [TopTrigger] = []

        // --- Pollen ---
        if let p = pollen {
            triggers.append(TopTrigger(
                icon: "leaf.fill",
                title: "Pollen",
                subtitle: p.displayValue,
                percentage: min(1.0, Double(p.dominant) / 100.0),
                iconColor: Color("ColorG"),
                level: p.level,
                symptomDayWeight: symptomWeight
            ))
        }

        // --- AQI ---
        if let a = aqi {
            triggers.append(TopTrigger(
                icon: "aqi.medium",
                title: "Air Quality",
                subtitle: a.displayValue,
                percentage: min(1.0, a.aqi / 200.0),
                iconColor: Color("ColorY"),
                level: a.level,
                symptomDayWeight: symptomWeight
            ))
        }

        // --- Humidity ---
        if let w = weather {
            triggers.append(TopTrigger(
                icon: "humidity.fill",
                title: "Humidity",
                subtitle: w.displayValue,
                percentage: min(1.0, w.humidity / 100.0),
                iconColor: Color("ColorB"),
                level: w.level,
                symptomDayWeight: symptomWeight
            ))
        }

        // --- HealthKit ---
        if let h = health {
            if let sleep = h.sleepHours {
                let pct = max(0, min(1, (8 - sleep) / 8))
                triggers.append(TopTrigger(
                    icon: "moon.zzz.fill",
                    title: "Sleep",
                    subtitle: String(format: "%.1f hrs", sleep),
                    percentage: pct,
                    iconColor: Color("ColorB"),
                    level: h.sleepLevel,
                    symptomDayWeight: symptomWeight
                ))
            }
            if let hr = h.restingHeartRate {
                let pct = max(0, min(1, (hr - 60) / 60))
                triggers.append(TopTrigger(
                    icon: "heart.fill",
                    title: "Heart Rate",
                    subtitle: String(format: "%.0f bpm", hr),
                    percentage: pct,
                    iconColor: Color("ColorR"),
                    level: h.heartRateLevel,
                    symptomDayWeight: symptomWeight
                ))
            }
        }

        // Rank: combined score of percentage + symptom day weight
        self.topTriggers = triggers.sorted {
            ($0.percentage + $0.symptomDayWeight) > ($1.percentage + $1.symptomDayWeight)
        }
    }

    // MARK: - Symptom day weight (normalised 0–1)

    /// Returns a 0–1 weight based on how many symptoms were logged today
    private func symptomCountWeight() -> Double {
        guard let context = modelContext else { return 0 }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }

        let predicate = #Predicate<SymptomLog> {
            $0.date >= start && $0.date < end
        }
        let descriptor = FetchDescriptor<SymptomLog>(predicate: predicate)
        let count = (try? context.fetch(descriptor))?.count ?? 0
        return min(1.0, Double(count) / 5.0)
    }

    // MARK: - Data fetchers

    private func fetchPollen(location: CLLocation?) async -> PollenData? {
        guard let loc = location else { return nil }
        return try? await AmbeeService.shared.fetch(for: loc)
    }

    private func fetchAQI(location: CLLocation?) async -> AQIData? {
        guard let loc = location else { return nil }
        return try? await AmbeeService.shared.fetchAQI(for: loc)
    }

    private func fetchWeather(location: CLLocation?) async -> AmbeeWeatherData? {
        guard let loc = location else { return nil }
        return try? await AmbeeService.shared.fetchWeather(for: loc)
    }

    private func fetchHealth() async -> HealthData? {
        try? await HealthKitService.shared.requestAuthorization()
        return await HealthKitService.shared.fetchAll()
    }

    private func resolveLocation() async -> CLLocation? {
        locationManager.requestWhenInUseAuthorization()
        return locationManager.location
    }
}
