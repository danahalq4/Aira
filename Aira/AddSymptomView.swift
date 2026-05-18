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

    // Persisted custom symptoms (always shown)
    @State private var customSymptoms: [String] = UserDefaults.standard.stringArray(forKey: "customSymptoms") ?? []

    @State private var showNoSelectionAlert = false
    @State private var showSavedToast = false
    @State private var savedCount = 0
    @State private var isSaving = false

    // Long-press delete for custom items
    @State private var pendingDeleteCustom: String?
    @State private var showDeleteAlert = false

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

    // Default options (without "Other")
    private let defaultSymptomsBase = [
        "Wheezing",
        "Cough",
        "Chest Tightness",
        "Shortness of Breath",
        "Fatigue"
    ]
    private let otherKey = "Other"

    // Grid = custom symptoms (persisted) + defaults (no duplicates) + "Other" last
    private var allOptions: [String] {
        let customs = customSymptoms
        let defaults = defaultSymptomsBase.filter { !customs.contains($0) }
        return customs + defaults + [otherKey]
    }

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
                            ForEach(allOptions, id: \.self) { title in
                                SymptomTextCard(
                                    title: title,
                                    isSelected: selectedSymptoms.contains(title),
                                    cardColor: cardColor,
                                    selectedColor: Color.accentColor.opacity(0.12),
                                    textColor: primaryText
                                )
                                .onTapGesture {
                                    if title == otherKey {
                                        showOtherPopup = true
                                    } else {
                                        toggleSymptom(title)
                                    }
                                }
                                .onLongPressGesture {
                                    // Allow deletion only for persisted custom items
                                    guard customSymptoms.contains(title) else { return }
                                    pendingDeleteCustom = title
                                    showDeleteAlert = true
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
                    selectedSymptoms: $selectedSymptoms,
                    onImmediateAdd: { name in
                        // Ensure selection
                        selectedSymptoms.insert(name)
                        // Immediate add to calendar with current settings
                        onSave([name], selectedSeverity, startTime, endTime)
                    }
                )
                .onDisappear {
                    // Persist custom list on popup close
                    UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                }
            }
            .alert("Select at least one symptom", isPresented: $showNoSelectionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please pick one or more symptoms before saving.")
            }
            // Long-press delete alert for custom items
            .alert("Delete symptom?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let name = pendingDeleteCustom {
                        // Remove from selection
                        selectedSymptoms.remove(name)
                        // Remove from persisted customs
                        customSymptoms.removeAll { $0 == name }
                        UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                    }
                    pendingDeleteCustom = nil
                }
                Button("Cancel", role: .cancel) {
                    pendingDeleteCustom = nil
                }
            } message: {
                if let name = pendingDeleteCustom {
                    Text("Remove “\(name)” from your custom symptoms?")
                } else {
                    Text("")
                }
            }
        }
    }

    private func toggleSymptom(_ symptom: String) {
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

    // Immediate add to calendar via AddSymptomView
    var onImmediateAdd: ((String) -> Void)? = nil

    @State private var newSymptom: String = ""
    @Environment(\.dismiss) private var dismiss

    // Theming via Assets
    private var backgroundColor: Color { Color("background") }
    private var cardColor: Color       { Color("card") }
    private var primaryText: Color     { Color("text") }
    private var secondaryText: Color   { Color("small text") }

    var body: some View {
        ZStack {
            // لا تعتيم خلفي — يظهر فقط البوكس
            // Popup card styled with app assets
            VStack(spacing: 20) {
                Text("Add Custom Symptom")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Add Custom Symptom...", text: $newSymptom, axis: .vertical)
                    .padding()
                    .frame(minHeight: 90, alignment: .topLeading)
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .bottomTrailing) {
                        Text("\(newSymptom.count)/100")
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
                            .font(.system(size: 17, weight: .semibold))
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
                            .font(.system(size: 17, weight: .semibold))
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
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .frame(height: 120, alignment: .center)
            .padding(.horizontal, 6)
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
