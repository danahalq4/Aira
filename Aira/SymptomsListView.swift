//
//  SymptomsListView.swift
//  Aira
//
//  Created by MVVM.
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
            ZStack {
                Circle()
                    .fill(Color("card").opacity(0.001)) // tap target alignment
                Image(systemName: symptom.iconSystemName)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(Color(symptom.severity.colorAssetName))
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(symptom.name)
                    .font(.body.weight(.semibold))
                    .foregroundColor(Color("text"))

                HStack(spacing: 6) {
                    Text(timeString(symptom.time))
                        .foregroundColor(Color("small text"))
                    Text(symptom.severity.displayText)
                        .foregroundColor(Color("small text"))
                }
                .font(.subheadline)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { symptom.isTracked },
                set: { _ in onToggle() }
            ))
            .toggleStyle(SwitchToggleStyle(tint: Color("text"))) // بديل عن AccentColor
            .labelsHidden()
        }
        .padding(12)
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
                Symptom(name: "Wheezing", time: Date(), severity: .moderate, isTracked: true, iconSystemName: "wind"),
                Symptom(name: "Anxiety", time: Date(), severity: .mild, isTracked: false, iconSystemName: "face.smiling")
            ],
            toggleAction: { _ in }
        )
    }
    .padding()
    .background(Color("background"))
}
