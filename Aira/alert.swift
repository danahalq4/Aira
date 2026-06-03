//
//  ALERT.swift
//  Aira
//

import SwiftUI


struct ALERT: View {


    let riskResult: RiskResult


    @Environment(\.dismiss)
    private var dismiss



    var body: some View {


        VStack(spacing: 0) {


            headerView


            ScrollView(showsIndicators: false) {


                VStack(spacing: 16) {


                    riskCard


                    triggersCard


                    recommendationCard
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
        .navigationBarBackButtonHidden(true)
    }






    // MARK: - Header

    private var headerView: some View {


        HStack {


            Button {

                dismiss()

            } label: {


                Image(systemName: "chevron.left")
                    .font(
                        .system(
                            size: 18,
                            weight: .medium
                        )
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








    // MARK: - Risk Card

    private var riskCard: some View {


        VStack(spacing: 14) {


            Image(
                systemName:
                    "exclamationmark.triangle.fill"
            )
            .font(.system(size: 34))
            .foregroundColor(
                alertColor
            )



            Text(alertTitle)
                .font(
                    .system(
                        size: 28,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    alertColor
                )



            Text(
                "\(Int(riskResult.score))%"
            )
            .font(
                .system(
                    size: 34,
                    weight: .bold
                )
            )
            .foregroundColor(
                Color("text")
            )



            Text(alertMessage)
                .font(.system(size: 14))
                .foregroundColor(
                    Color("small text")
                )
                .multilineTextAlignment(.center)

        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(

            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(Color("card"))
        )
    }









    // MARK: - Top Triggers


    private var triggersCard: some View {


        VStack(
            alignment: .leading,
            spacing: 14
        ) {


            Text("Top Risk Triggers")
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
                riskResult.triggers

                    // فقط اللي سبب الخطر
                    .filter {

                        $0.deduction > 0
                    }


                    // الأعلى تأثير أول
                    .sorted {

                        $0.deduction >
                        $1.deduction
                    },


                id: \.name

            ) { trigger in


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
            .fill(Color("card"))
        )
    }







    private func triggerRow(
        _ trigger: RiskTrigger
    ) -> some View {


        HStack(spacing: 12) {


            Image(
                systemName:
                    trigger.icon
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


                Text(trigger.name)
                    .font(
                        .system(size: 15)
                    )
                    .foregroundColor(
                        Color("text")
                    )



                Text(trigger.displayValue)
                    .font(
                        .system(size: 13)
                    )
                    .foregroundColor(
                        Color("small text")
                    )
            }


            Spacer()
        }
    }









    // MARK: - Recommendation


    private var recommendationCard: some View {


        HStack(spacing: 12) {


            Image(
                systemName: "inhaler"
            )
            .font(.system(size: 28))
            .foregroundColor(
                Color("ColorB")
            )



            Text(recommendation)
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundColor(
                    Color("text")
                )


            Spacer()
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









    // MARK: - Logic


    private var alertTitle: String {


        riskResult.score < 25
        ? "Critical Risk"
        : "High Risk"
    }





    private var alertColor: Color {


        riskResult.score < 25
        ? Color("ColorR")
        : Color("ColorO")
    }






    private var alertMessage: String {


        riskResult.score < 25

        ? "Multiple asthma triggers are elevated. Take precautions and monitor your symptoms closely."

        : "Your asthma risk is high due to the triggers below. Reduce exposure and monitor your symptoms."
    }







    private var highestTrigger: RiskTrigger? {


        riskResult.triggers

            .filter {

                $0.deduction > 0
            }

            .sorted {

                $0.deduction >
                $1.deduction
            }

            .first
    }







    private var recommendation: String {


        switch highestTrigger?.name {


        case "Air Quality":

            return "Avoid poor air quality exposure."


        case "Pollen":

            return "Reduce pollen exposure outdoors."


        case "Wind Speed":

            return "Limit outdoor exposure during strong winds."


        case "Humidity":

            return "Stay in balanced humidity conditions."


        case "Temperature":

            return "Avoid extreme temperature changes."


        case "Sleep":

            return "Improve your sleep routine."


        case "Heart Rate":

            return "Monitor your heart rate."


        case "Respiratory Rate":

            return "Monitor your breathing symptoms."


        default:

            return "Use your inhaler as prescribed."
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
