//
//  TrendsView.swift
//  Aira
//
//  Created by Danah AlQahtani on 30/11/1447 AH.
//

import Foundation

import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewModel()

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {

                Text("My Trends")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color("text"))
                    .padding(.top, 55)

                periodPicker

                symptomsCard

                topTriggersCard

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(TrendPeriod.allCases) { period in
                Button {
                    viewModel.selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(.system(size: 17, weight: .semibold))
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

    private var symptomsCard: some View {
        VStack(alignment: .leading, spacing: 24) {

            HStack {
                Text("Symptoms")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("text"))

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color("ColorB"))
                        .frame(width: 8, height: 8)

                    Text("SYM")
                        .font(.system(size: 14))
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

                        Text(item.day)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("small text"))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 165)
        }
        .padding(24)
        .background(Color("card"))
        .cornerRadius(24)
    }

    private var topTriggersCard: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("text"))

                Text("Top Triggers")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(Color("text"))

                Spacer()

                Image(systemName: "chevron.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("small text"))
            }

            VStack(spacing: 18) {
                ForEach(viewModel.topTriggers) { trigger in
                    triggerRow(trigger)
                }
            }
        }
        .padding(24)
        .background(Color("card"))
        .cornerRadius(24)
    }

    private func triggerRow(_ trigger: TopTrigger) -> some View {
        HStack(spacing: 14) {

            Image(systemName: trigger.icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(trigger.iconColor)
                .frame(width: 28)

            Text(trigger.title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color("text"))
                .frame(width: 115, alignment: .leading)

            ProgressView(value: trigger.percentage)
                .tint(Color("ColorB"))
                .frame(height: 8)

            Text("\(Int(trigger.percentage * 100))%")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color("text"))
                .frame(width: 42, alignment: .trailing)
        }
    }
}

#Preview {
    TrendsView()
}
