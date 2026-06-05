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
                    .font(
                        .largeTitle.weight(.bold)
                    )
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



            ZStack {


                // MARK: Background Lines

                VStack(spacing: 0) {


                    HStack {

                        Text("High")
                            .font(.caption2)
                            .foregroundColor(
                                Color("small text")
                            )
                            .frame(
                                width: 60,
                                alignment: .leading
                            )


                        Rectangle()
                            .fill(
                                Color("small text")
                                    .opacity(0.2)
                            )
                            .frame(height: 1)
                    }



                    Spacer()



                    HStack {

                        Text("Medium")
                            .font(.caption2)
                            .foregroundColor(
                                Color("small text")
                            )
                            .frame(
                                width: 60,
                                alignment: .leading
                            )


                        Rectangle()
                            .fill(
                                Color("small text")
                                    .opacity(0.2)
                            )
                            .frame(height: 1)
                    }



                    Spacer()



                    HStack {

                        Text("Low")
                            .font(.caption2)
                            .foregroundColor(
                                Color("small text")
                            )
                            .frame(
                                width: 60,
                                alignment: .leading
                            )


                        Rectangle()
                            .fill(
                                Color("small text")
                                    .opacity(0.2)
                            )
                            .frame(height: 1)
                    }


                    // space for days
                    Spacer()
                        .frame(height: 28)
                }



                // MARK: Real Chart

                HStack(
                    alignment: .bottom,
                    spacing: 0
                ) {


                    Spacer()
                        .frame(width: 60)



                    ForEach(
                        viewModel.weeklyData
                    ) { item in


                        VStack(spacing: 8) {


                            Spacer()



                            Capsule()
                                .fill(
                                    Color("ColorB")
                                )
                                .frame(
                                    width: 24,
                                    height: max(
                                        20,
                                        item.score * 1.4
                                    )
                                )



                            Text(item.day)
                                .font(
                                    .caption
                                        .weight(.medium)
                                )
                                .foregroundColor(
                                    Color("small text")
                                )
                                .frame(
                                    height: 20
                                )
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                }
            }
            .frame(height: 200)
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



            ForEach(
                viewModel.topTriggers
            ) { trigger in


                triggerRow(trigger)
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
            .font(
                .footnote.weight(.medium)
            )
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
