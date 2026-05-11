//
//  AsthmaOverviewView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 11/05/2026.
//




import SwiftUI

// MARK: - Root View

struct AsthmaOverviewView: View {

    @StateObject private var viewModel = AsthmaOverviewViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    asthmaScoreCard
                    todayTriggersCard
                    inhalerReminderCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Asthma")
                    .font(.system(size: 28, weight: .bold))
                Text("Overview")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: viewModel.notificationTapped) {
                Image(systemName: viewModel.hasUnreadNotifications ? "bell.badge" : "bell")
                    .font(.system(size: 22, weight: .medium))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Score Card

    private var asthmaScoreCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Asthma Score")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
            }

            ScoreRingView(
                score: viewModel.animatedScore,
                label: viewModel.scoreLabel
            )
            .frame(width: 160, height: 160)

            Divider()

            Button(action: viewModel.airQualityTapped) {
                HStack(spacing: 10) {
                    Image(systemName: "wind")
                    Text(viewModel.airQualityMessage)
                        .font(.system(size: 14))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Triggers Card

    private var todayTriggersCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Triggers")
                .font(.system(size: 16, weight: .semibold))

            ForEach(viewModel.triggers) { trigger in
                TriggerRowView(trigger: trigger)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Inhaler Reminder Card

    private var inhalerReminderCard: some View {
        Button(action: viewModel.inhalerReminderTapped) {
            HStack(spacing: 16) {
               Image(systemName: "inhaler")
                   .font(.system(size: 32))
                .foregroundStyle(.secondary)
             .frame(width: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Inhaler Reminder")
                        .font(.system(size: 15, weight: .semibold))
                    Text(viewModel.inhalerReminderMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .padding(20)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Score Ring

private struct ScoreRingView: View {
    let score: Double
    let label: String

    private var progress: Double { score / 100 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.2), lineWidth: 14)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(.primary, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.2), value: progress)

            VStack(spacing: 4) {
                Text("\(Int(score))%")
                    .font(.system(size: 34, weight: .bold))
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Trigger Row

private struct TriggerRowView: View {
    let trigger: AsthmaTrigger

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: trigger.icon)
                .frame(width: 22)

            Text(trigger.name)
                .font(.system(size: 15))

            Spacer()

            Text(trigger.level.rawValue)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(trigger.level == .low ? .primary : .secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    AsthmaOverviewView()
}
