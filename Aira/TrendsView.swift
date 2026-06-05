//
//  TrendsView.swift
//  Aira
//

import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel =
    TrendsViewModel()

    var body: some View {

        VStack(spacing: 0) {

            headerView

            ScrollView(showsIndicators: false) {

                VStack(spacing: 16) {

                    asthmaScoreCard

                    topTriggersCard

                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(
            Color("background")
                .ignoresSafeArea()
        )
    }

    // MARK: - Header

    private var headerView: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text("Your Weekly Trends")
                    .font(.body)
                    .foregroundColor(
                        Color("small text")
                    )

                Text("This Week")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(
                        Color("text")
                    )
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Asthma Score Card

    private var asthmaScoreCard: some View {

        VStack(
            alignment: .leading,
            spacing: 20
        ) {

            HStack {

                Text("Asthma Score")
                    .font(.headline)
                    .foregroundColor(
                        Color("text")
                    )

                Spacer()

                Text("AVG")
                    .font(.subheadline)
                    .foregroundColor(
                        Color("small text")
                    )
            }

            HStack(
                alignment: .bottom
            ) {

                ForEach(viewModel.weeklyData) { item in

                    VStack(spacing: 8) {

                        Capsule()
                            .fill(
                                Color("ColorB")
                            )
                            .frame(
                                width: 22,
                                height:
                                    max(
                                        25,
                                        item.score * 1.2
                                    )
                            )

                        Text(item.day)
                            .font(.footnote.weight(.medium))
                            .foregroundColor(
                                Color("small text")
                            )
                    }

                    Spacer()
                }
            }
            .frame(height: 170)

        }
        .padding(20)
        .background(

            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(
                Color("card")
            )
        )
    }

    // MARK: - Top Triggers

    private var topTriggersCard: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack(spacing: 8) {

                Image(
                    systemName: "sparkles"
                )

                Text("Top Triggers")
                    .font(.headline)

            }
            .foregroundColor(
                Color("text")
            )

            ForEach(viewModel.topTriggers) { trigger in

                triggerRow(
                    trigger
                )
            }

        }
        .padding(20)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(

            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(
                Color("card")
            )
        )
    }

    // MARK: - Row

    private func triggerRow(
        _ trigger: TopTrigger
    ) -> some View {

        HStack(spacing: 12) {

            Image(
                systemName: trigger.icon
            )
            .foregroundColor(
                levelColor(
                    trigger.level
                )
            )
            .frame(width: 22)

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(trigger.title)
                    .font(.subheadline)
                    .foregroundColor(
                        Color("text")
                    )

                Text(trigger.subtitle)
                    .font(.footnote)
                    .foregroundColor(
                        Color("small text")
                    )
            }

            Spacer()

            Text(
                "\(Int(trigger.percentage * 100))%"
            )
            .font(.footnote.weight(.medium))
            .foregroundColor(
                Color("small text")
            )
        }
    }

    private func levelColor(
        _ level: TriggerLevel
    ) -> Color {

        switch level {

        case .low:

            return Color("ColorG")

        case .moderate:

            return Color("ColorY")

        case .high:

            return Color("ColorR")
        }
    }
}

#Preview {

    TrendsView()
}
