//
//  HomeViewModel.swift
//  Aira
//
//  Created by MVVM.
//

import Foundation
import SwiftUI
import Combine

struct Symptom: Identifiable, Hashable {
    let id: UUID
    var name: String
    var time: Date
    var severity: Severity
    var isTracked: Bool
    var iconSystemName: String

    init(id: UUID = UUID(), name: String, time: Date, severity: Severity, isTracked: Bool, iconSystemName: String) {
        self.id = id
        self.name = name
        self.time = time
        self.severity = severity
        self.isTracked = isTracked
        self.iconSystemName = iconSystemName
    }
}

enum Severity: String, CaseIterable, Codable {
    case mild
    case moderate
    case severe

    var colorAssetName: String {
        switch self {
        case .mild:     return "ColorG"
        case .moderate: return "ColorO"
        case .severe:   return "ColorR"
        }
    }

    var displayText: String {
        switch self {
        case .mild:     return "Mild"
        case .moderate: return "Moderate"
        case .severe:   return "Severe"
        }
    }
}

// MARK: - CalendarViewModel

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var currentMonthAnchor: Date

    private let calendar = Calendar.current

    init(selectedDate: Date = Date()) {
        self.selectedDate = calendar.startOfDay(for: selectedDate)
        self.currentMonthAnchor = calendar.date(
            from: calendar.dateComponents([.year, .month], from: selectedDate)
        ) ?? selectedDate
    }

    func daysInMonth() -> [Date] {
        guard
            let monthRange = calendar.range(of: .day, in: .month, for: currentMonthAnchor),
            let firstOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: currentMonthAnchor)
            )
        else { return [] }

        let firstWeekdayIndex = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmpty = (firstWeekdayIndex - calendar.firstWeekday + 7) % 7

        var days: [Date] = []

        if leadingEmpty > 0 {
            for offset in stride(from: leadingEmpty, to: 0, by: -1) {
                if let date = calendar.date(byAdding: .day, value: -offset, to: firstOfMonth) {
                    days.append(date)
                }
            }
        }

        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            if let last = days.last,
               let next = calendar.date(byAdding: .day, value: 1, to: last) {
                days.append(next)
            } else { break }
        }

        return days
    }

    func isSameMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonthAnchor, toGranularity: .month)
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func select(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }

    func monthTitle() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return df.string(from: currentMonthAnchor)
    }

    func weekdaySymbols() -> [String] {
        var symbols = Calendar.current.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        if first > 0 {
            symbols = Array(symbols[first...] + symbols[..<first])
        }
        return symbols
    }

    func goToPreviousMonth() {
        if let prev = calendar.date(byAdding: .month, value: -1, to: currentMonthAnchor) {
            currentMonthAnchor = prev
        }
    }

    func goToNextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: currentMonthAnchor) {
            currentMonthAnchor = next
        }
    }
}

// MARK: - SymptomsViewModel

@MainActor
final class SymptomsViewModel: ObservableObject {
    @Published private(set) var allSymptomsByDate: [Date: [Symptom]] = [:]
    private let calendar = Calendar.current

    init(seed: Bool = true) {
        if seed { seedData() }
    }

    func symptoms(on day: Date) -> [Symptom] {
        let key = calendar.startOfDay(for: day)
        return allSymptomsByDate[key] ?? []
    }

    func toggleTracked(_ symptom: Symptom, on day: Date) {
        let key = calendar.startOfDay(for: day)
        guard var list = allSymptomsByDate[key],
              let idx = list.firstIndex(of: symptom) else { return }
        list[idx].isTracked.toggle()
        allSymptomsByDate[key] = list   // ← triggers @Published
    }

    func count(on day: Date) -> Int {
        symptoms(on: day).count
    }

    // MARK: Add APIs

