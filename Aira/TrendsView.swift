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
                    Text("My")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color("text"))
                    Text("Trends")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("small text"))
                }
                .padding(.top, 16)

                periodPicker

                symptomsCard

                topTriggersCard

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

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

    // MARK: - Symptoms Card

    private var symptomsCard: some View {
        VStack(alignment: .leading, spacing: 24) {

            HStack {
                // ── Card Title (matches "Asthma Risk" / "Today's Triggers") ──
                Text("Symptoms")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("text"))

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color("ColorB"))
                        .frame(width: 8, height: 8)
                    Text("SYM")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color("small text"))
                }
            }

            HStack(alignment: .bottom, spacing: 17) {
                ForEach(viewModel.weeklyData) { item in
                    VStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(item.isHighSeverity ? Color("ColorR") : Color("ColorB"))
                            .frame(width: 28, height: max(5, item.severity * 145))
                            .opacity(item.severity <= 0.05 ? 0.25 : 1)

                        // ── Day labels ──
                        Text(item.day)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color("small text"))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 165)
        }
        .padding(20)
        .background(Color("card"))
        .cornerRadius(20)
    }

    // MARK: - Top Triggers Card

    private var topTriggersCard: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("text"))
                // ── Card Title ──
                Text("Top Triggers")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("text"))

                Spacer()

                Image(systemName: "chevron.up")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("small text"))
            }

            VStack(spacing: 12) {
                ForEach(viewModel.topTriggers) { trigger in
                    triggerRow(trigger)
                }
            }
        }
        .padding(20)
        .background(Color("card"))
        .cornerRadius(20)
    }

    private func triggerRow(_ trigger: TopTrigger) -> some View {
        HStack(spacing: 12) {
            // تمت إزالة الأيقونة اليسار
            // Image(systemName: trigger.icon)
            //     .font(.system(size: 16, weight: .medium))
            //     .foregroundColor(trigger.iconColor)
            //     .frame(width: 22)

            // ── Row text (matches "Temprature", "Humidity") ──
            Text(trigger.title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color("text"))
                .frame(width: 115, alignment: .leading)

            ProgressView(value: trigger.percentage)
                .tint(Color("ColorB"))
                .frame(height: 8)

            // ── Value (matches "High", "Moderate") ──
            Text("\(Int(trigger.percentage * 100))%")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("text"))
                .frame(width: 42, alignment: .trailing)
        }
    }
}

#Preview {
    TrendsView()
}
