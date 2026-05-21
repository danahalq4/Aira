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

    private let severities: [Color] = [
        Color("ColorY"),
        Color("ColorO"),
        Color("ColorR")
    ]

    private let severityLabels = [
        "Moderate",
        "Severe",
        "Very Severe"
    ]
    private let defaultSymptomsBase = [
        "Wheezing", "Cough", "Chest Tightness", "Shortness of Breath", "Fatigue"
    ]
    private let otherKey = "Other"

    private var allOptions: [String] {
        let customs: [String] = customSymptoms
        let defaults: [String] = defaultSymptomsBase.filter { d in
            !customs.contains(d)
        }
        return customs + defaults + [otherKey]
    }

    // Hoist columns to a property to avoid recomputation inside the builder
    private let gridColumns: [GridItem] =
        Array(repeating: GridItem(.flexible(), spacing: 18), count: 3)

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        Text("How are you feeling?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(primaryText)

                        LazyVGrid(
                            columns: gridColumns,
                            spacing: 18
                        ) {
                            ForEach(allOptions, id: \.self) { (title: String) in
                                symptomItemView(for: title)
                            }
                        }

                        severitySection

                        timeSection

                        HStack {
                            Text("Selected: \(selectedSymptoms.count)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(secondaryText)
                            Spacer()
                        }

                        Button {
                            guard !selectedSymptoms.isEmpty else {
                                return
                            }
                            guard !isSaving else { return }
                            isSaving = true

                            savedCount = selectedSymptoms.count
                            onSave(selectedSymptoms, selectedSeverity, startTime, endTime)
                            dismiss()
                        } label: {
                            Text("Save Symptom")
                                .font(.system(size: 16, weight: .semibold))
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
            }
            .navigationTitle("Log Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showOtherPopup) {
                CustomSymptomsPopup(
                    customSymptoms: $customSymptoms,
                    selectedSymptoms: $selectedSymptoms,
                    onImmediateAdd: { name in
                        selectedSymptoms.insert(name)
                        onSave([name], selectedSeverity, startTime, endTime)
                    }
                )
                .onDisappear {
                    UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                }
            }
        }
    }

    // MARK: - Extracted subviews

    private func symptomItemView(for title: String) -> some View {
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
            guard customSymptoms.contains(title) else { return }
            pendingDeleteCustom = title
            showDeleteAlert = true
        }
    }

    private var severitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Severity")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(primaryText)

            HStack(alignment: .bottom, spacing: 45) {
                ForEach(0..<severities.count, id: \.self) { (index: Int) in
                    VStack(spacing: 8) {
                        SeverityCircle(
                            color: severities[index],
                            isSelected: selectedSeverity == index,
                            innerStrokeColor: backgroundColor,
                            size: CGFloat(40 + index * 10)
                        )
                        .onTapGesture {
                            selectedSeverity = index
                        }

                        Text(severityLabels[index])
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(secondaryText)
                            .multilineTextAlignment(.center)
                            .frame(height: 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Time")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(primaryText)

            HStack {
                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)

                Text("-")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(primaryText)

                DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.08), radius: 8, y: 4)
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
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 80, alignment: .center)
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
        ZStack {
            // Base filled circle
            Circle()
                .fill(color)
                .frame(width: size, height: size)

            // Inner contrast stroke to keep edges crisp against backgrounds
            Circle()
                .stroke(innerStrokeColor.opacity(0.9), lineWidth: 3)
                .frame(width: size - 6, height: size - 6)

            // Selection ring
            if isSelected {
                Circle()
                    .stroke(color.opacity(0.7), lineWidth: 4)
                    .frame(width: size + 6, height: size + 6)
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
        .accessibilityLabel(isSelected ? "Selected severity" : "Severity")
    }
}
