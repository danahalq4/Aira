//
//  AsthmaOverviewViewModel.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 11/05/2026.
//



import SwiftUI
import Combine

final class AsthmaOverviewViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var score: Double = 0
    @Published private(set) var animatedScore: Double = 0
    @Published private(set) var scoreLabel: String = ""
    @Published private(set) var airQualityMessage: String = ""
    @Published private(set) var triggers: [AsthmaTrigger] = []
    @Published private(set) var inhalerReminderMessage: String = ""
    @Published private(set) var hasUnreadNotifications: Bool = true

    // MARK: - Init

    init() {
        loadData()
    }

    // MARK: - Intents

    func onAppear() {
        withAnimation(.easeOut(duration: 1.2)) {
            animatedScore = score
        }
    }

    func notificationTapped() {
        hasUnreadNotifications = false
    }

    func inhalerReminderTapped() {
        // Navigate or log — wire to coordinator in a real app
        print("Inhaler reminder tapped")
    }

    @Published var showAirDetail: Bool = false

    func airQualityTapped() {
        showAirDetail = true
    }
    
    // MARK: - Private

    private func loadData() {
        // Replace with async repository / use-case call in production
        let data = AsthmaOverviewData(
            score: 70,
            scoreLabel: "Good",
            airQualityMessage: "Why is the asthma risk good?",
            triggers: [
                AsthmaTrigger(name: "Temprature", icon: "thermometer.medium",   level: .high),
                AsthmaTrigger(name: "Humidity", icon: "drop.fill",   level: .moderate),
                AsthmaTrigger(name: "Pollen",   icon: "leaf.fill",   level: .low),
                AsthmaTrigger(name: "Dust",     icon: "aqi.low",     level: .low)
            ],
            inhalerReminderMessage: "Use your inhaler as prescribed"
        )
        apply(data)
    }

    private func apply(_ data: AsthmaOverviewData) {
        score                  = data.score
        scoreLabel             = data.scoreLabel
        airQualityMessage      = data.airQualityMessage
        triggers               = data.triggers
        inhalerReminderMessage = data.inhalerReminderMessage
    }
}
