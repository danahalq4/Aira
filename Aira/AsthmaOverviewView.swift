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
        .background(Color("background").ignoresSafeArea())
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Asthma")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("text"))
                Text("Overview")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color("small text"))
            }
            Spacer()
            
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
                    .foregroundColor(Color("text"))
                Spacer()
              
            }

            ScoreRingView(
                score: viewModel.animatedScore,
                label: viewModel.scoreLabel
            )
            .frame(width: 160, height: 160)

            Divider()
                .background(Color("small text").opacity(0.2))

            Button(action: viewModel.airQualityTapped) {
                HStack(spacing: 10) {
                    Image(systemName: "wind")
                        .foregroundColor(Color("ColorB")) // wind باللون الأزرق
                    Text(viewModel.airQualityMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Color("text"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("small text"))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("card"))
        )
    }

    // MARK: - Triggers Card

    private var todayTriggersCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Triggers")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("text"))

            ForEach(Array(viewModel.triggers.enumerated()), id: \.element.id) { index, trigger in
                TriggerRowView(trigger: trigger, index: index)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("card"))
        )
    }

    // MARK: - Inhaler Reminder Card

    private var inhalerReminderCard: some View {
        Button(action: viewModel.inhalerReminderTapped) {
            HStack(spacing: 16) {
                Image(systemName: "inhaler")
                    .font(.system(size: 32))
                    .foregroundColor(Color("ColorB")) // البخاخ باللون الأزرق
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Inhaler Reminder")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("text"))
                    Text(viewModel.inhalerReminderMessage)
                        .font(.system(size: 13))
                        .foregroundColor(Color("small text"))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("small text"))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("card"))
            )
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
                .stroke(Color("small text").opacity(0.2), lineWidth: 14)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.2), value: progress)

            VStack(spacing: 4) {
                Text("\(Int(score))%")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color("text"))
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("small text"))
            }
        }
    }
}

// MARK: - Trigger Row

private struct TriggerRowView: View {
    let trigger: AsthmaTrigger
    let index: Int

    // يحدد لون الأيقونة حسب الترتيب: الأول G، الثاني Y، الثالث B
    private var highlightColor: Color {
        switch index {
        case 0: return Color("ColorG") // أخضر من الـ Assets
        case 1: return Color("ColorY") // أصفر من الـ Assets
        case 2: return Color("ColorB") // أزرق من الـ Assets
        default: return Color("text")  // الافتراضي
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: trigger.icon)
                .foregroundColor(highlightColor)
                .frame(width: 22)

            Text(trigger.name)
                .font(.system(size: 15))
                .foregroundColor(Color("text"))

            Spacer()

            Text(trigger.level.rawValue)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(trigger.level == .low ? Color("ColorG") : Color("ColorY"))
        }
    }
}

// MARK: - Preview

#Preview {
    AsthmaOverviewView()
        .background(Color("background"))
}
