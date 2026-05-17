//
//  TrendsView.swift
//  Aira
//
//  "My Trends" screen – displays a per-day severity-score bar chart
//  and a collapsible Top Triggers list.
//  Architecture: MVVM  (drives TrendsViewModel)
//


import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewModel()

    var body: some View {

        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {

                // TITLE
                Text("My Trends")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color("text"))
                    .padding(.top, 55)

                // SEGMENT
                periodPicker

                // CHART CARD
                symptomsCard

                // TRIGGERS CARD
                topTriggersCard

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - COMPONENTS
extension TrendsView {

    private var periodPicker: some View {

        HStack(spacing: 0) {

            ForEach(TrendPeriod.allCases) { period in

                Button {

                    viewModel.selectedPeriod = period

                } label: {

                    Text(period.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(
                            viewModel.selectedPeriod == period
                            ? Color("ColorB")
                            : Color("small text")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
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
        .padding(5)
        .background(Color.white)
        .clipShape(Capsule())
        .padding(.horizontal, 40)
    }

    // MARK: CHART CARD

    private var symptomsCard: some View {

        VStack(alignment: .leading, spacing: 24) {

            HStack {

                Text("Symptoms")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("text"))

                Spacer()

                HStack(spacing: 6) {

                    Circle()
                        .fill(Color("ColorB"))
                        .frame(width: 8, height: 8)

                    Text("SYM")
                        .font(.system(size: 15))
                        .foregroundColor(Color("small text"))
                }
            }

            // BARS
            HStack(alignment: .bottom, spacing: 18) {

                ForEach(viewModel.weeklyData) { item in

                    VStack(spacing: 10) {

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                item.isHighSeverity
                                ? Color("ColorR")
                                : Color("ColorB")
                            )
                            .frame(
                                width: 28,
                                height: max(5, item.severity * 145)
                            )
                            .opacity(item.severity <= 0.05 ? 0.28 : 1)

                        Text(item.day)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("small text"))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 170)
        }
        .padding(24)
        .background(Color("card"))
        .cornerRadius(28)
    }

    // MARK: TRIGGERS CARD

    private var topTriggersCard: some View {

        VStack(alignment: .leading, spacing: 22) {

            HStack {

                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("text"))

                Text("Top Triggers")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("text"))

                Spacer()

                Image(systemName: "chevron.up")
                    .foregroundColor(Color("small text"))
            }

            VStack(spacing: 22) {

                ForEach(viewModel.topTriggers) { trigger in

                    triggerRow(trigger)
                }
            }
        }
        .padding(24)
        .background(Color("card"))
        .cornerRadius(28)
    }

    // MARK: ROW

    private func triggerRow(_ trigger: TopTrigger) -> some View {

        HStack(spacing: 16) {

            Image(systemName: trigger.icon)
                .font(.system(size: 23))
                .foregroundColor(trigger.iconColor)
                .frame(width: 28)

            Text(trigger.title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("text"))
                .frame(width: 130, alignment: .leading)

            ProgressView(value: trigger.percentage)
                .tint(Color("ColorB"))
                .frame(height: 8)

            Text("\(Int(trigger.percentage * 100))%")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("text"))
                .frame(width: 50, alignment: .trailing)
        }
    }
}

#Preview {
    TrendsView()
}
