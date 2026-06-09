//
//  HomeView.swift
//  Aira
//

import SwiftUI
import SwiftData


struct HomeView: View {


    @Environment(\.modelContext)
    private var modelContext


    @Query private var symptomLogs: [SymptomLog]


    @StateObject private var viewModel =
    HomeViewModel()


    @ObservedObject private var alertStore =
    AlertHistoryStore.shared


    @State private var showingAddSheet =
    false


    @State private var selectedAlert:
    AsthmaAlertLog?





    var body: some View {


        let phoneSymptoms =
        viewModel.symptomsVM.symptoms(
            on: viewModel.calendarVM.selectedDate
        )


        let savedSymptoms =
        symptomLogs

            .filter {

                Calendar.current.isDate(

                    $0.date,

                    inSameDayAs:
                        viewModel.calendarVM.selectedDate
                )
            }

            .compactMap { log -> Symptom? in


                guard let name =
                        log.name
                else {

                    return nil
                }


                return Symptom(

                    name:
                        name,

                    time:
                        log.date,

                    severity:
                        severityFromRaw(
                            log.severityRaw
                        ),

                    isTracked:
                        true,

                    iconSystemName:
                        "lungs.fill"
                )
            }





        let symptomsForDay =
        phoneSymptoms +
        savedSymptoms







        VStack(spacing: 0) {




            HStack {


                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {


                    Text("Symptom")
                        .font(
                            .largeTitle.weight(.bold)
                        )
                        .foregroundColor(
                            Color("text")
                        )


                    Text("Log")
                        .font(.body)
                        .foregroundColor(
                            Color("small text")
                        )
                }


                Spacer()
            }
            .padding(.horizontal,20)
            .padding(.top,16)








            ScrollView(
                showsIndicators: false
            ) {


                VStack(spacing:16) {




                    CalendarMonthView(

                        viewModel:
                            viewModel.calendarVM,


                        onPlusTapped: {

                            showingAddSheet =
                            true
                        },


                        hasSymptoms: { day in


                            symptomLogs.contains {

                                Calendar.current.isDate(

                                    $0.date,

                                    inSameDayAs:
                                        day
                                )
                            }
                        }
                    )
                    .padding(.horizontal,16)







                    SymptomsListView(

                        symptoms:
                            symptomsForDay,


                        deleteAction: { symptom in


                            viewModel.symptomsVM.delete(

                                symptom,

                                on:
                                    viewModel.calendarVM.selectedDate
                            )

                        }
                    )
                    .padding(.horizontal,16)



                }
            }
        }



        .background(

            Color("background")
                .ignoresSafeArea()
        )






        .sheet(

            isPresented:
                $showingAddSheet

        ) {



            AddSymptomView {

                selectedNames,
                selectedSeverityIndex,
                startTime,
                endTime in





                let severity =
                severityFromIndex(
                    selectedSeverityIndex
                )






                // يخلي الاختيار واللون والواجهة زي قبل
                viewModel.symptomsVM.addMany(

                    names:
                        Array(selectedNames),

                    severity:
                        severity,

                    time:
                        startTime,

                    on:
                        viewModel.calendarVM.selectedDate
                )






                // الحفظ الدائم
                for name in selectedNames {


                    let log =
                    SymptomLog(

                        date:
                            startTime,

                        name:
                            name,

                        severityRaw:
                            severity.rawValue
                    )


                    modelContext.insert(log)
                }






                do {

                    try modelContext.save()


                    print(
                        "SYMPTOM SAVED"
                    )

                } catch {


                    print(
                        "SAVE ERROR:",
                        error.localizedDescription
                    )
                }
            }
        }
    }






    private func severityFromIndex(
        _ index: Int
    ) -> Severity {


        switch index {


        case 0:
            return .mild


        case 1:
            return .moderate


        default:
            return .severe
        }
    }






    private func severityFromRaw(
        _ raw: String?
    ) -> Severity {


        Severity(
            rawValue:
                raw ?? ""
        )
        ??
        .moderate
    }
}
