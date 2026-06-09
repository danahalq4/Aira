import SwiftUI
import SwiftData


struct AddSymptomView: View {


    @State private var selectedSymptoms: Set<String> = []
    @State private var selectedSeverity: Int = 2
    @State private var startTime = Date()
    @State private var endTime = Date()

    @State private var showOtherPopup = false

    @State private var customSymptoms: [String] =
    UserDefaults.standard.stringArray(
        forKey: "customSymptoms"
    ) ?? []


    var onSave: (
        _ selectedNames: Set<String>,
        _ selectedSeverityIndex: Int,
        _ startTime: Date,
        _ endTime: Date
    ) -> Void



    @Environment(\.modelContext)
    private var modelContext


    @Environment(\.dismiss)
    private var dismiss


    @Environment(\.colorScheme)
    private var colorScheme





    private var backgroundColor: Color {
        Color("background")
    }

    private var cardColor: Color {
        Color("card")
    }

    private var primaryText: Color {
        Color("text")
    }

    private var secondaryText: Color {
        Color("small text")
    }





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
        "Wheezing",
        "Cough",
        "Chest Tightness",
        "Shortness of Breath",
        "Fatigue"
    ]


    private let otherKey = "Other"



    private var allOptions: [String] {

        let defaults =
        defaultSymptomsBase.filter {
            !customSymptoms.contains($0)
        }

        return customSymptoms + defaults + [otherKey]
    }



    private let gridColumns: [GridItem] =
    Array(
        repeating:
            GridItem(
                .flexible(),
                spacing: 18
            ),
        count: 3
    )








    var body: some View {


        NavigationStack {


            ZStack {


                backgroundColor
                    .ignoresSafeArea()



                ScrollView {


                    VStack(
                        alignment: .leading,
                        spacing: 24
                    ) {




                        Text("How are you feeling?")
                            .font(
                                .system(
                                    size: 16,
                                    weight: .semibold
                                )
                            )
                            .foregroundColor(
                                primaryText
                            )





                        LazyVGrid(
                            columns: gridColumns,
                            spacing: 18
                        ) {


                            ForEach(
                                allOptions,
                                id: \.self
                            ) { title in


                                symptomButton(
                                    title
                                )
                            }
                        }





                        Text("Severity")
                            .font(.headline)
                            .foregroundColor(
                                primaryText
                            )


                        HStack(spacing: 35) {


                            ForEach(
                                0..<severities.count,
                                id: \.self
                            ) { index in


                                Circle()
                                    .fill(
                                        severities[index]
                                    )
                                    .frame(
                                        width: selectedSeverity == index ? 55 : 45,
                                        height: selectedSeverity == index ? 55 : 45
                                    )
                                    .onTapGesture {

                                        selectedSeverity = index
                                    }
                            }
                        }







                        DatePicker(
                            "Time",
                            selection: $startTime,
                            displayedComponents:
                                .hourAndMinute
                        )







                        Button {


                            guard
                                !selectedSymptoms.isEmpty
                            else {
                                return
                            }



                            onSave(
                                selectedSymptoms,
                                selectedSeverity,
                                startTime,
                                endTime
                            )


                            dismiss()



                        } label: {


                            Text("Save Symptom")
                                .font(
                                    .system(
                                        size: 16,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(.white)
                                .frame(
                                    maxWidth:
                                        .infinity
                                )
                                .padding()
                                .background(
                                    selectedSymptoms.isEmpty
                                    ? Color.gray
                                    : Color.accentColor
                                )
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                )
                        }
                        .disabled(
                            selectedSymptoms.isEmpty
                        )

                    }
                    .padding(24)
                }
            }


            .navigationTitle(
                "Log Symptom"
            )
        }
    }









    private func symptomButton(
        _ title: String
    ) -> some View {


        Text(title)
            .font(
                .system(
                    size: 15,
                    weight: .medium
                )
            )
            .foregroundColor(
                primaryText
            )
            .frame(
                maxWidth: .infinity
            )
            .frame(height: 80)
            .background(

                selectedSymptoms.contains(title)

                ? Color.accentColor.opacity(0.15)

                : cardColor
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
            .onTapGesture {


                if selectedSymptoms.contains(title) {

                    selectedSymptoms.remove(title)

                } else {

                    selectedSymptoms.insert(title)
                }
            }
    }
}
