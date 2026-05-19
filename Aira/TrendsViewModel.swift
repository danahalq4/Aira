//
//  TrendsViewModel.swift
//  Aira
//
//  Created by Danah AlQahtani on 30/11/1447 AH.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class TrendsViewModel: ObservableObject {
    
    // Input
    @Published var selectedPeriod: TrendPeriod = .week {
        didSet { recompute() }
    }
    
    // Dependencies
    private let symptomsVM: SymptomsViewModel
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    // Output
    @Published private(set) var dailyData: [DailySymptomData] = []
    
    // Existing demo data for top triggers (unchanged)
    let topTriggers: [TopTrigger] = [
        TopTrigger(icon: "lungs.fill", title: "Shortness\nof breath", percentage: 1.0, iconColor: Color("Green")),
        TopTrigger(icon: "wind", title: "Wheezing", percentage: 0.66, iconColor: .blue),
        TopTrigger(icon: "zzz", title: "Fatigue", percentage: 0.66, iconColor: .yellow)
    ]
    
    // MARK: - Init
    
    init(symptomsVM: SymptomsViewModel? = nil) {
        self.symptomsVM = symptomsVM ?? SymptomsViewModel(seed: true)
        
        // Recompute when symptoms change
        self.symptomsVM.objectWillChange
            .sink { [weak self] _ in self?.recompute() }
            .store(in: &cancellables)
        
        recompute()
    }
    
    // MARK: - Compute Daily Data
    
    private func recompute() {
        // Always compute for the current week
        let days = daysInCurrentWeek()
        let labels = labelsForWeek(days: days)
        
        var result: [DailySymptomData] = []
        for (idx, date) in days.enumerated() {
            let symptoms = symptomsVM.symptoms(on: date)
            let avg = averageSeverity(from: symptoms)
            let isHigh = avg >= 0.66
            let label = labels[idx]
            result.append(DailySymptomData(day: label, severity: avg, isHighSeverity: isHigh))
        }
        
        self.dailyData = result
    }
    
    private func labelsForWeek(days: [Date]) -> [String] {
        let fmt = DateFormatter()
        fmt.locale = .current
        fmt.dateFormat = "EEE"
        return days.map { fmt.string(from: $0).uppercased() }
    }
    
    // MARK: - Averaging
    
    private func averageSeverity(from symptoms: [Symptom]) -> Double {
        guard !symptoms.isEmpty else { return 0.0 }
        func weight(_ s: Severity) -> Double {
            switch s {
            case .mild:     return 0.0
            case .moderate: return 0.5
            case .severe:   return 1.0
            }
        }
        let sum = symptoms.reduce(0.0) { $0 + weight($1.severity) }
        return sum / Double(symptoms.count)
    }
    
    // MARK: - Calendar ranges
    
    private func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
    
    private func daysInCurrentWeek() -> [Date] {
        let now = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
        
        var days: [Date] = []
        var current = startOfDay(weekInterval.start)
        while current < weekInterval.end {
            days.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return days  // ← function ends here
    }
    
    // These are now top-level properties of the class, not inside the function
    var symptomDayCount: Int {
        dailyData.filter { $0.severity > 0.05 }.count
    }
    
    var worstDayLabel: String {
        dailyData.max(by: { $0.severity < $1.severity })?.day ?? "—"
    }
}
