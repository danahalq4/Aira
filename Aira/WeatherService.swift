//
//  WeatherService.swift
//  Aira
//

import WeatherKit
import CoreLocation

struct WeatherData {

    let temperatureCelsius: Double
    let humidity: Double
    let condition: String
}

final class WeatherService {

    static let shared = WeatherService()

    private let service = WeatherKit.WeatherService.shared

    private init() {}

    func fetch(for location: CLLocation) async throws -> WeatherData {

        print("📍 WEATHER LOCATION:",
              location.coordinate.latitude,
              location.coordinate.longitude)

        let weather =
        try await service.weather(for: location)

        let current = weather.currentWeather

        let temp =
        current.temperature.converted(to: .celsius).value

        let humidity =
        current.humidity

        print("🌤 TEMP:", temp)
        print("💧 HUMIDITY:", humidity)
        print("☁️ CONDITION:", current.condition.description)

        return WeatherData(
            temperatureCelsius: temp,
            humidity: humidity,
            condition: current.condition.description
        )
    }
}
