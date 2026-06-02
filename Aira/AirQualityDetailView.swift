import SwiftUI


// MARK: - Air Quality Detail View

struct AirQualityDetailView: View {

    let riskTriggers: [RiskTrigger]
    let score: Double


    private var scoringTriggers: [RiskTrigger] {

        riskTriggers
            .filter {
                $0.name == "Temperature" ||
                $0.name == "Humidity" ||
                $0.name == "Air Quality" ||
                $0.name == "Wind Speed"
            }
            .sorted {
                $0.deduction > $1.deduction
            }
    }
    private func severityColor(
        for trigger: RiskTrigger
    ) -> Color {

        switch trigger.level {

        case .high:
            return Color("ColorR")

        case .moderate:
            return Color("ColorO")

        case .low:
            return Color("ColorY")
        }
    }



    var body: some View {


        ScrollView(showsIndicators: false) {


            VStack(spacing: 20) {


                AnnotatedRingView(

                    score: score,

                    triggers: scoringTriggers,

                    colorFor: severityColor
                )

                .frame(
                    width: 220,
                    height: 220
                )

                .padding(.top, 24)



                Text(
                    "Each colored gap shows what's pulling your score down"
                )

                .font(.system(size: 13))

                .foregroundColor(
                    Color("small text")
                )

                .multilineTextAlignment(.center)

                .padding(.horizontal, 32)




                VStack(spacing: 10) {


                    ForEach(
                        scoringTriggers,
                        id: \.name
                    ) { trigger in


                        TriggerCard(

                            trigger: trigger,

                            tintColor:
                                severityColor(
                                    for: trigger
                                )
                        )
                    }
                }

                .padding(.horizontal, 16)

                .padding(.bottom, 32)
            }
        }


        .background(
            Color("background")
                .ignoresSafeArea()
        )

        .navigationTitle(
            "Why \(Int(score))%?"
        )

        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}




// MARK: - Trigger Card

private struct TriggerCard: View {


    let trigger: RiskTrigger

    let tintColor: Color



    var body: some View {


        HStack(spacing: 12) {



            Image(systemName: trigger.icon)

                .foregroundColor(
                    Color("small text")
                )

                .frame(width: 22)



            VStack(
                alignment: .leading,
                spacing: 2
            ) {


                HStack(spacing: 6) {


                    Text(trigger.name)

                        .font(
                            .system(
                                size: 15,
                                weight: .medium
                            )
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



                Text(trigger.reasonText)

                    .font(
                        .system(size: 12)
                    )

                    .foregroundColor(
                        Color("small text")
                    )
            }



            Spacer()



            Text(
                "−\(trigger.deduction)%"
            )

            .font(
                .system(
                    size: 15,
                    weight: .semibold
                )
            )

            .foregroundColor(
                tintColor
            )
        }


        .padding(14)


        .background(

            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )

            .fill(
                Color("card")
            )
        )
    }
}




// MARK: - Ring

private struct AnnotatedRingView: View {


    let score: Double

    let triggers: [RiskTrigger]

    let colorFor: (RiskTrigger) -> Color


    private let lineWidth: CGFloat = 22



    var body: some View {


        ZStack {


            Circle()

                .stroke(

                    Color("small text")
                        .opacity(0.15),

                    lineWidth: lineWidth
                )



            Circle()

                .trim(
                    from: 0,
                    to: score / 100
                )

                .stroke(

                    Color.accentColor,

                    style:
                        StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .butt
                        )
                )

                .rotationEffect(
                    .degrees(-90)
                )



            ForEach(
                Array(triggers.enumerated()),
                id: \.element.name
            ) { index, trigger in


                let start =
                segmentStart(
                    upTo: index
                )


                let end =
                start +
                Double(trigger.deduction) / 100



                Circle()

                    .trim(
                        from: start,
                        to: end
                    )

                    .stroke(

                        colorFor(trigger),

                        style:
                            StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .butt
                            )
                    )

                    .rotationEffect(
                        .degrees(-90)
                    )
            }



            VStack(spacing: 4) {


                Text("\(Int(score))%")


                    .font(
                        .system(
                            size: 38,
                            weight: .bold
                        )
                    )


                    .foregroundColor(
                        Color("text")
                    )



                Text(
                    RiskScoreEngine
                        .scoreLabel(score)
                )


                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )


                .foregroundColor(
                    Color("small text")
                )
            }
        }
    }



    private func segmentStart(
        upTo index: Int
    ) -> Double {


        let base =
        score / 100


        let prior =
        triggers
            .prefix(index)
            .reduce(0) {
                $0 + $1.deduction
            }


        return
        base +
        Double(prior) / 100
    }
}



// MARK: - Preview

#Preview {

    NavigationStack {


        AirQualityDetailView(

            riskTriggers: [


                RiskTrigger(
                    name: "Temperature",
                    icon: "thermometer.medium",
                    level: .low,
                    displayValue: "25°C",
                    deduction: 0,
                    reasonText: "Comfortable temperature"
                ),


                RiskTrigger(
                    name: "Humidity",
                    icon: "drop.fill",
                    level: .moderate,
                    displayValue: "70%",
                    deduction: 8,
                    reasonText: "High humidity"
                ),


                RiskTrigger(
                    name: "Wind Speed",
                    icon: "wind",
                    level: .high,
                    displayValue: "35 km/h",
                    deduction: 15,
                    reasonText:
                        "Strong wind — higher asthma trigger risk"
                ),


                RiskTrigger(
                    name: "Air Quality",
                    icon: "aqi.low",
                    level: .low,
                    displayValue: "AQI 20",
                    deduction: 0,
                    reasonText:
                        "Good air quality"
                )
            ],


            score: 77
        )
    }
}
