//
//  TrendsModels.swift
//  Aira
//
//  Shared models for Trends screen.
//  Replaces the old struct definitions split across two files.
//

import Foundation
import SwiftUI

// MARK: - Period

enum TrendPeriod: String, CaseIterable, Identifiable {
    case week        = "Week"
    case month       = "Month"
    case threeMonths = "3 Mo"
    var id: String { rawValue }
}

// MARK: - Bar chart data

struct DailySymptomData: Identifiable {
    let id        = UUID()
    let day:      String
    let severity: Double
    let isHighSeverity: Bool
}

// MARK: - Top trigger row

struct TopTrigger: Identifiable {
    let id       = UUID()
    let icon:     String
    let title:    String
    let subtitle: String        // e.g. "6.2 hrs last night", "72 bpm"
    let percentage: Double      // 0–1 for progress bar
    let iconColor: Color
    let level:    TriggerLevel  // Low / Moderate / High
}
