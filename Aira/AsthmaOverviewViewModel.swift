//
//  AsthmaOverviewViewModel.swift
//  Aira
//

import SwiftUI
import Combine
import CoreLocation

@MainActor
final class AsthmaOverviewViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var score: Double        = 0
    @Published private(set) var animatedScore: Double = 0
    @Published private(set) var scoreLabel: String   = "—"
    @Published private(set) var airQualityMessage: String = "Why is the asthma risk —?"
    @Published private(set) var triggers: [AsthmaTrigger] = []
    @Published private(set) var riskTriggers: [RiskTrigger] = []  // for detail view
    @Published private(set) var inhalerReminderMessage: String = "Use your inhaler as prescribed"
    @Published private(set) var hasActiveAlert: Bool  = false
    @Published private(set) var isLoading: Bool       = false
    @Published private(set) var usingSampleData: Bool = false

    @Published var showAirDetail: Bool = false
    @Published var showAlert: Bool = false   // NEW: navigate to ALERT

    // MARK: - Services

    private let locationService = LocationService.shared
    private var cancellables    = Set<AnyCancellable>()

    // Cache last pollen triple for building main card summary
    private var lastTreePollen: Int?
    private var lastWeedPollen: Int?
    private var lastGrassPollen: Int?

    // MARK: - Init

    init() {
        // Removed sample data. We’ll wait for real fetches.
        observeLocation()
    }

    // MARK: - Intents

    func onAppear() {
        withAnimation(.easeOut(duration: 1.2)) {
            animatedScore = score
        }
        locationService.requestPermissionAndStart()
    }

    func airQualityTapped() { showAirDetail = true }
    func inhalerReminderTapped() {
        showAlert = true
    }

    // MARK: - Location observer

    private func observeLocation() {
        locationService.$location
            .compactMap { $0 }
            .removeDuplicates { a, b in
                a.distance(from: b) < 500
            }
            .sink { [weak self] location in
                Task { await self?.fetchAllData(for: location) }
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    private func fetchAllData(for location: CLLocation) async {
        isLoading = true
        usingSampleData = false

        var input = RiskInput()

        // Run all fetches concurrently
        async let weatherResult  = fetchWeather(location: location)
        async let pollenResult   = fetchPollen(location: location)
        async let aqiResult      = fetchAQI(location: location)
        async let healthResult   = HealthKitService.shared.fetchAll()

        let (weather, pollen, aqi, health) = await (weatherResult, pollenResult, aqiResult, healthResult)

        // Weather
        if let w = weather {
            input.temperature_2m = w.temperature_2m
            input.relative_humidity_2m = Double(w.relative_humidity_2m)
        }

        // Pollen
        if let p = pollen {
            input.pollenCount = p.dominant
            input.treePollen = p.treePollen
            input.weedPollen = p.weedPollen
            input.grassPollen = p.grassPollen

            lastTreePollen = p.treePollen
            lastWeedPollen = p.weedPollen
            lastGrassPollen = p.grassPollen
        } else {
            lastTreePollen = nil
            lastWeedPollen = nil
            lastGrassPollen = nil
        }

        // AQI
        if let a = aqi {
            input.aqi = a.aqi
        }

        // Health
        input.sleepHours     = health.sleepHours
        input.heartRate      = health.restingHeartRate
        input.steps          = health.steps
        input.respiratoryRate = health.respiratoryRate

        // Removed sample fallback: if data fails, we simply apply what we have.
        // If nothing available, UI will reflect empty/defaults.

        // Calculate score only if we have at least one meaningful input
        let hasAnyInput =
            input.temperature_2m != nil ||
            input.relative_humidity_2m != nil ||
            input.pollenCount != nil ||
            input.aqi != nil ||
            input.sleepHours != nil ||
            input.heartRate != nil

        if hasAnyInput {
            let result = RiskScoreEngine.calculate(from: input)
            apply(result: result)
        } else {
            // Reset UI to empty state
            score = 0
            scoreLabel = "—"
            airQualityMessage = "Why is the asthma risk —?"
            riskTriggers = []
            triggers = []
            animatedScore = 0
        }

        isLoading = false
    }

    // MARK: - Individual fetches (silent fail)

    private func fetchWeather(location: CLLocation) async -> WeatherData? {
        try? await WeatherService.shared.fetch(for: location)
    }

    private func fetchPollen(location: CLLocation) async -> PollenData? {
        try? await AmbeeService.shared.fetch(for: location)
    }

    private func fetchAQI(location: CLLocation) async -> AirQualityData? {
        try? await AirVisualService.shared.fetch(for: location)
    }

    // MARK: - Apply result → UI

    private func apply(result: RiskResult) {
        score        = result.score
        scoreLabel   = result.label
        airQualityMessage = "Why is the asthma risk \(result.label.lowercased())?"
        riskTriggers = result.triggers

        // Build main card triggers:
        // - Temperature, Humidity, Air Quality as-is.
        // - Pollen: عنصر واحد بمستوى مجمّع حسب أعلى قيمة بين الثلاثة.
        var main: [AsthmaTrigger] = []

        func makeAsthmaTrigger(from rt: RiskTrigger) -> AsthmaTrigger {
            AsthmaTrigger(name: rt.name, icon: rt.icon, level: rt.level, displayValue: rt.displayValue)
        }

        for rt in result.triggers {
            if rt.name == "Temperature" || rt.name == "Humidity" || rt.name == "Air Quality" {
                main.append(makeAsthmaTrigger(from: rt))
            }
        }

        if let t = lastTreePollen, let w = lastWeedPollen, let g = lastGrassPollen {
            let maxVal = max(t, max(w, g))
            let level: TriggerLevel
            if maxVal > 50 {
                level = .high
            } else if maxVal >= 20 {
                level = .moderate
            } else {
                level = .low
            }
            main.append(AsthmaTrigger(
                name: "Pollen",
                icon: "leaf.fill",
                level: level,
                displayValue: "\(maxVal) gr/m³"
            ))
        } else if let summary = result.triggers.first(where: { $0.name == "Pollen (Total)" }) {
            main.append(makeAsthmaTrigger(from: summary))
        }

        triggers = main

        withAnimation(.easeOut(duration: 1.2)) {
            animatedScore = score
        }
    }
}
