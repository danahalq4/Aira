//
//  AsthmaOverviewView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 11/05/2026.
//

import SwiftUI


// MARK: - Root View

struct AsthmaOverviewView: View {


    @StateObject private var viewModel =
    AsthmaOverviewViewModel()



    var body: some View {


        NavigationStack {


            VStack(spacing: 0) {


                headerView



                ScrollView(showsIndicators: false) {


                    VStack(spacing: 16) {


                        if viewModel.hasActiveAlert {


                            inhalerReminderCard
                        }



                        asthmaScoreCard


                        todayTriggersCard
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


            .onAppear {

                viewModel.onAppear()
            }



            .navigationDestination(
                isPresented: $viewModel.showAirDetail
            ) {


                AirQualityDetailView(

                    riskTriggers:
                        viewModel.riskTriggers,

                    score:
                        viewModel.score
                )
            }



            .navigationDestination(
                isPresented: $viewModel.showAlert
            ) {


                ALERT(

                    riskResult:

                        RiskResult(

                            score:
                                viewModel.score,


                            label:
                                viewModel.scoreLabel,


                            triggers:
                                viewModel.riskTriggers
                        )
                )
            }
        }
    }






    // MARK: - Header


    private var headerView: some View {


        HStack {


            VStack(
                alignment: .leading,
                spacing: 2
            ) {


                Text("Asthma")
                    .font(
                        .system(
                            size: 28,
                            weight: .bold
                        )
                    )
                    .foregroundColor(
                        Color("text")
                    )


                Text("Overview")
                    .font(
                        .system(
                            size: 16
                        )
                    )
                    .foregroundColor(
                        Color("small text")
                    )
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


                Text("Asthma Risk")
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(
                        Color("text")
                    )


                Spacer()
            }



            ScoreRingView(

                score:
                    viewModel.animatedScore,

                label:
                    viewModel.scoreLabel
            )
            .frame(
                width: 160,
                height: 160
            )



            Divider()



            Button(
                action:
                    viewModel.airQualityTapped
            ) {


                HStack(spacing: 10) {


                    Image(systemName: "wind")
                        .foregroundColor(
                            Color("ColorB")
                        )


                    Text(
                        viewModel.airQualityMessage
                    )
                    .font(.system(size: 14))
                    .foregroundColor(
                        Color("text")
                    )



                    Spacer()



                    Image(systemName: "chevron.right")
                        .foregroundColor(
                            Color("small text")
                        )
                }
            }
        }
        .padding(20)
        .background(

            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(Color("card"))
        )
    }









    // MARK: - Triggers Card


    private var todayTriggersCard: some View {


        VStack(
            alignment: .leading,
            spacing: 14
        ) {


            Text("Today's Triggers")
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
                .foregroundColor(
                    Color("text")
                )



            ForEach(
                Array(viewModel.triggers.enumerated()),
                id: \.element.id
            ) { index, trigger in


                TriggerRowView(

                    trigger: trigger,

                    index: index
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
            .fill(Color("card"))
        )
    }










    // MARK: - Inhaler Card


    private var inhalerReminderCard: some View {


        Button(
            action:
                viewModel.inhalerReminderTapped
        ) {


            HStack(spacing: 16) {


                Image(systemName: "inhaler")
                    .font(.system(size: 32))
                    .foregroundColor(
                        Color("ColorB")
                    )
                    .frame(width: 44)



                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {


                    Text("Inhaler Reminder")
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )


                    Text(
                        viewModel.inhalerReminderMessage
                    )
                    .font(.system(size: 13))
                    .foregroundColor(
                        Color("small text")
                    )
                }



                Spacer()



                Image(systemName: "chevron.right")
                    .foregroundColor(
                        Color("small text")
                    )
            }
            .padding(20)
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )
        }
        .buttonStyle(.plain)
    }
}










// MARK: - Score Ring


private struct ScoreRingView: View {


    let score: Double

    let label: String



    private var progress: Double {

        score / 100
    }



    var body: some View {


        ZStack {


            Circle()
                .stroke(
                    Color("small text")
                        .opacity(0.2),
                    lineWidth: 14
                )



            Circle()
                .trim(
                    from: 0,
                    to: progress
                )
                .stroke(
                    Color.accentColor,
                    style:
                        StrokeStyle(
                            lineWidth: 14,
                            lineCap: .round
                        )
                )
                .rotationEffect(
                    .degrees(-90)
                )



            VStack(spacing: 4) {


                Text("\(Int(score))%")
                    .font(
                        .system(
                            size: 34,
                            weight: .bold
                        )
                    )


                Text(LocalizedStringKey(label))
                    .font(
                        .system(size: 15)
                    )
                    .foregroundColor(
                        Color("small text")
                    )
            }
        }
    }
}










// MARK: - Trigger Row

private struct TriggerRowView: View {

    let trigger: AsthmaTrigger
    let index: Int


    private var levelColor: Color {

        switch trigger.level {

        case .low:
            return Color("ColorG")

        case .moderate:
            return Color("ColorY")

        case .high:
            return Color("ColorR")
        }
    }


    var body: some View {

        HStack(spacing: 12) {


            Image(systemName: trigger.icon)
                .foregroundColor(levelColor)
                .frame(width: 22)


            VStack(
                alignment: .leading,
                spacing: 4
            ) {


                Text(LocalizedStringKey(trigger.name))
                    .font(.system(size: 15))
                    .foregroundColor(Color("text"))


                Text(LocalizedStringKey(trigger.displayValue))
                    .font(.system(size: 13))
                    .foregroundColor(
                        Color("small text")
                    )
            }


            Spacer()
        }
    }
}


#Preview {

    AsthmaOverviewView()
}
