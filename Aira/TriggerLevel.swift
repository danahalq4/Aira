//
//  TriggerLevel.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 11/05/2026.
//

import Foundation

// MARK: - Trigger Level

enum TriggerLevel: String {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

// MARK: - Asthma Trigger

struct AsthmaTrigger: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let level: TriggerLevel
    let displayValue: String   // e.g., "32°C", "55%", "AQI 48"
}

// MARK: - Asthma Overview Data

struct AsthmaOverviewData {
    var score: Double
    var scoreLabel: String
    var airQualityMessage: String
    var triggers: [AsthmaTrigger]
    var inhalerReminderMessage: String
    var hasActiveAlert: Bool
}

