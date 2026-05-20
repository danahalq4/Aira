//
//  AirQualityDetailView.swift
//  Aira
//

import SwiftUI

struct AirQualityDetailView: View {

    let riskTriggers: [RiskTrigger]
    let score: Double

    private func color(for index: Int) -> Color {
        switch index {
        case 0: return Color("ColorR")
        case 1: return Color("ColorB")
        case 2: return Color("ColorG")
        case 3: return Color("ColorY")
        default: return Color("text")
        }
    }

    // New: exclude Temperature from detail list
    private var filteredTriggers: [RiskTrigger] {
        riskTriggers.filter { $0.name != "Temperature" }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Annotated ring
                AnnotatedRingView(
                    score: score,
                    triggers: riskTriggers,
                    colorFor: color
                )
                .frame(width: 220, height: 220)
                .padding(.top, 24)

                Text("Each colored gap shows what's pulling your score down")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color("small text"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Detail rows (without Temperature)
                VStack(spacing: 10) {
                    ForEach(Array(filteredTriggers.enumerated()), id: \.offset) { index, trigger in
                        HStack(spacing: 12) {
                            Image(systemName: trigger.icon)
                                .foregroundColor(color(for: index))
                                .frame(width: 22)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 8) {
                                    Text(trigger.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color("text"))
                                    // Real value
                                    Text(trigger.displayValue)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(Color("small text"))
                                }
                                Text(trigger.reasonText)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color("small text"))
                            }

                            Spacer()

                            Text("−\(trigger.deduction)%")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(color(for: index))
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color("card"))
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color("background").ignoresSafeArea())
        .navigationTitle("Why \(Int(score))%?")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Annotated Ring

private struct AnnotatedRingView: View {
    let score: Double
    let triggers: [RiskTrigger]
    let colorFor: (Int) -> Color

    private let lineWidth: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("small text").opacity(0.15), lineWidth: lineWidth)

            // Blue = good score
            Circle()
                .trim(from: 0, to: score / 100)
                .stroke(Color.accentColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                .rotationEffect(.degrees(-90))

            // Colored loss segments
            ForEach(Array(triggers.enumerated()), id: \.offset) { index, trigger in
                let start = segmentStart(upTo: index)
                let end   = start + Double(trigger.deduction) / 100

                Circle()
                    .trim(from: start, to: end)
                    .stroke(colorFor(index),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }

            VStack(spacing: 4) {
                Text("\(Int(score))%")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color("text"))
                Text(RiskScoreEngine.scoreLabel(score))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("small text"))
            }
        }
    }

    private func segmentStart(upTo index: Int) -> Double {
        let base  = score / 100
        let prior = triggers.prefix(index).reduce(0) { $0 + $1.deduction }
        return base + Double(prior) / 100
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AirQualityDetailView(
            riskTriggers: [
                RiskTrigger(name: "Temperature", icon: "thermometer.medium",
                            level: .moderate, displayValue: "30°C",
                            deduction: 10, reasonText: "Warm — slightly elevated"),
                RiskTrigger(name: "Humidity",    icon: "drop.fill",
                            level: .low,      displayValue: "55%",
                            deduction: 2,  reasonText: "Comfortable range"),
                RiskTrigger(name: "Pollen",      icon: "leaf.fill",
                            level: .moderate, displayValue: "35 gr/m³",
                            deduction: 10, reasonText: "Moderate — limit outdoor exposure"),
                RiskTrigger(name: "Air Quality", icon: "aqi.low",
                            level: .low,      displayValue: "AQI 48",
                            deduction: 2,  reasonText: "Good air quality")
            ],
            score: 76
        )
    }
}

