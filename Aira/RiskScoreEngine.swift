//
//  RiskScoreEngine.swift
//  Aira
//

import Foundation

// MARK: - Input snapshot

struct RiskInput {

    // Environment
    var temperature_2m: Double?
    var relative_humidity_2m: Double?
    var windSpeed: Double?
    var aqi: Int?

    // Health — for future Trends only
    var sleepHours: Double?
    var heartRate: Double?
    var steps: Double?
    var respiratoryRate: Double?
}


// MARK: - Output

struct RiskResult {

    let score: Double
    let label: String
    let triggers: [RiskTrigger]
}


struct RiskTrigger {

    let name: String
    let icon: String
    let level: TriggerLevel
    let displayValue: String
    let deduction: Int
    let reasonText: String
}



// MARK: - Engine

enum RiskScoreEngine {


    static func calculate(from input: RiskInput) -> RiskResult {

        var triggers: [RiskTrigger] = []
        var totalDeduction = 0



        // MARK: Air Quality

        if let aqi = input.aqi {

            let (level, reason, deduction) =
            evaluateAQI(aqi)

            triggers.append(
                RiskTrigger(
                    name: "Air Quality",
                    icon: "aqi.low",
                    level: level,
                    displayValue: "AQI \(aqi)",
                    deduction: deduction,
                    reasonText: reason
                )
            )

            totalDeduction += deduction
        }



        // MARK: Humidity

        if let humidity =
            input.relative_humidity_2m {

            let (level, reason, deduction) =
            evaluateHumidity(humidity)

            triggers.append(
                RiskTrigger(
                    name: "Humidity",
                    icon: "drop.fill",
                    level: level,
                    displayValue:
                        "\(Int(humidity))%",
                    deduction: deduction,
                    reasonText: reason
                )
            )

            totalDeduction += deduction
        }



        // MARK: Temperature

        if let temp =
            input.temperature_2m {

            let (level, reason, deduction) =
            evaluateTemperature(temp)

            triggers.append(
                RiskTrigger(
                    name: "Temperature",
                    icon: "thermometer.medium",
                    level: level,
                    displayValue:
                        "\(Int(temp))°C",
                    deduction: deduction,
                    reasonText: reason
                )
            )

            totalDeduction += deduction
        }



        // MARK: Wind Speed

        if let wind =
            input.windSpeed {

            let (level, reason, deduction) =
            evaluateWind(wind)

            triggers.append(
                RiskTrigger(
                    name: "Wind Speed",
                    icon: "wind",
                    level: level,
                    displayValue:
                        "\(Int(wind)) km/h",
                    deduction: deduction,
                    reasonText: reason
                )
            )

            totalDeduction += deduction
        }



        let score =
        max(
            0,
            min(
                100,
                Double(100 - totalDeduction)
            )
        )


        return RiskResult(
            score: score,
            label: scoreLabel(score),
            triggers: triggers
        )
    }



    // MARK: Label

    static func scoreLabel(_ score: Double) -> String {

        switch score {

        case 80...100:
            return "Good"

        case 60..<80:
            return "Fair"

        case 40..<60:
            return "Moderate"

        default:
            return "Poor"
        }
    }



    // MARK: AQI

    private static func evaluateAQI(
        _ aqi: Int
    ) -> (TriggerLevel, String, Int) {


        switch aqi {

        case 0...50:
            return (
                .low,
                "Good — air quality is healthy",
                0
            )

        case 51...100:
            return (
                .moderate,
                "Moderate — sensitive groups take care",
                10
            )

        case 101...150:
            return (
                .high,
                "Unhealthy for sensitive groups",
                18
            )

        default:
            return (
                .high,
                "Unhealthy — avoid outdoor activity",
                25
            )
        }
    }



    // MARK: Humidity

    private static func evaluateHumidity(
        _ humidity: Double
    ) -> (TriggerLevel, String, Int) {


        switch humidity {

        case ..<20:
            return (.high,
                    "Very dry — irritates airways",
                    20)

        case 20..<40:
            return (.moderate,
                    "Dry — monitor breathing",
                    10)

        case 40...60:
            return (.low,
                    "Ideal humidity",
                    0)

        case 61..<75:
            return (.moderate,
                    "High humidity — mold risk",
                    8)

        default:
            return (.high,
                    "Very humid — asthma trigger risk",
                    16)
        }
    }



    // MARK: Temperature

    private static func evaluateTemperature(
        _ temp: Double
    ) -> (TriggerLevel, String, Int) {


        switch temp {

        case ..<8:
            return (.high,
                    "Cold air may trigger symptoms",
                    12)

        case 8..<14:
            return (.moderate,
                    "Cool — monitor symptoms",
                    6)

        case 14...32:
            return (.low,
                    "Comfortable temperature",
                    0)

        case 33..<38:
            return (.moderate,
                    "Hot weather may affect breathing",
                    8)

        default:
            return (.high,
                    "Extreme temperature risk",
                    15)
        }
    }



    // MARK: Wind Speed

    private static func evaluateWind(
        _ speed: Double
    ) -> (TriggerLevel, String, Int) {


        switch speed {

        case 0..<15:
            return (
                .low,
                "Calm wind — minimal impact",
                1
            )
        case 15..<30:
            return (
                .moderate,
                "Wind may carry irritants",
                8
            )

        default:
            return (
                .high,
                "Strong wind — higher asthma trigger risk",
                15
            )
        }
    }
}
