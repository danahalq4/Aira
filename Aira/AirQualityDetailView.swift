//
//  AirQualityDetailView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 17/05/2026.
//


import SwiftUI

// MARK: - Air Quality Detail View

struct AirQualityDetailView: View {
    let triggers: [AsthmaTrigger]
    let score: Double

    // Loss per trigger — swap for real API values later
    private func loss(for trigger: AsthmaTrigger) -> Int {
        switch trigger.level {
        case .high:     return 15
        case .moderate: return 10
        case .low:      return trigger.name == "Pollen" ? 3 : 2
        }
    }

    private func color(for index: Int) -> Color {
        switch index {
        case 0: return Color("ColorR")
        case 1: return Color("ColorB")
        case 2: return Color("ColorG")
        case 3: return Color("ColorY")
        default: return Color("text")
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Annotated ring
                AnnotatedRingView(
                    score: score,
                    triggers: triggers,
                    lossFor: loss,
                    colorFor: color
                )
                .frame(width: 220, height: 220)
                .padding(.top, 24)

                Text("Each colored gap shows what's pulling your score down")
                    .font(.system(size: 13))
                    .foregroundColor(Color("small text"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Legend rows using your existing trigger data + colors
                VStack(spacing: 10) {
                    ForEach(Array(triggers.enumerated()), id: \.element.id) { index, trigger in
                        HStack(spacing: 12) {
                            Image(systemName: trigger.icon)
                                .foregroundColor(color(for: index))
                                .frame(width: 22)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(trigger.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color("text"))
                                Text(reasonText(for: trigger))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("small text"))
                            }

                            Spacer()

                            Text("−\(loss(for: trigger))%")
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

    private func reasonText(for trigger: AsthmaTrigger) -> String {
        switch trigger.level {
        case .high:     return "High levels — can irritate airways"
        case .moderate: return "Slightly elevated — worth monitoring"
        case .low:      return "Low — not a concern today"
        }
    }
}

// MARK: - Annotated Ring

private struct AnnotatedRingView: View {
    let score: Double
    let triggers: [AsthmaTrigger]
    let lossFor: (AsthmaTrigger) -> Int
    let colorFor: (Int) -> Color

    private let lineWidth: CGFloat = 22

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color("small text").opacity(0.15), lineWidth: lineWidth)

            // Blue = good score
            Circle()
                .trim(from: 0, to: score / 100)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                .rotationEffect(.degrees(-90))

            // Colored loss segments
            ForEach(Array(triggers.enumerated()), id: \.element.id) { index, trigger in
                let start = segmentStart(upTo: index)
                let end = start + Double(lossFor(trigger)) / 100

                Circle()
                    .trim(from: start, to: end)
                    .stroke(colorFor(index), style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }

            // Center label
            VStack(spacing: 4) {
                Text("\(Int(score))%")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color("text"))
                Text("Good")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("small text"))
            }
        }
    }

    private func segmentStart(upTo index: Int) -> Double {
        let base = score / 100
        let prior = triggers.prefix(index).reduce(0) { $0 + lossFor($1) }
        return base + Double(prior) / 100
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AirQualityDetailView(
            triggers: [
                AsthmaTrigger(name: "Temperature", icon: "thermometer.medium", level: .high),
                AsthmaTrigger(name: "Humidity",    icon: "drop.fill",          level: .moderate),
                AsthmaTrigger(name: "Pollen",      icon: "leaf.fill",          level: .low),
                AsthmaTrigger(name: "Dust",        icon: "aqi.low",            level: .low)
            ],
            score: 70
        )
    }
}