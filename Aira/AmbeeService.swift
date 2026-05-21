//
//  AmbeeService.swift
//  Aira
//

import Foundation
import CoreLocation

struct PollenData {

    let grassPollen: Int
    let treePollen: Int
    let weedPollen: Int

    // Dominant = أعلى قيمة بين الأنواع الثلاثة (الأخطر للربو)
    var dominant: Int {
        max(grassPollen, treePollen, weedPollen)
    }

    // Risk level بناءً على dominant
    var level: TriggerLevel {
        switch dominant {
        case 0...20:
            return .low
        case 21...60:
            return .moderate
        default:
            return .high
        }
    }

    // Display text
    var displayValue: String {
        "\(dominant) gr/m³"
    }
}

final class AmbeeService {

    static let shared = AmbeeService()

    private let apiKey =
    "66ace5938b3431834d9944765fe84efb9397c3a26a5a86e7df044ffe40bdac28"

    private init() {}

    func fetch(for location: CLLocation) async throws -> PollenData {

        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude

        print("📍 POLLEN LOCATION:", lat, lng)

        let urlStr =
        "https://api.ambeedata.com/latest/pollen/by-lat-lng?lat=\(lat)&lng=\(lng)"

        print("🌼 AMBEE URL:", urlStr)

        guard let url = URL(string: urlStr) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            apiKey,
            forHTTPHeaderField: "x-api-key"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let (data, response) =
        try await URLSession.shared.data(for: request)
        

        // RAW RESPONSE

        print(
            "🌼 RAW RESPONSE:",
            String(data: data, encoding: .utf8) ?? "NO DATA"
        )

        // STATUS CODE

        if let http = response as? HTTPURLResponse {

            print("🌼 STATUS CODE:", http.statusCode)

            guard (200...299).contains(http.statusCode) else {

                print("❌ AMBEE HTTP ERROR")

                throw URLError(.badServerResponse)
            }
        }

        // DECODE

        let decoded =
        try JSONDecoder().decode(
            AmbeeResponse.self,
            from: data
        )

        print("✅ AMBEE DECODED:", decoded)

        guard let first = decoded.data.first else {

            print("❌ AMBEE EMPTY DATA")

            throw URLError(.cannotParseResponse)
        }

        let pollen = PollenData(

            grassPollen: first.Count.grass_pollen,
            treePollen: first.Count.tree_pollen,
            weedPollen: first.Count.weed_pollen
        )

        print("🌼 GRASS:", pollen.grassPollen)
        print("🌼 TREE:", pollen.treePollen)
        print("🌼 WEED:", pollen.weedPollen)

        print("🌼 FINAL POLLEN:", pollen.dominant)

        return pollen
    }

    // MARK: - AQI (Ambee)

    func fetchAQI(for location: CLLocation) async throws -> AQIData {
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let urlStr = "https://api.ambeedata.com/latest/by-lat-lng?lat=\(lat)&lng=\(lng)"
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: data, encoding: .utf8) ?? ""
                print("❌ Ambee AQI HTTP \(http.statusCode):", body)
                throw URLError(.badServerResponse)
            }
        }

        let decoded = try JSONDecoder().decode(AmbeeAQIResponse.self, from: data)
        guard let first = decoded.stations.first else { throw URLError(.cannotParseResponse) }
        return AQIData(aqi: first.AQI, dominantPollutant: first.dominantPollutant ?? "—")
    }

    // MARK: - Weather (Ambee)

    func fetchWeather(for location: CLLocation) async throws -> AmbeeWeatherData {
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let urlStr = "https://api.ambeedata.com/weather/latest/by-lat-lng?lat=\(lat)&lng=\(lng)"
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: data, encoding: .utf8) ?? ""
                print("❌ Ambee Weather HTTP \(http.statusCode):", body)
                throw URLError(.badServerResponse)
            }
        }

        let decoded = try JSONDecoder().decode(AmbeeWeatherResponse.self, from: data)
        return AmbeeWeatherData(humidity: decoded.data.humidity, temperature: decoded.data.temperature)
    }
}

// MARK: - Decodable Models

private struct AmbeeResponse: Decodable {

    let data: [AmbeeItem]
}

private struct AmbeeItem: Decodable {

    let Count: PollenCount
}

private struct PollenCount: Decodable {

    let grass_pollen: Int
    let tree_pollen: Int
    let weed_pollen: Int
}

struct AQIData {
    let aqi: Double
    let dominantPollutant: String

    var level: TriggerLevel {
        switch aqi {
        case 0...50:   return .low
        case 51...150: return .moderate
        default:       return .high
        }
    }

    var displayValue: String { "AQI \(Int(aqi))" }
}

struct AmbeeWeatherData {
    let humidity: Double
    let temperature: Double

    var level: TriggerLevel {
        switch humidity {
        case 0...40:  return .low
        case 41...70: return .moderate
        default:      return .high
        }
    }

    var displayValue: String { "\(Int(humidity))% humidity" }
}

// MARK: - Ambee AQI / Weather Decodables

private struct AmbeeAQIResponse: Decodable {
    let stations: [AQIStation]
}

private struct AQIStation: Decodable {
    let AQI: Double
    let dominantPollutant: String?
}

private struct AmbeeWeatherResponse: Decodable {
    let data: WeatherPayload
}

private struct WeatherPayload: Decodable {
    let humidity: Double
    let temperature: Double
}
