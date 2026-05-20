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

    @Published private(set) var score: Double        = 70
    @Published private(set) var animatedScore: Double = 0
    @Published private(set) var scoreLabel: String   = "Good"
    @Published private(set) var airQualityMessage: String = "Why is the asthma risk \(RiskScoreEngine.scoreLabel(70).lowercased())?"
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

    // MARK: - Init

    init() {
        applySampleData()   // show sample immediately while fetching
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
        // You can also set hasActiveAlert here if you want to control the card visibility
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

        // If all env data failed → show sample
        if weather == nil && pollen == nil && aqi == nil {
            usingSampleData = true
            applySampleData()
            isLoading = false
            return
        }

        // Calculate score
        let result = RiskScoreEngine.calculate(from: input)
        apply(result: result)

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

        // Convert RiskTrigger → AsthmaTrigger for existing UI
        // Show only env triggers (not sleep/HR) in main card
        let envNames: Set<String> = ["Temperature", "Humidity", "Pollen", "Air Quality"]
        triggers = result.triggers
            .filter { envNames.contains($0.name) }
            .map { AsthmaTrigger(name: $0.name, icon: $0.icon, level: $0.level, displayValue: $0.displayValue) }

        withAnimation(.easeOut(duration: 1.2)) {
            animatedScore = score
        }
    }

    // MARK: - Sample fallback

    private func applySampleData() {
        let sampleInput = RiskInput(
            temperature_2m: 30,
            relative_humidity_2m: 55,
            pollenCount: 35,
            aqi: 48,
            sleepHours: nil,
            heartRate: nil,
            steps: nil,
            respiratoryRate: nil
        )
        let result = RiskScoreEngine.calculate(from: sampleInput)
        apply(result: result)
    }
}

