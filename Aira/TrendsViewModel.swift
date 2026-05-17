//
//  TrendsViewModel.swift
//  Aira
//
//  Created by Danah AlQahtani on 30/11/1447 AH.
//

import Foundation
import SwiftUI
import Combine

final class TrendsViewModel: ObservableObject {

    @Published var selectedPeriod: TrendPeriod = .week

    let weeklyData: [DailySymptomData] = [
        DailySymptomData(day: "MON", severity: 0.04, isHighSeverity: false),
        DailySymptomData(day: "TUE", severity: 0.04, isHighSeverity: false),
        DailySymptomData(day: "WED", severity: 0.04, isHighSeverity: false),
        DailySymptomData(day: "THU", severity: 0.04, isHighSeverity: false),
        DailySymptomData(day: "FRI", severity: 0.62, isHighSeverity: false),
        DailySymptomData(day: "SAT", severity: 0.62, isHighSeverity: true),
        DailySymptomData(day: "SUN", severity: 0.46, isHighSeverity: false)
    ]

    let topTriggers: [TopTrigger] = [
        TopTrigger(icon: "lungs.fill", title: "Shortness\nof breath", percentage: 1.0, iconColor: Color("Green")),
        TopTrigger(icon: "wind", title: "Wheezing", percentage: 0.66, iconColor: .blue),
        TopTrigger(icon: "zzz", title: "Fatigue", percentage: 0.66, iconColor: .yellow)
    ]
}
