//
//  AirVisualService.swift
//  Aira
//

import Foundation
import CoreLocation

struct AirQualityData {
    let aqi: Int              // US AQI
    let mainPollutant: String // e.g. "p2" = PM2.5

    var level: TriggerLevel {
        switch aqi {
        case 0...50:   return .low
        case 51...150: return .moderate
        default:       return .high
        }
    }

    var displayValue: String { "AQI \(aqi)" }
}

final class AirVisualService {


    static let shared = AirVisualService()


    private init() {}



    private var apiKey: String {

        Bundle.main.object(
            forInfoDictionaryKey: "AIRVISUAL_API_KEY"
        ) as? String ?? ""
    }

    func fetch(for location: CLLocation) async throws -> AirQualityData {
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let urlStr = "https://api.airvisual.com/v2/nearest_city?lat=\(lat)&lon=\(lng)&key=\(apiKey)"

        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? ""
                print("AirVisual HTTP \(http.statusCode):", body)
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(IQAirResponse.self, from: data)

            let pollution = decoded.data.current.pollution
            return AirQualityData(
                aqi: pollution.aqius,
                mainPollutant: pollution.mainus
            )
        } catch {
            print("AirVisual error:", error.localizedDescription)
            throw error
        }
    }
}

// MARK: - Decodable Models

private struct IQAirResponse: Decodable {
    let data: IQAirData
}

private struct IQAirData: Decodable {
    let current: IQAirCurrent
}

private struct IQAirCurrent: Decodable {
    let pollution: IQAirPollution
}

private struct IQAirPollution: Decodable {
    let aqius: Int
    let mainus: String
}
