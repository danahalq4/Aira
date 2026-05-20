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

    // Highest pollen value

    var dominant: Int {
        max(grassPollen, treePollen, weedPollen)
    }

    // Convert raw count → TriggerLevel

    var level: TriggerLevel {

        switch dominant {

        case 0...20:
            return .low

        case 21...80:
            return .moderate

        default:
            return .high
        }
    }

    // Human-readable string

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

        // MARK: RAW RESPONSE

        print(
            "🌼 RAW RESPONSE:",
            String(data: data, encoding: .utf8) ?? "NO DATA"
        )

        // MARK: STATUS CODE

        if let http = response as? HTTPURLResponse {

            print("🌼 STATUS CODE:", http.statusCode)

            guard (200...299).contains(http.statusCode) else {

                print("❌ AMBEE HTTP ERROR")

                throw URLError(.badServerResponse)
            }
        }

        // MARK: DECODE

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

        print("🌼 FINAL POLLEN:", pollen.dominant)

        return pollen
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
