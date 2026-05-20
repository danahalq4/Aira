//
//  WatchAsthmaScoreView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 19/05/2026.
//

//
//  WatchAsthmaScoreView.swift
//  Aira Watch App
//
//  Screen 1 — "Aisha" (Asthma Score / Air Quality)
//  Mirrors AsthmaOverviewView.swift on iPhone.
//  Shared types used: AsthmaTrigger, TriggerLevel, AsthmaOverviewViewModel
//
import SwiftUI
import Combine

#if os(watchOS)

enum TriggerLevel: String, CaseIterable, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

struct AsthmaTrigger: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var level: TriggerLevel
    var value: String
    var unit: String
}

final class AsthmaOverviewViewModel: ObservableObject {
    @Published var score: Double = 82
    @Published var animatedScore: Double = 82
    @Published var scoreLabel: String = "Good"
    @Published var triggers: [AsthmaTrigger] = [
        AsthmaTrigger(name: "Temperature", icon: "thermometer.medium", level: .high,     value: "34", unit: "°C"),
        AsthmaTrigger(name: "Humidity",    icon: "drop.fill",          level: .moderate, value: "68", unit: "%"),
        AsthmaTrigger(name: "Pollen",      icon: "leaf.fill",          level: .low,      value: "12", unit: "µg/m³"),
        AsthmaTrigger(name: "Dust",        icon: "aqi.low",            level: .low,      value: "18", unit: "µg/m³")
    ]
    @Published var hasActiveAlert: Bool = false
    @Published var inhalerReminderMessage: String = "No inhaler reminder right now."

    func onAppear() {
        // Simulate any setup/refresh work as needed for previews/testing
    }
}
#endif

struct AsthmaWatchOverviewView: View {
    @State private var showSymptomLog = false
    @ObservedObject var viewModel: AsthmaOverviewViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 17) {
                
                Text("Asthma Score")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ScoreRingWatchView(
                    score: viewModel.animatedScore,
                    label: viewModel.scoreLabel
                )
                .frame(width: 130, height: 130)
                
            
              
                
            }
        
        }
        .background(.background)
        .onAppear {
            viewModel.onAppear()
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showSymptomLog = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(.secondary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)
        }
        .sheet(isPresented: $showSymptomLog) {
            WatchSymptomsView()
        } }

}

// MARK: - Score Ring

private struct ScoreRingWatchView: View {
    let score: Double
    let label: String

    private var progress: Double {
        score / 100
    }

    private var ringColor: Color {
        switch score {
        case 70...: return .blue
        case 40..<70: return .yellow
        default: return .red
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.25), lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.2), value: progress)

            VStack(spacing: 4) {
                Text("\(Int(score))%")
                    .font(.system(size: 34, weight: .bold))

                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AsthmaWatchOverviewView(viewModel: AsthmaOverviewViewModel())
}
