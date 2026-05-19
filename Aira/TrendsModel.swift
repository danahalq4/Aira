//
//  TrendsViewModel.swift
//  Aira
//
//  MVVM ViewModel for the My Trends screen.
//  Computes a daily "severity score" from the symptoms data and
//  aggregates top triggers across the selected time range.
//

import Foundation
import Combine
import SwiftUI

enum TrendPeriod: String, CaseIterable, Identifiable {
    case week = "Week"

    var id: String { rawValue }
}

struct DailySymptomData: Identifiable {
    let id = UUID()
    let day: String
    let severity: Double
    let isHighSeverity: Bool
}

struct TopTrigger: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let percentage: Double
    let iconColor: Color
}
