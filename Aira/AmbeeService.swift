//
//  AmbeeService.swift
//  Aira
//

import Foundation
import CoreLocation


// MARK: - AQI

struct AQIData {

    let aqi: Double
    let level: TriggerLevel

    var displayValue: String {
        "AQI \(Int(aqi))"
    }
}


// MARK: - Pollen App Data

struct PollenData {

    let treeRisk: String
    let grassRisk: String
    let weedRisk: String

    let treeCount: Double
    let grassCount: Double
    let weedCount: Double
}


// MARK: - Pollen API V3 Response

struct PollenResponse: Codable {

    let data: [PollenItem]
}


struct PollenItem: Codable {

    let risk: PollenRisk?
    let count: PollenCount?

    enum CodingKeys: String, CodingKey {
        case risk = "Risk"
        case count = "Count"
    }
}


struct PollenRisk: Codable {

    let tree_pollen: String?
    let grass_pollen: String?
    let weed_pollen: String?
}


struct PollenCount: Codable {

    let tree_pollen: Double?
    let grass_pollen: Double?
    let weed_pollen: Double?
}



// MARK: - AQI Response

struct AQIResponse: Codable {

    let stations: [AQIStation]
}


struct AQIStation: Codable {

    let AQI: Int?
}



// MARK: - Ambee Service

final class AmbeeService {


    static let shared = AmbeeService()

    private init() {}


    private let apiKey =
    "66ace5938b3431834d9944765fe84efb9397c3a26a5a86e7df044ffe40bdac28"



    // MARK: - Fetch Pollen

    func fetch(
        for location: CLLocation
    ) async throws -> PollenData {


        let lat =
        location.coordinate.latitude


        let lng =
        location.coordinate.longitude



        let urlString =
        "https://api.ambeedata.com/v3/pollen/latest?lat=\(lat)&lng=\(lng)"



        guard let url =
                URL(string: urlString)

        else {

            throw URLError(.badURL)
        }



        var request =
        URLRequest(url: url)



        request.addValue(
            apiKey,
            forHTTPHeaderField: "x-api-key"
        )



        let (data, _) =
        try await URLSession.shared.data(
            for: request
        )



        print(
            String(
                data: data,
                encoding: .utf8
            ) ?? ""
        )



        let decoded =
        try JSONDecoder()
            .decode(
                PollenResponse.self,
                from: data
            )



        guard let pollen =
                decoded.data.first

        else {

            throw URLError(.badServerResponse)
        }



        return PollenData(


            treeRisk:
                pollen.risk?.tree_pollen ?? "Low",


            grassRisk:
                pollen.risk?.grass_pollen ?? "Low",


            weedRisk:
                pollen.risk?.weed_pollen ?? "Low",



            treeCount:
                pollen.count?.tree_pollen ?? 0,


            grassCount:
                pollen.count?.grass_pollen ?? 0,


            weedCount:
                pollen.count?.weed_pollen ?? 0
        )
    }




    // MARK: - Fetch AQI

    func fetchAQI(
        for location: CLLocation
    ) async throws -> AQIData {


        let lat =
        location.coordinate.latitude


        let lng =
        location.coordinate.longitude



        let urlString =
        "https://api.ambeedata.com/latest/by-lat-lng?lat=\(lat)&lng=\(lng)"



        guard let url =
                URL(string: urlString)

        else {

            throw URLError(.badURL)
        }



        var request =
        URLRequest(url: url)



        request.addValue(
            apiKey,
            forHTTPHeaderField: "x-api-key"
        )



        let (data, _) =
        try await URLSession.shared.data(
            for: request
        )



        let decoded =
        try JSONDecoder()
            .decode(
                AQIResponse.self,
                from: data
            )



        let value =
        decoded.stations.first?.AQI ?? 0



        let level: TriggerLevel


        switch value {

        case 0...50:

            level = .low


        case 51...100:

            level = .moderate


        default:

            level = .high
        }



        return AQIData(
            aqi: Double(value),
            level: level
        )
    }
}
