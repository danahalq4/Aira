//
//  AsthmaOverviewViewModel.swift
//  Aira
//

import SwiftUI
import Combine
import CoreLocation
import WatchConnectivity

@MainActor
final class AsthmaOverviewViewModel: ObservableObject {


    // MARK: - Published State

    @Published private(set) var score: Double = 0
    @Published private(set) var animatedScore: Double = 0
    @Published private(set) var scoreLabel: String = "—"

    @Published private(set) var airQualityMessage: String =
    "Why is the asthma risk —?"

    @Published private(set) var triggers: [AsthmaTrigger] = []

    @Published private(set) var riskTriggers: [RiskTrigger] = []

    @Published private(set) var inhalerReminderMessage =
    "Use your inhaler as prescribed"

    @Published private(set) var hasActiveAlert = false
    @Published private(set) var isLoading = false

    @Published var showAirDetail = false
    @Published var showAlert = false



    // MARK: - Services

    private let locationService =
    LocationService.shared

    private var cancellables =
    Set<AnyCancellable>()



    // MARK: - Init

    init() {
        observeLocation()
    }



    // MARK: - Intents

    func onAppear() {

        withAnimation(.easeOut(duration: 1.2)) {
            animatedScore = score
        }

        locationService.requestPermissionAndStart()
    }


    func airQualityTapped() {
        showAirDetail = true
    }


    func inhalerReminderTapped() {
        showAlert = true
    }



    // MARK: - Location

    private func observeLocation() {

        locationService.$location

            .compactMap { $0 }

            .removeDuplicates { a, b in
                a.distance(from: b) < 500
            }

            .sink { [weak self] location in

                Task {
                    await self?.fetchAllData(
                        for: location
                    )
                }
            }

            .store(
                in: &cancellables
            )
    }



    // MARK: - Fetch

    private func fetchAllData(
        for location: CLLocation
    ) async {


        isLoading = true


        var input = RiskInput()



        async let weatherResult =
        fetchWeather(location: location)


        async let aqiResult =
        fetchAQI(location: location)


        async let healthResult =
        HealthKitService.shared.fetchAll()



        let (
            weather,
            aqi,
            health
        ) =
        await (
            weatherResult,
            aqiResult,
            healthResult
        )



        // Weather + Wind

        if let w = weather {

            input.temperature_2m =
            w.temperature_2m


            input.relative_humidity_2m =
            Double(w.relative_humidity_2m)


            input.windSpeed =
            w.wind_speed_10m
        }



        // AQI

        if let a = aqi {

            input.aqi =
            a.aqi
        }



        // Health

        input.sleepHours =
        health.sleepHours


        input.heartRate =
        health.restingHeartRate


        input.steps =
        health.steps


        input.respiratoryRate =
        health.respiratoryRate



        let hasAnyInput =

        input.temperature_2m != nil ||

        input.relative_humidity_2m != nil ||

        input.windSpeed != nil ||

        input.aqi != nil



        if hasAnyInput {

            let result =
            RiskScoreEngine.calculate(
                from: input
            )


            apply(
                result: result
            )


        } else {


            score = 0

            scoreLabel = "—"

            airQualityMessage =
            "Why is the asthma risk —?"


            riskTriggers = []

            triggers = []

            animatedScore = 0
        }


        isLoading = false
    }



    // MARK: - Fetch helpers


    private func fetchWeather(
        location: CLLocation
    ) async -> WeatherData? {

        try? await WeatherService.shared.fetch(
            for: location
        )
    }



    private func fetchAQI(
        location: CLLocation
    ) async -> AirQualityData? {

        try? await AirVisualService.shared.fetch(
            for: location
        )
    }



    // MARK: - Apply Result


    private func apply(
        result: RiskResult
    ) {


        score =
        result.score


        scoreLabel =
        result.label


        airQualityMessage =
        "Why is the asthma risk \(result.label.lowercased())?"


        riskTriggers =
        result.triggers



        var main: [AsthmaTrigger] = []



        func makeAsthmaTrigger(
            from rt: RiskTrigger
        ) -> AsthmaTrigger {


            AsthmaTrigger(

                name: rt.name,

                icon: rt.icon,

                level: rt.level,

                displayValue: rt.displayValue
            )
        }



        for rt in result.triggers {


            if rt.name == "Temperature" ||

                rt.name == "Humidity" ||

                rt.name == "Air Quality" ||

                rt.name == "Wind Speed" {


                main.append(
                    makeAsthmaTrigger(from: rt)
                )
            }
        }



        triggers = main



        print(
            "ABOUT TO SEND SCORE TO WATCH:",
            result.score,
            result.label
        )



        WatchConnectivityManager.shared
            .sendScoreToWatch(
                result: result
            )



        withAnimation(
            .easeOut(duration: 1.2)
        ) {

            animatedScore = score
        }
    }
}
