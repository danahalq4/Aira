//
import SwiftUI

#if os(watchOS)

struct WatchAirDetailView: View {
    let riskTriggers: [RiskTrigger]
    let score: Double

    private var generalTriggers: [RiskTrigger] {
        var rows: [RiskTrigger] = []

        if let temp = riskTriggers.first(where: { $0.name == "Temperature" }) {
            rows.append(
                RiskTrigger(
                    name: "Temp",
                    icon: temp.icon,
                    level: temp.level,
                    displayValue: temp.displayValue,
                    deduction: temp.deduction,
                    reasonText: temp.reasonText
                )
            )
        }

        if let humidity = riskTriggers.first(where: { $0.name == "Humidity" }) {
            rows.append(humidity)
        }

        if let pollen = riskTriggers.first(where: { $0.name == "Pollen (Total)" }) {
            rows.append(
                RiskTrigger(
                    name: "Pollen",
                    icon: pollen.icon,
                    level: pollen.level,
                    displayValue: pollen.displayValue,
                    deduction: pollen.deduction,
                    reasonText: pollen.reasonText
                )
            )
        }

        if let aqi = riskTriggers.first(where: { $0.name == "Air Quality" }) {
            rows.append(aqi)
        }

        return rows
    }

    private func severityColor(_ level: TriggerLevel) -> Color {
        switch level {
        case .high:     return Color("ColorR")
        case .moderate: return Color("ColorO")
        case .low:      return Color("ColorY")
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(generalTriggers, id: \.name) { trigger in
                    WatchGeneralTriggerRow(
                        trigger: trigger,
                        severityColor: severityColor
                    )
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .navigationTitle("Breakdown")
    }
}

private struct WatchGeneralTriggerRow: View {
    let trigger: RiskTrigger
    let severityColor: (TriggerLevel) -> Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: trigger.icon)
                .foregroundStyle(severityColor(trigger.level))
                .font(.system(size: 14))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(trigger.name)
                    .font(.system(size: 13, weight: .medium))

                Text(trigger.displayValue)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(trigger.level.rawValue)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(severityColor(trigger.level))
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(severityColor(trigger.level).opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        WatchAirDetailView(
            riskTriggers: [],
            score: 54
        )
    }
}

#endif // os(watchOS)
