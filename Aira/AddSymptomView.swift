//
//  AddSymptomView.swift
//  Aira
//
//  Created by Reema Alsaleh on 25/11/1447 AH.
//

import SwiftUI

struct AddSymptomView: View {
    @State private var selectedSymptoms: Set<String> = []
    @State private var selectedSeverity: Int = 2
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showOtherPopup = false

    // UserDefaults-backed custom symptoms
    @State private var customSymptoms: [String] = UserDefaults.standard.stringArray(forKey: "customSymptoms") ?? []

    @State private var showNoSelectionAlert = false
    @State private var showSavedToast = false
    @State private var savedCount = 0
    @State private var isSaving = false

    // Notes
    @State private var notes: String = ""

    var onSave: (_ selectedNames: Set<String>, _ selectedSeverityIndex: Int, _ startTime: Date, _ endTime: Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var backgroundColor: Color { Color("background") }
    private var cardColor: Color       { Color("card") }
    private var primaryText: Color     { Color("text") }
    private var secondaryText: Color   { Color("small text") }

    private let severities: [Color] = [
        Color("ColorG"),
        Color("ColorY"),
        Color("ColorO"),
        Color("ColorR"),
        Color.gray
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // How are you feeling?
                        Text("How are you feeling?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(primaryText)

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 3),
                            spacing: 18
                        ) {
                            ForEach(symptoms, id: \.1) { symptom in
                                SymptomCard(
                                    imageName: symptom.0,
                                    title: symptom.1,
                                    isSelected: selectedSymptoms.contains(symptom.1),
                                    cardColor: cardColor,
                                    selectedColor: Color.accentColor.opacity(0.12),
                                    textColor: primaryText,
                                    iconColor: primaryText
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

                        // Severity
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Severity")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(primaryText)

                            HStack(spacing: 28) {
                                ForEach(0..<severities.count, id: \.self) { index in
                                    SeverityCircle(
                                        color: severities[index],
                                        isSelected: selectedSeverity == index,
                                        innerStrokeColor: backgroundColor
                                    )
                                    .onTapGesture { selectedSeverity = index }
                                }
                            }

                            HStack {
                                Text("None")
                                Spacer()
                                Text("Severe")
                            }
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(secondaryText)
                        }

                        // Notes (optional)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes (optional)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(primaryText)

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $notes)
                                    .padding(12)
                                    .frame(minHeight: 110, alignment: .topLeading)
                                    .background(cardColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .scrollContentBackground(.hidden)

                                if notes.isEmpty {
                                    Text("Add a note...")
                                        .foregroundColor(secondaryText)
                                        .padding(.top, 18)
                                        .padding(.leading, 18)
                                }
                            }
                        }

                        // Time
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Time")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(primaryText)

                            HStack {
                                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)

                                Text("-")
                                    .font(.title3)
                                    .foregroundColor(primaryText)

                                DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(cardColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.08), radius: 8, y: 4)
                        }

                        // Selected counter
                        HStack {
                            Text("Selected: \(selectedSymptoms.count)")
                                .font(.system(size: 13))
                                .foregroundColor(secondaryText)
                            Spacer()
                        }

                        // Save button
                        Button {
                            guard !selectedSymptoms.isEmpty else {
                                showNoSelectionAlert = true
                                return
                            }
                            guard !isSaving else { return }
                            isSaving = true

                            savedCount = selectedSymptoms.count
                            onSave(selectedSymptoms, selectedSeverity, startTime, endTime)

                            withAnimation(.spring()) { showSavedToast = true }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation(.easeOut(duration: 0.25)) { showSavedToast = false }
                                dismiss()
                            }
                        } label: {
                            Text("Save Symptom")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedSymptoms.isEmpty ? Color.gray.opacity(0.6) : Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(selectedSymptoms.isEmpty)
                    }
                    .padding(24)
                }

                // Toast
                if showSavedToast {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text("Saved \(savedCount) symptom\(savedCount == 1 ? "" : "s")")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color.black.opacity(0.75))
                        .clipShape(Capsule())
                        .padding(.bottom, 24)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Log Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showOtherPopup) {
                CustomSymptomsPopup(
                    customSymptoms: $customSymptoms,
                    selectedSymptoms: $selectedSymptoms
                )
                .onDisappear {
                    UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                }
            }
            .alert("Select at least one symptom", isPresented: $showNoSelectionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please pick one or more symptoms before saving.")
            }
        }
    }

    private let symptoms = [
        ("wheezing", "Wheezing"),
        ("cough",    "Cough"),
        ("chest",    "Chest Tightness"),
        ("attack",   "Shortness of Breath"),
        ("fatigue",  "Fatigue"),
        ("otherDots","Other")
    ]

    func toggleSymptom(_ symptom: String) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }
}

// MARK: - CustomSymptomsPopup

struct CustomSymptomsPopup: View {
    @Binding var customSymptoms: [String]
    @Binding var selectedSymptoms: Set<String>
    @State private var symptomToDelete: String?
    @State private var showDeleteAlert = false
    @State private var newSymptom: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("Add Custom Symptom")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 14) {
                Text("Past Symptoms")
                    .font(.headline)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                    spacing: 16
                ) {
                    ForEach(customSymptoms, id: \.self) { symptom in
                        Text(symptom)
                            .onLongPressGesture {
                                symptomToDelete = symptom
                                showDeleteAlert  = true
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(Color("card"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        selectedSymptoms.contains(symptom) ? Color.accentColor : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .onTapGesture {
                                if selectedSymptoms.contains(symptom) {
                                    selectedSymptoms.remove(symptom)
                                } else {
                                    selectedSymptoms.insert(symptom)
                                }
                            }
                    }
                }
                .alert("Delete Symptom?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        if let toDelete = symptomToDelete {
                            customSymptoms.removeAll { $0 == toDelete }
                            selectedSymptoms.remove(toDelete)
                            UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }

            TextField("Add Custom Symptom...", text: $newSymptom, axis: .vertical)
                .padding()
                .frame(minHeight: 90, alignment: .topLeading)
                .background(Color("card"))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(alignment: .bottomTrailing) {
                    Text("\(newSymptom.count)/100")
                        .foregroundColor(Color("small text"))
                        .padding()
                }
                .onChange(of: newSymptom) { _, value in
                    if value.count > 100 { newSymptom = String(value.prefix(100)) }
                }

            Button("Save") {
                let trimmed = newSymptom.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty, !customSymptoms.contains(trimmed) else { return }
                customSymptoms.append(trimmed)
                UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                selectedSymptoms.insert(trimmed)
                newSymptom = ""
            }
            .font(.headline)
            .frame(width: 120, height: 44)
            .background(Color("card"))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Button("Cancel") { dismiss() }
                .font(.headline)
                .frame(width: 120, height: 44)
                .background(Color("card"))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Spacer()
        }
        .padding(28)
        .background(Color.black.opacity(0.25))
    }
}

// MARK: - SymptomCard

struct SymptomCard: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let cardColor: Color
    let selectedColor: Color
    let textColor: Color
    let iconColor: Color

    var iconSize: CGFloat { imageName == "chest" ? 65 : 52 }

    var body: some View {
        VStack(spacing: 14) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(iconColor)

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
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

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 46, height: 46)
            .overlay(
                Circle()
                    .stroke(isSelected ? color : Color.clear, lineWidth: 4)
                    .frame(width: 58, height: 58)
            )
            .overlay(
                Circle()
                    .stroke(isSelected ? innerStrokeColor : Color.clear, lineWidth: 3)
                    .frame(width: 50, height: 50)
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
