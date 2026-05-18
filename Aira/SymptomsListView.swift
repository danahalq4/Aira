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
            // أيقونة محذوفة حسب طلبك

            VStack(alignment: .leading, spacing: 2) {
                Text(symptom.name)
                    .font(.body.weight(.semibold))
                    .foregroundColor(Color("text"))

                HStack(spacing: 8) {
                    Text(timeString(symptom.time))
                        .foregroundColor(Color("small text"))

                    // دائرة بلون الشدة بدل نص الشدة
                    Circle()
                        .fill(Color(symptom.severity.colorAssetName))
                        .frame(width: 8, height: 8)
                }
                .font(.subheadline)
            }

            Spacer()

            // إن كنتِ لا تريدين الـ Toggle، نتركه محذوفاً:
            // Toggle("", isOn: Binding(
            //     get: { symptom.isTracked },
            //     set: { _ in onToggle() }
            // ))
            // .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            // .labelsHidden()
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
                Symptom(name: "Cough", time: Date(), severity: .severe, isTracked: true, iconSystemName: "lungs.fill"),
                Symptom(name: "Fatigue", time: Date(), severity: .mild, isTracked: false, iconSystemName: "zzz")
            ],
            toggleAction: { _ in }
        )
    }
    .padding()
    .background(Color("background"))
}
