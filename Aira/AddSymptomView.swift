//
//  AddSymptomView.swift
//  Aira
//

import SwiftUI

struct AddSymptomView: View {
    @State private var selectedSymptoms: Set<String> = []
    @State private var selectedSeverity: Int = 2
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showOtherPopup = false

    @State private var customSymptoms: [String] = UserDefaults.standard.stringArray(forKey: "customSymptoms") ?? []

    @State private var showNoSelectionAlert = false
    @State private var showSavedToast = false
    @State private var savedCount = 0
    @State private var isSaving = false

    @State private var pendingDeleteCustom: String?
    @State private var showDeleteAlert = false

    var onSave: (_ selectedNames: Set<String>, _ selectedSeverityIndex: Int, _ startTime: Date, _ endTime: Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var backgroundColor: Color { Color("background") }
    private var cardColor: Color       { Color("card") }
    private var primaryText: Color     { Color("text") }
    private var secondaryText: Color   { Color("small text") }

    let severities = [
        Color(hex: "56AE59"),
        Color(hex: "9BE564"),
        Color(hex: "FDCA06"),
        Color(hex: "F87B1E"),
        Color.red
    ]

    let severityLabels = [
        "None",
        "Mild",
        "Moderate",
        "Severe",
        "Very Severe"
    ]

    private let defaultSymptomsBase = [
        "Wheezing", "Cough", "Chest Tightness", "Shortness of Breath", "Fatigue"
    ]
    private let otherKey = "Other"

    private var allOptions: [String] {
        let customs = customSymptoms
        let defaults = defaultSymptomsBase.filter { !customs.contains($0) }
        return customs + defaults + [otherKey]
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Log Symptoms")
                           .font(.title)
                           .fontWeight(.bold)
                           .frame(maxWidth: .infinity)
                           .foregroundColor(textColor)
                           .padding(.top, -15)

                       Text("How are you feeling?")
                           .font(.title2)
                           .fontWeight(.bold)
                           .foregroundColor(textColor)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 3), spacing: 18) {
                        ForEach(symptoms, id: \.1) { symptom in
                            SymptomCard(
                                imageName: symptom.0,
                                title: symptom.1,
                                isSelected: selectedSymptoms.contains(symptom.1)
                            )
                            .onTapGesture {
                                if symptom.1 == "Other" {
                                showOtherPopup = true
                                    } else {
                                  toggleSymptom(symptom.1)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        
                        Text("Severity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        

                        HStack(alignment: .bottom, spacing: 14) {
                            ForEach(0..<severities.count, id: \.self) { index in
                                VStack(spacing: 8) {
                                    SeverityCircle(
                                        color: severities[index],
                                        isSelected: selectedSeverity == index,
                                        innerStrokeColor: severityInnerStrokeColor,
                                        size: CGFloat(40 + index * 10)
                                    )
                                    .onTapGesture {
                                        selectedSeverity = index
                                    }

                                    Text(severityLabels[index])
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .frame(height: 32)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Time")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)

                        HStack {
                            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)

                            Text("-")
                                .font(.title3)
                                .foregroundColor(textColor)

                            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(noteBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0 : 0.08), radius: 8, y: 4)
                    }
                    Button {
                    } label: {
                        Text("Save Symptom")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            
                            .padding(24)
                        }
                    }
                    .sheet(isPresented: $showOtherPopup) {
                        CustomSymptomsPopup(
                            customSymptoms: $customSymptoms,
                            selectedSymptoms: $selectedSymptoms
                        )
                    }
                }

                func toggleSymptom(_ symptom: String) {
                    if selectedSymptoms.contains(symptom) {
                        selectedSymptoms.remove(symptom)
                    } else {
                        selectedSymptoms.insert(symptom)
                    }
                }
            }

struct CustomSymptomsPopup: View {
    @Binding var customSymptoms: [String]
    @Binding var selectedSymptoms: Set<String>
    var onImmediateAdd: ((String) -> Void)? = nil

    @State private var newSymptom: String = ""
    @Environment(\.dismiss) private var dismiss

    private var backgroundColor: Color { Color("background") }
    private var cardColor: Color       { Color("card") }
    private var primaryText: Color     { Color("text") }
    private var secondaryText: Color   { Color("small text") }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // ── Popup title ──
                Text("Add Custom Symptom")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Add Custom Symptom...", text: $newSymptom, axis: .vertical)
                    .font(.system(size: 15, weight: .regular))
                    .padding()
                    .frame(minHeight: 90, alignment: .topLeading)
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .bottomTrailing) {
                        Text("\(newSymptom.count)/100")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(secondaryText)
                            .padding()
                    }
                    .onChange(of: newSymptom) { _, value in
                        if value.count > 100 { newSymptom = String(value.prefix(100)) }
                    }

                HStack(spacing: 16) {
                    Button {
                        let trimmed = newSymptom.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        if !customSymptoms.contains(trimmed) {
                            customSymptoms.append(trimmed)
                            UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                        }
                        selectedSymptoms.insert(trimmed)
                        onImmediateAdd?(trimmed)
                        newSymptom = ""
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(cardColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color("small text").opacity(0.15), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(20)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: Color("small text").opacity(0.18), radius: 20, y: 8)
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - SymptomTextCard

struct SymptomTextCard: View {
    let title: String
    let isSelected: Bool
    let cardColor: Color
    let selectedColor: Color
    let textColor: Color

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(textColor)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 80, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? selectedColor : cardColor)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }
}

// MARK: - SeverityCircle

struct SeverityCircle: View {
    let color: Color
    let isSelected: Bool
    let innerStrokeColor: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(isSelected ? color : Color.clear, lineWidth: 4)
                    .frame(width: size + 12, height: size + 12)
            )
            .overlay(
                Circle()
                    .stroke(isSelected ? innerStrokeColor : Color.clear, lineWidth: 3)
                    .frame(width: size + 4, height: size + 4)
            )
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    AddSymptomView { _, _, _, _ in }
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    AddSymptomView { _, _, _, _ in }
        .preferredColorScheme(.dark)
}
