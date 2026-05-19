//
//  SymptomsListView.swift
//  Aira
//

import SwiftUI

struct SymptomsListView: View {
    let symptoms: [Symptom]
    let toggleAction: (Symptom) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(symptoms) { symptom in
                SymptomCardView(symptom: symptom) {
                    toggleAction(symptom)
                }
            }
        }
    }
}

struct SymptomCardView: View {
    let symptom: Symptom
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {
                // ── Symptom name (matches "Temprature", "Humidity") ──
                Text(symptom.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("text"))

                HStack(spacing: 8) {
                    // ── Time (small secondary) ──
                    Text(timeString(symptom.time))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color("small text"))

                    // ── Severity dot فقط بدون نص
                    Circle()
                        .fill(Color(symptom.severity.colorAssetName))
                        .frame(width: 8, height: 8)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("card"))
        )
    }

    private func timeString(_ date: Date) -> String {
        let df = DateFormatter()
        df.timeStyle = .short
        return df.string(from: date)
    }
}

#Preview {
    VStack {
        SymptomsListView(
            symptoms: [
                Symptom(name: "Wheezing",  time: Date(), severity: .moderate, isTracked: true,  iconSystemName: "wind"),
                Symptom(name: "Cough",     time: Date(), severity: .severe,   isTracked: true,  iconSystemName: "lungs.fill"),
                Symptom(name: "Fatigue",   time: Date(), severity: .mild,     isTracked: false, iconSystemName: "zzz")
            ],
            toggleAction: { _ in }
        )
    }
    .padding()
    .background(Color("background"))
}
