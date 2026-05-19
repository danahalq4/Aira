//
//  TrendsView.swift
//  Aira
//

import SwiftUI

struct TrendsView: View {
    @StateObject private var viewModel = TrendsViewModel()

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {

                // ── Page Header (matches "Asthma / Overview") ──
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Weekly Trends")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color("text"))
                    Text("This Week")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("small text"))
                }
                .padding(.top, 16)

                symptomsCard
                topTriggersCard
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Symptoms Card

    // MARK: - Symptoms Card

    private var symptomsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                // ── Card Title (matches "Asthma Risk" / "Today's Triggers") ──
                Text("Symptoms")
                    .font(.system(size: 16, weight: .semibold))
    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(TrendPeriod.allCases) { period in
                Button {
                    viewModel.selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(
                            viewModel.selectedPeriod == period
                            ? Color("ColorB")
                            : Color("small text")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            Capsule()
                                .fill(
                                    viewModel.selectedPeriod == period
                                    ? Color("ColorB").opacity(0.15)
                                    : Color.clear
                                )
                        )
                }
            }
        }
        .padding(4)
        .background(Color("card"))
        .clipShape(Capsule())
        .padding(.horizontal, 48)
    }
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
                HStack(spacing: 5) {
                    Circle().fill(Color("ColorB")).frame(width: 8, height: 8)
                    Text("Severity")
                        .font(.system(size: 13))
                            .opacity(item.severity <= 0.05 ? 0.25 : 1)

                        // ── Day labels ──
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
                            .font(.system(size: 13, weight: .regular))
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
        .padding(20)
                .font(.system(size: 12))
        .cornerRadius(20)
    }
                Text("Top Triggers")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("text"))
                Spacer()
        VStack(alignment: .leading, spacing: 14) {

            HStack(spacing: 8) {
                    .foregroundColor(Color("ColorB"))
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.vertical, 5)
                // ── Card Title ──
                    .clipShape(Capsule())
                    .font(.system(size: 16, weight: .semibold))

            VStack(spacing: 16) {

                Image(systemName: "chevron.up")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("small text"))
        .cornerRadius(22)
    }
            VStack(spacing: 12) {
    private func triggerRow(_ trigger: TopTrigger) -> some View {
        HStack(spacing: 12) {
            Image(systemName: trigger.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(trigger.iconColor)
        .padding(20)

        .cornerRadius(20)
            Text(trigger.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("text"))
                .frame(minWidth: 100, alignment: .leading)
            // تمت إزالة الأيقونة اليسار
            // Image(systemName: trigger.icon)
            //     .font(.system(size: 16, weight: .medium))
            //     .foregroundColor(trigger.iconColor)
            //     .frame(width: 22)

            // ── Value (matches "High", "Moderate") ──
            Text("\(Int(trigger.percentage * 100))%")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color("text"))
                .frame(width: 115, alignment: .leading)
        }
    }

    // MARK: - Severity Color

            // ── Value (matches "High", "Moderate") ──
        switch max(0, min(1, severity)) {
                .font(.system(size: 15, weight: .medium))
        case 0.33..<0.66: return Color("ColorO")
                .frame(width: 42, alignment: .trailing)
        default: return Color("ColorR")
        }
    }
}

#Preview {
    TrendsView()
}
