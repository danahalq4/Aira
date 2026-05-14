//
//  AddSymptomView.swift
//  Aira
//
//  Created by Reema Alsaleh  on 25/11/1447 AH.
//


import SwiftUI

struct AddSymptomView: View {
    @State private var selectedSymptoms: Set<String> = []
    @State private var selectedSeverity: Int = 2
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showOtherPopup = false
    @State private var customSymptoms: [String] = UserDefaults.standard.stringArray(forKey: "customSymptoms") ?? []

    var onSave: (_ selectedNames: Set<String>, _ selectedSeverityIndex: Int, _ startTime: Date, _ endTime: Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let symptoms = [
        ("wheezing", "Wheezing"),
        ("cough", "Cough"),
        ("chest", "Chest Tightness"),
        ("attack", "Shortness\nof Breath"),
        ("fatigue", "Fatigue"),
        ("otherDots", "Other")
    ]

    let severities = [
        Color(hex: "56AE59"),
        Color(hex: "FDCA06"),
        Color(hex: "F87B1E"),
        Color.red,
        Color.gray
    ]

    var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "0E1116") : Color(hex: "F7F8FA")
    }

    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var noteBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "1B2028") : .white
    }

    var severityInnerStrokeColor: Color {
        colorScheme == .dark ? Color(hex: "0E1116") : Color(hex: "F7F8FA")
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

                        HStack(spacing: 28) {
                            ForEach(0..<severities.count, id: \.self) { index in
                                SeverityCircle(
                                    color: severities[index],
                                    isSelected: selectedSeverity == index,
                                    innerStrokeColor: severityInnerStrokeColor
                                )
                                .onTapGesture {
                                    selectedSeverity = index
                                }
                            }
                        }

                        HStack {
                            Text("None")
                            Spacer()
                            Text("Severe")
                        }
                        .font(.headline)
                        .foregroundColor(.gray)
                    }

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
                        onSave(selectedSymptoms, selectedSeverity, startTime, endTime)
                        dismiss()
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
                Text("Past Symptoms ")
                    .font(.headline)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(customSymptoms, id: \.self) { symptom in
                        Text(symptom)
                            .onLongPressGesture {
                                symptomToDelete = symptom
                                showDeleteAlert = true
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(selectedSymptoms.contains(symptom) ? Color.blue.opacity(0.15) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(selectedSymptoms.contains(symptom) ? Color.blue : Color.clear, lineWidth: 2)
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
                        if let symptomToDelete {
                            customSymptoms.removeAll { $0 == symptomToDelete }
                            selectedSymptoms.remove(symptomToDelete)
                            UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                        }
                    }

                    Button("Cancel", role: .cancel) { }
                }
            }

            TextField("Add Custom Symptom...", text: $newSymptom, axis: .vertical)
                .padding()
                .frame(minHeight: 90, alignment: .topLeading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(alignment: .bottomTrailing) {
                    Text("\(newSymptom.count)/100")
                        .foregroundColor(.gray)
                        .padding()
                }
                .onChange(of: newSymptom) { _, value in
                    if value.count > 100 {
                        newSymptom = String(value.prefix(100))
                    }
                }

            Button("Save") {
                let trimmed = newSymptom.trimmingCharacters(in: .whitespacesAndNewlines)

                if !trimmed.isEmpty && !customSymptoms.contains(trimmed) {
                    customSymptoms.append(trimmed)
                    UserDefaults.standard.set(customSymptoms, forKey: "customSymptoms")
                    selectedSymptoms.insert(trimmed)
                    newSymptom = ""
                }
            }
            .font(.headline)
            .frame(width: 120, height: 44)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Button("Cancel") {
                dismiss()
            }
            .font(.headline)
            .frame(width: 120, height: 44)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Spacer()
        }
        .padding(28)
        .background(Color.gray.opacity(0.25))
    }
}
struct SymptomCard: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    @Environment(\.colorScheme) private var colorScheme

    var cardColor: Color {
        colorScheme == .dark ? Color(hex: "1B2028") : .white
    }

    var selectedColor: Color {
        colorScheme == .dark ? Color(hex: "2A3340") : Color(hex: "EAF2FF")
    }

    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var iconColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var iconSize: CGFloat {
        imageName == "chest" ? 65 : 52
        
    }

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
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(isSelected ? selectedColor : cardColor)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0 : 0.08), radius: 8, y: 4)
    }
}

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

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

#Preview("Light Mode") {
    AddSymptomView { _,_,_,_ in }
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    AddSymptomView { _,_,_,_ in }
        .preferredColorScheme(.dark)
}

