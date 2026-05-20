//
//  WatchAirDetailView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 20/05/2026.
//

import SwiftUI

struct WatchAirDetailView: View {
    let triggers: [AsthmaTrigger]
    let score: Double

    var body: some View {
        List {
            Section {
                ForEach(triggers) { trigger in
                    HStack {
                        Image(systemName: trigger.icon)
                            .foregroundStyle(.blue)

                        Text(trigger.name)
                            .font(.system(size: 14))

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(trigger.value) \(trigger.unit)")
                                .font(.system(size: 13, weight: .semibold))

                            Text(trigger.level.rawValue)
                                .font(.system(size: 11))
                                .foregroundStyle(levelColor(trigger.level))
                        }
                    }
                }
            } header: {
                Text("Today's Triggers")
            }
        }
        .navigationTitle("Air Details")
    }

    private func levelColor(_ level: TriggerLevel) -> Color {
        switch level {
        case .low:      return .green
        case .moderate: return .yellow
        case .high:     return .red
        }
    }
}

#Preview {
    WatchAirDetailView(
        triggers: [
            AsthmaTrigger(name: "Temperature", icon: "thermometer.medium", level: .high,     value: "34", unit: "°C"),
            AsthmaTrigger(name: "Humidity",    icon: "drop.fill",          level: .moderate, value: "68", unit: "%"),
            AsthmaTrigger(name: "Pollen",      icon: "leaf.fill",          level: .low,      value: "12", unit: "µg/m³"),
            AsthmaTrigger(name: "Dust",        icon: "aqi.low",            level: .low,      value: "18", unit: "µg/m³")
        ],
        score: 82
    )
}
