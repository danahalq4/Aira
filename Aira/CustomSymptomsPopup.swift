import SwiftUI

struct CustomSymptomsPopup: View {
    @Binding var customSymptoms: [String]
    @Binding var selectedSymptoms: Set<String>
    var onImmediateAdd: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var newSymptom: String = ""
    @State private var showDuplicateAlert = false

    private var trimmedNew: String {
        newSymptom.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // Add new custom symptom
                HStack(spacing: 8) {
                    TextField("Add a custom symptom", text: $newSymptom)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding(12)
                        .background(Color("card"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button(action: addNew) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                    }
                    .disabled(trimmedNew.isEmpty)
                }

                // Existing custom symptoms list with selection
                if customSymptoms.isEmpty {
                    Text("No custom symptoms yet. Add one above.")
                        .font(.footnote)
                        .foregroundColor(Color("small text"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    List {
                        ForEach(customSymptoms, id: \.self) { name in
                            HStack {
                                Text(name)
                                Spacer()
                                if selectedSymptoms.contains(name) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleSelection(name)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.insetGrouped)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .navigationTitle("Custom Symptoms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("This symptom already exists.", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    private func addNew() {
        let candidate = trimmedNew
        guard !candidate.isEmpty else { return }

        // Prevent duplicates (case-insensitive)
        if customSymptoms.contains(where: { $0.caseInsensitiveCompare(candidate) == .orderedSame }) {
            showDuplicateAlert = true
            return
        }

        customSymptoms.append(candidate)
        selectedSymptoms.insert(candidate)
        onImmediateAdd(candidate)
        newSymptom = ""
        dismiss()
    }

    private func toggleSelection(_ name: String) {
        if selectedSymptoms.contains(name) {
            selectedSymptoms.remove(name)
        } else {
            selectedSymptoms.insert(name)
        }
    }

    private func delete(at offsets: IndexSet) {
        let toRemove = offsets.compactMap { index in
            customSymptoms.indices.contains(index) ? customSymptoms[index] : nil
        }
        for name in toRemove {
            selectedSymptoms.remove(name)
        }
        customSymptoms.remove(atOffsets: offsets)
    }
}

#Preview {
    struct PreviewHost: View {
        @State var customs: [String] = ["Anxiety", "Headache"]
        @State var selected: Set<String> = ["Anxiety"]

        var body: some View {
            CustomSymptomsPopup(
                customSymptoms: $customs,
                selectedSymptoms: $selected,
                onImmediateAdd: { _ in }
            )
            .background(Color("background"))
        }
    }
    return PreviewHost()
}
