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


    // MARK: - Published

    @Published private(set) var score: Double = 0
    @Published private(set) var animatedScore: Double = 0
    @Published private(set) var scoreLabel: String = "—"

    @Published private(set) var airQualityMessage =
    "Why is the asthma risk ?"
    // HOME (Air only)
    @Published private(set) var triggers: [AsthmaTrigger] = []

    // ALL (Air + Health)
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







    // MARK: - Actions

    func onAppear() {


        withAnimation(
            .easeOut(duration: 1.2)
        ) {

            animatedScore =
            score
        }



        locationService
            .requestPermissionAndStart()
    }






    func airQualityTapped() {

        showAirDetail =
        true
    }




    func inhalerReminderTapped() {

        showAlert =
        true
    }









    // MARK: - Location

    private func observeLocation() {


        locationService
            .$location


            .compactMap {

                $0
            }



            .removeDuplicates { a, b in


                a.distance(
                    from: b
                ) < 500
            }



            .sink { [weak self] location in


                Task {


                    await self?
                        .fetchAllData(
                            for: location
                        )
                }
            }



            .store(
                in: &cancellables
            )
    }










    // MARK: - Fetch All


    private func fetchAllData(
        for location: CLLocation
    ) async {



        isLoading =
        true



        var input =
        RiskInput()





        async let weatherResult =
        fetchWeather(
            location: location
        )


        async let aqiResult =
        fetchAQI(
            location: location
        )


        async let pollenResult =
        fetchPollen(
            location: location
        )


        async let healthResult =
        HealthKitService.shared.fetchAll()






        let (
            weather,
            aqi,
            pollen,
            health
        )
        =
        await (
            weatherResult,
            aqiResult,
            pollenResult,
            healthResult
        )







        if let w = weather {


            input.temperature_2m =
            w.temperature_2m


            input.relative_humidity_2m =
            Double(
                w.relative_humidity_2m
            )


            input.windSpeed =
            w.wind_speed_10m
        }






        if let a = aqi {


            input.aqi =
            a.aqi
        }






        if let p = pollen {



            let risks = [

                p.treeRisk,
                p.grassRisk,
                p.weedRisk
            ]



            if risks.contains("High") {


                input.pollenRisk =
                "High"


            } else if risks.contains("Moderate") {


                input.pollenRisk =
                "Moderate"


            } else {


                input.pollenRisk =
                "Low"
            }




            input.treePollenCount =
            p.treeCount


            input.grassPollenCount =
            p.grassCount


            input.weedPollenCount =
            p.weedCount
        }








        input.sleepHours =
        health.sleepHours


        input.heartRate =
        health.restingHeartRate


        input.steps =
        health.steps


        input.respiratoryRate =
        health.respiratoryRate








        let result =
        RiskScoreEngine.calculate(
            from: input
        )





        apply(
            result: result
        )



        isLoading =
        false
    }











    // MARK: - Helpers


    private func fetchWeather(
        location: CLLocation
    ) async -> WeatherData? {


        try? await
        WeatherService.shared.fetch(
            for: location
        )
    }






    private func fetchAQI(
        location: CLLocation
    ) async -> AirQualityData? {


        try? await
        AirVisualService.shared.fetch(
            for: location
        )
    }







    private func fetchPollen(
        location: CLLocation
    ) async -> PollenData? {


        try? await
        AmbeeService.shared.fetch(
            for: location
        )
    }










    // MARK: - Apply


    private func apply(
        result: RiskResult
    ) {


        score =
        result.score

        scoreLabel =
        result.label

        airQualityMessage =
        String(
            format: NSLocalizedString("Why is the asthma risk %@?", comment: ""),
            NSLocalizedString(result.label.lowercased(), comment: "")
        )







        // MARK: Alert only High + Critical


        if result.score < 40 {



            hasActiveAlert =
            true





            if result.score < 25 {



                inhalerReminderMessage =
                "Critical asthma risk detected. Review your recommendations."



            } else {



                inhalerReminderMessage =
                "High asthma risk detected. Check your recommendations."
            }






            AlertHistoryStore.shared
                .saveIfNeeded(
                    result: result
                )



        } else {




            hasActiveAlert =
            false




            inhalerReminderMessage =
            "Use your inhaler as prescribed"
        }









      





        riskTriggers =
        result.triggers









        TrendsStore.shared.update(

            score:
                result.score,


            triggers:
                result.triggers
        )










        triggers =
        result.triggers


            .filter {


                $0.name == "Air Quality" ||

                $0.name == "Humidity" ||

                $0.name == "Temperature" ||

                $0.name == "Wind Speed" ||

                $0.name == "Pollen"
            }



            .map {


                AsthmaTrigger(

                    name:
                        $0.name,


                    icon:
                        $0.icon,


                    level:
                        $0.level,


                    displayValue:
                        $0.displayValue
                )
            }









        WatchConnectivityManager.shared
            .sendScoreToWatch(
                result: result
            )








        withAnimation(
            .easeOut(duration: 1.2)
        ) {


            animatedScore =
            score
        }
    }
}
