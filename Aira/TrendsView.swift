//
//  TrendsView.swift
//  Aira
//
//  Created by Danah AlQahtani on 30/11/1447 AH.
//
import SwiftUI
import SwiftUI

struct TrendsView: View {
    @StateObject private var viewModel = TrendsViewModel()

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Weekly Trends")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("small text"))
                    Text("This Week")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color("text"))
                }
                .padding(.top, 55)

                symptomsCard
                topTriggersCard
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Symptoms Card

    private var symptomsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Symptoms")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("text"))
                Spacer()
                HStack(spacing: 5) {
                    Circle().fill(Color("ColorB")).frame(width: 8, height: 8)
                    Text("Severity")
                        .font(.system(size: 13))
                        .foregroundColor(Color("small text"))
                }
            }

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(viewModel.dailyData) { item in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(color(forSeverity: item.severity))
                            .frame(width: 28, height: max(5, item.severity * 130))
                            .opacity(item.severity <= 0.05 ? 0.25 : 1)
                        Text(item.day)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color("small text"))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 155)

            Divider()
            HStack(spacing: 14) {
                legendItem(color: Color("ColorB"), label: "Low")
                legendItem(color: Color("ColorO"), label: "Medium")
                legendItem(color: Color("ColorR"), label: "High")
            }
        }
        .padding(22)
        .background(Color("card"))
        .cornerRadius(22)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color("small text"))
        }
    }

    // MARK: - Top Triggers Card

    private var topTriggersCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color("text"))
                Text("Top Triggers")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("text"))
                Spacer()
                Text("This week")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorB"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("ColorB").opacity(0.12))
                    .clipShape(Capsule())
            }

            VStack(spacing: 16) {
                ForEach(viewModel.topTriggers) { trigger in
                    triggerRow(trigger)
                }
            }
        }
        .padding(22)
        .background(Color("card"))
        .cornerRadius(22)
    }

    private func triggerRow(_ trigger: TopTrigger) -> some View {
        HStack(spacing: 12) {
            Image(systemName: trigger.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(trigger.iconColor)
                .frame(width: 26)

            Text(trigger.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("text"))
                .frame(minWidth: 100, alignment: .leading)

            ProgressView(value: trigger.percentage)
                .tint(Color("ColorB"))
                .frame(height: 6)

            Text("\(Int(trigger.percentage * 100))%")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("text"))
                .frame(width: 40, alignment: .trailing)
        }
    }

    // MARK: - Severity Color

    private func color(forSeverity severity: Double) -> Color {
        switch max(0, min(1, severity)) {
        case 0.0..<0.33: return Color("ColorB")
        case 0.33..<0.66: return Color("ColorO")
        default: return Color("ColorR")
        }
    }
}

#Preview {
    TrendsView()
}