    func add(name: String, severity: Severity, time: Date, on day: Date) {
        let key = calendar.startOfDay(for: day)
        let icon = iconForName(name)
        var list = allSymptomsByDate[key] ?? []
        let symptom = Symptom(
            name: name,
            time: timeWithDay(time, day: key),
            severity: severity,
            isTracked: true,
            iconSystemName: icon
        )
        list.append(symptom)
        allSymptomsByDate[key] = list   // ← triggers @Published → UI يتحدث
    }

    func addMany(names: [String], severity: Severity, time: Date, on day: Date) {
        for n in names {
            add(name: n, severity: severity, time: time, on: day)
        }
    }

    // MARK: Private helpers

    private func timeWithDay(_ timeOnly: Date, day: Date) -> Date {
        let compsTime = calendar.dateComponents([.hour, .minute, .second], from: timeOnly)
        var compsDay  = calendar.dateComponents([.year, .month, .day], from: day)
        compsDay.hour   = compsTime.hour
        compsDay.minute = compsTime.minute
        compsDay.second = compsTime.second
        return calendar.date(from: compsDay) ?? day
    }

    private func iconForName(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("wheez")                          { return "wind" }
        if lower.contains("cough")                          { return "lungs" }
        if lower.contains("chest")                          { return "lungs.fill" }
        if lower.contains("shortness") || lower.contains("breath") { return "lungs.fill" }
        if lower.contains("fatigue")                        { return "zzz" }
        return "star"
    }

    private func seedData() {
        let today      = calendar.startOfDay(for: Date())
        let yesterday  = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        allSymptomsByDate[today] = [
            Symptom(name: "Wheezing", time: makeTime(hour: 17, minute: 27),
                    severity: .moderate, isTracked: true,  iconSystemName: "wind"),
            Symptom(name: "Anxiety",  time: makeTime(hour: 21, minute:  7),
                    severity: .mild,    isTracked: false, iconSystemName: "face.smiling")
        ]
        allSymptomsByDate[yesterday] = [
            Symptom(name: "Cough",               time: makeTime(hour:  9, minute: 12),
                    severity: .mild,   isTracked: true,  iconSystemName: "lungs"),
            Symptom(name: "Shortness of breath", time: makeTime(hour: 14, minute: 45),
                    severity: .severe, isTracked: true,  iconSystemName: "lungs.fill")
        ]
        allSymptomsByDate[twoDaysAgo] = [
            Symptom(name: "Fatigue", time: makeTime(hour: 19, minute: 5),
                    severity: .moderate, isTracked: false, iconSystemName: "zzz")
        ]
    }

    private func makeTime(hour: Int, minute: Int) -> Date {
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour   = hour
        comps.minute = minute
        return calendar.date(from: comps) ?? Date()
    }
}

// MARK: - HomeViewModel

@MainActor
final class HomeViewModel: ObservableObject {

    // ✅ FIX: بدّلنا @Published إلى stored + objectWillChange forwarding
    //    عشان لما symptomsVM يغيّر بياناته، HomeView يعيد الرسم تلقائياً
    let calendarVM:  CalendarViewModel
    let symptomsVM:  SymptomsViewModel

    private var cancellables = Set<AnyCancellable>()

    init(calendarVM: CalendarViewModel? = nil,
         symptomsVM: SymptomsViewModel? = nil) {

        self.calendarVM = calendarVM ?? CalendarViewModel()
        // ✅ FIX: seed: true بدل false — حتى تظهر البيانات التجريبية
        self.symptomsVM = symptomsVM ?? SymptomsViewModel(seed: true)

        // ✅ FIX: أي تغيير في الـ child ViewModels يُشعل HomeViewModel
        //    وبالتالي SwiftUI يعيد رسم HomeView وكل الـ computed properties
        self.symptomsVM.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        self.calendarVM.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var selectedDateTitle: String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("EEEE, MMM d")
        return df.string(from: calendarVM.selectedDate)
    }

    var loggedCountText: String {
        let count = symptomsVM.count(on: calendarVM.selectedDate)
        return count == 1 ? "1 symptom logged" : "\(count) symptoms logged"
    }
}
