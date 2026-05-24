//
import SwiftUI

// MARK: - Air Quality Detail View

struct AirQualityDetailView: View {

    let riskTriggers: [RiskTrigger]
    let score: Double

    // Main scoring triggers only, sorted highest deduction first
    private var scoringTriggers: [RiskTrigger] {
        riskTriggers
            .filter { trigger in
                trigger.deduction > 0 &&
                trigger.name != "Tree Pollen" &&
                trigger.name != "Weed Pollen" &&
                trigger.name != "Grass Pollen"
            }
            .sorted { $0.deduction > $1.deduction }
    }

    // Sub-pollen rows (informational, no deduction)
    private var pollenSubRows: [RiskTrigger] {
        riskTriggers.filter {
            $0.name == "Tree Pollen" ||
            $0.name == "Weed Pollen" ||
            $0.name == "Grass Pollen"
        }
        .sorted { $0.name < $1.name }
    }

    // Color by severity — used only for % numbers and ring segments
    private func severityColor(for trigger: RiskTrigger) -> Color {
        switch trigger.level {
        case .high:     return Color("ColorR")
        case .moderate: return Color("ColorO")
        case .low:      return Color("ColorY")
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
                .frame(width: 220, height: 220)
                .padding(.top, 24)

                Text("Each colored gap shows what's pulling your score down")
                    .font(.system(size: 13))
                    .foregroundColor(Color("small text"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(spacing: 10) {
                    ForEach(scoringTriggers, id: \.name) { trigger in
                        if trigger.name == "Pollen (Total)" {
                            PollenDetailCard(
                                summary: trigger,
                                subRows: pollenSubRows,
                                summaryColor: severityColor(for: trigger),
                                colorFor: severityColor
                            )
                        } else {
                            TriggerCard(trigger: trigger, tintColor: severityColor(for: trigger))
                        }
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

// MARK: - Plain Trigger Card

private struct TriggerCard: View {
    let trigger: RiskTrigger
    let tintColor: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon always gray — color on the number only
            Image(systemName: trigger.icon)
                .foregroundColor(Color("small text"))
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(trigger.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("text"))
                    Text(trigger.displayValue)
                        .font(.system(size: 13))
                        .foregroundColor(Color("small text"))
                }
                Text(trigger.reasonText)
                    .font(.system(size: 12))
                    .foregroundColor(Color("small text"))
            }

            Spacer()

            Text("−\(trigger.deduction)%")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tintColor)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("card"))
        )
    }
}

// MARK: - Pollen Detail Card

private struct PollenDetailCard: View {
    let summary: RiskTrigger
    let subRows: [RiskTrigger]
    let summaryColor: Color
    let colorFor: (RiskTrigger) -> Color

    var body: some View {
        VStack(spacing: 0) {

            // Summary row
            HStack(spacing: 12) {
                Image(systemName: summary.icon)
                    .foregroundColor(Color("small text"))
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Pollen")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("text"))
                        Text(summary.displayValue)
                            .font(.system(size: 13))
                            .foregroundColor(Color("small text"))
                    }
                    Text(summary.reasonText)
                        .font(.system(size: 12))
                        .foregroundColor(Color("small text"))
                }

                Spacer()

                Text("−\(summary.deduction)%")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(summaryColor)
            }
            .padding(14)

            if !subRows.isEmpty {
                Divider()
                    .padding(.horizontal, 14)

                VStack(spacing: 0) {
                    ForEach(subRows, id: \.name) { sub in
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(colorFor(sub).opacity(0.3))
                                .frame(width: 3)
                                .cornerRadius(2)
                                .padding(.leading, 8)

                            // Sub-row icons also gray
                            Image(systemName: sub.icon)
                                .foregroundColor(Color("small text"))
                                .font(.system(size: 13))
                                .frame(width: 18)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(sub.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color("text"))
                                Text(sub.displayValue)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("small text"))
                            }

                            Spacer()

                            // Level badge colored by severity
                            Text(sub.level.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(colorFor(sub))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(colorFor(sub).opacity(0.12))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)

                        if sub.name != subRows.last?.name {
                            Divider().padding(.leading, 46)
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("card"))
        )
    }
}

// MARK: - Annotated Ring

private struct AnnotatedRingView: View {
    let score: Double
    let triggers: [RiskTrigger]
    let colorFor: (RiskTrigger) -> Color

    private let lineWidth: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("small text").opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: score / 100)
                .stroke(Color.accentColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                .rotationEffect(.degrees(-90))

            ForEach(Array(triggers.enumerated()), id: \.element.name) { index, trigger in
                let start = segmentStart(upTo: index)
                let end   = start + Double(trigger.deduction) / 100

                Circle()
                    .trim(from: start, to: end)
                    .stroke(colorFor(trigger),
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
                RiskTrigger(name: "Temperature",    icon: "thermometer.medium",
                            level: .moderate, displayValue: "14°C",
                            deduction: 8,  reasonText: "Cool — worth monitoring"),
                RiskTrigger(name: "Humidity",       icon: "drop.fill",
                            level: .high,     displayValue: "83%",
                            deduction: 12, reasonText: "Very humid — mold spore risk"),
                RiskTrigger(name: "Pollen (Total)", icon: "leaf.fill",
                            level: .high,     displayValue: "117 gr/m³",
                            deduction: 18, reasonText: "High — stay indoors if possible"),
                RiskTrigger(name: "Tree Pollen",    icon: "leaf.fill",
                            level: .high,     displayValue: "117 gr/m³",
                            deduction: 0,  reasonText: "High — stay indoors if possible"),
                RiskTrigger(name: "Weed Pollen",    icon: "leaf",
                            level: .low,      displayValue: "4 gr/m³",
                            deduction: 0,  reasonText: "Low — not a concern today"),
                RiskTrigger(name: "Grass Pollen",   icon: "leaf.arrow.circlepath",
                            level: .moderate, displayValue: "27 gr/m³",
                            deduction: 0,  reasonText: "Moderate — limit outdoor exposure"),
                RiskTrigger(name: "Air Quality",    icon: "aqi.low",
                            level: .low,      displayValue: "AQI 20",
                            deduction: 2,  reasonText: "Good air quality")
            ],
            score: 60
        )
    }
}
