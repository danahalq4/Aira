//
//  WatchSymptomsView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 19/05/2026.
//


//
//  WatchSymptomsView.swift
//  Aira Watch App
//
//  
////
//  WatchSymptomsView.swift
//  Aira Watch App
////
//  WatchSymptomsView.swift
//  Aira Watch App
//
import SwiftUI

struct WatchSymptomsView: View {
    
    @State private var selectedSymptom: String? = nil
    @State private var selectedSeverity: Int? = nil
    @Environment(\.dismiss) private var dismiss
    var onSave: (_ symptom: String, _ severityIndex: Int) -> Void = { _, _ in }
    
    private let symptoms: [WatchSymptomOption] = [
        .init(name: "Fatigue", icon: "brain.head.profile"),
        .init(name: "Wheeze", icon: "wind"),
        .init(name: "Cough", icon: "head.profile.arrow.forward.and.visionpro"),
        .init(name: "Chest", icon: "lungs.fill"),
        .init(name: "Breath", icon: "figure.run")
    ]
    
    private let severities: [Color] = [
        .yellow,
        .orange,
        .red
    ]
    
    var body: some View {
        TabView {
            // CARD 1: Pick Symptom
            VStack(spacing: 9) {
                headerView
                symptomsScrollView
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 0)
            
            // CARD 2: Severity + Save
            VStack(spacing: 14) {
                severityView
                saveButton
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .containerBackground(.background, for: .navigation)
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            Text("Quick Log")
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)

            Text("Log Symptom")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.secondary)
        }
        //.frame(maxWidth: .infinity)
    }
    private var symptomsScrollView: some View {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ],
                    spacing: 8
                ) {
                    ForEach(symptoms) { symptom in
                        WatchSymptomCard(
                                symptom: symptom,
                                isSelected: selectedSymptom == symptom.name
                            )
                        .onTapGesture {selectedSymptom = symptom.name
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.bottom, 8)
            }
        }
    private var severityView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SEVERITY")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            
            HStack(spacing: 20) {
                ForEach(0..<severities.count, id: \.self) { index in
                    Circle()
                        .fill(severities[index])
                        .frame(
                            width: index == 0 ? 30 : index == 1 ? 42 : 54,
                            height: index == 0 ? 30 : index == 1 ? 42 : 54
                        )
                        .overlay {
                                Circle()
                                    .stroke(
                                        (selectedSeverity != nil && selectedSeverity == index) ? severities[index].opacity(0.7) : Color.clear,
                                        lineWidth: 3
                                    )
                                    .padding(-4)
                            }
                        .onTapGesture {
                            selectedSeverity = index
                        }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var saveButton: some View {
            Button {
                onSave(selectedSymptom!, selectedSeverity!)
                
               
                dismiss()
            } label: {
            Text("Save Entry")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                                .background(.thinMaterial)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(.white.opacity(0.18), lineWidth: 1)
                                }
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .disabled(selectedSymptom == nil || selectedSeverity == nil) // Disables save until both are chosen!
                .opacity((selectedSymptom == nil || selectedSeverity == nil) ? 0.6 : 1.0)
    }
}

// MARK: - Symptom Model

struct WatchSymptomOption: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

// MARK: - Symptom Card
struct WatchSymptomCard: View {
    let symptom: WatchSymptomOption
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    // Changes from a plain glass background to a solid blue/tint fill when active
                    .fill(.thinMaterial) // Keep glass background stable
                    .background(isSelected ? Color.accentColor : Color.clear) // Layer color underneath if active
                    .clipShape(Circle())
                    .frame(width: 44, height: 44)
                
                Image(systemName: symptom.icon)
                    // Makes the icon larger and turns it white when selected for high contrast
                    .font(.system(size: isSelected ? 24 : 20, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            
            Text(symptom.name)
                // Bolds the text label slightly when selected
                .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        // Dynamically changes the overall card container style based on its active state
        .background(.thinMaterial) // Stable base glass layer
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear) // Conditional tint overlay layer
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    isSelected ? Color.accentColor : Color.secondary.opacity(0.25),
                    lineWidth: isSelected ? 2.5 : 1
                )
        }
        // Adds a snappy, modern bounce animation whenever the user toggles a selection
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    WatchSymptomsView()
}
