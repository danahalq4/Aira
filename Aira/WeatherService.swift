//
//  WeatherService.swift
//  Aira
//

import Foundation
import CoreLocation

struct WeatherData: Codable {

    let temperature_2m: Double
    let relative_humidity_2m: Int
}

struct OpenMeteoResponse: Codable {

    let current: WeatherData
}

final class WeatherService {

    static let shared = WeatherService()

    private init() {}

    func fetch(for location: CLLocation) async throws -> WeatherData {

        print("📍 WEATHER LOCATION:",
              location.coordinate.latitude,
              location.coordinate.longitude)

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        let urlString =
        "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoded =
        try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

        print("🌤 TEMP:", decoded.current.temperature_2m)
        print("💧 HUMIDITY:", decoded.current.relative_humidity_2m)

        return decoded.current
    }
}
