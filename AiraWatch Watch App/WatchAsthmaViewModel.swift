//
//  WatchAsthmaViewModel.swift
//
import SwiftUI
import Combine
import SwiftData

#if os(watchOS)

@MainActor
final class WatchAsthmaViewModel: ObservableObject {

    @Published private(set) var score: Double         = 0
    @Published private(set) var animatedScore: Double = 0
    @Published private(set) var scoreLabel: String    = "—"
    @Published private(set) var riskTriggers: [RiskTrigger] = []
    @Published private(set) var isLoading: Bool       = false

    init() {
        WatchConnectivityManager.shared.onScoreReceived = { [weak self] score, label, triggers in
            Task { @MainActor in
                self?.score = score
                self?.scoreLabel = label
                self?.riskTriggers = triggers
                self?.isLoading = false

                withAnimation(.easeOut(duration: 1.2)) {
                    self?.animatedScore = score
                }

                print("WATCH VIEWMODEL UPDATED:", score, label)
            }
        }
    }

    func onAppear() {
        print("WATCH VIEWMODEL APPEARED")
    }
}

struct AsthmaWatchRootView: View {
    @StateObject private var viewModel = WatchAsthmaViewModel()

    var body: some View {
        TabView {
            AsthmaWatchOverviewView(viewModel: viewModel)
            WatchAirDetailView(riskTriggers: viewModel.riskTriggers, score: viewModel.score)
        }
        .tabViewStyle(.page)
    }
}

struct AsthmaWatchOverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showSymptomLog = false
    @ObservedObject var viewModel: WatchAsthmaViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Text("Asthma Score")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.isLoading {
                    ProgressView()
                        .frame(width: 130, height: 130)
                } else {
                    ScoreRingWatchView(
                        score: viewModel.animatedScore,
                        label: viewModel.scoreLabel
                    )
                    .frame(width: 130, height: 130)
                }
            }
        }
        .containerBackground(for: .navigation) { Color.clear }
        .onAppear { viewModel.onAppear() }
        .overlay(alignment: .topTrailing) {
            Button {
                showSymptomLog = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.ultraThinMaterial))
                    .overlay { Circle().stroke(Color.white.opacity(0.15), lineWidth: 1) }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)
        }
        .sheet(isPresented: $showSymptomLog) {
            WatchSymptomsView { symptom, severityIndex in
                let severityLabels = ["Moderate", "Severe", "Very Severe"]
                let newLog = SymptomLog(
                    date: Date(),
                    name: symptom,
                    severityRaw: severityLabels[severityIndex]
                )
                modelContext.insert(newLog)
                try? modelContext.save()
            }
        }
    }
}

private struct ScoreRingWatchView: View {
    let score: Double
    let label: String

    private var progress: Double { score / 100 }

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
                .stroke(ringColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.2), value: progress)

            VStack(spacing: 4) {
                Text("\(Int(score))%")
                    .font(.system(size: 34, weight: .bold))
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    AsthmaWatchRootView()
}

#endif
