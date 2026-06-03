//
//  HomeView.swift
//  Aira
//

import SwiftUI
import SwiftData


struct HomeView: View {


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





        let watchSymptoms =
        symptomLogs


            .filter {


                Calendar.current.isDate(

                    $0.date,

                    inSameDayAs:
                    viewModel.calendarVM.selectedDate
                )
            }



            .compactMap { log -> Symptom? in


                guard let name = log.name else {


                    return nil
                }


                return Symptom(

                    name: name,

                    time: log.date,

                    severity:
                    severityFromRaw(
                        log.severityRaw
                    ),

                    isTracked: true,

                    iconSystemName:
                    "lungs.fill"
                )
            }







        let symptomsForDay =
        phoneSymptoms +
        watchSymptoms







        let alertsForDay =
        alertStore.alerts.filter { alert in


            Calendar.current.isDate(

                alert.date,

                inSameDayAs:
                viewModel.calendarVM.selectedDate
            )
        }








        VStack(spacing: 0) {




            // MARK: Header


            HStack {


                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {


                    Text("Symptom")
                        .font(
                            .system(
                                size: 28,
                                weight: .bold
                            )
                        )
                        .foregroundColor(
                            Color("text")
                        )



                    Text("Log")
                        .font(
                            .system(size: 16)
                        )
                        .foregroundColor(
                            Color("small text")
                        )
                }



                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)









            ScrollView(
                showsIndicators: false
            ) {


                VStack(spacing: 16) {




                    CalendarMonthView(

                        viewModel:
                        viewModel.calendarVM,


                        onPlusTapped: {


                            showingAddSheet =
                            true
                        },


                        hasSymptoms: { day in


                            viewModel.symptomsVM
                                .count(
                                    on: day
                                ) > 0


                            ||


                            symptomLogs.contains { log in


                                Calendar.current.isDate(

                                    log.date,

                                    inSameDayAs:
                                    day
                                )
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)








                    HStack {


                        Text(
                            viewModel.selectedDateTitle
                        )
                        .font(
                            .system(
                                size: 16,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(
                            Color("text")
                        )



                        Spacer()



                        Text(
                            viewModel.loggedCountText
                        )
                        .font(
                            .system(size: 13)
                        )
                        .foregroundColor(
                            Color("small text")
                        )
                    }
                    .padding(.horizontal, 16)








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
                    .padding(.horizontal, 16)









                    // MARK: Alert History Cards


                    ForEach(alertsForDay) { alert in


                        Button {


                            selectedAlert =
                            alert



                        } label: {


                            HStack(spacing: 14) {



                                Image(
                                    systemName:
                                    "exclamationmark.triangle.fill"
                                )
                                .font(
                                    .system(size: 24)
                                )
                                .foregroundColor(
                                    alertColor(
                                        alert
                                    )
                                )





                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {



                                    Text("Alert")
                                        .font(
                                            .system(
                                                size: 16,
                                                weight: .semibold
                                            )
                                        )
                                        .foregroundColor(
                                            Color("text")
                                        )



                                    Text(
                                        alert.label
                                    )
                                    .font(
                                        .system(size: 13)
                                    )
                                    .foregroundColor(
                                        Color("small text")
                                    )
                                }




                                Spacer()




                                Text(
                                    "\(Int(alert.score))%"
                                )
                                .font(
                                    .system(
                                        size: 15,
                                        weight: .bold
                                    )
                                )
                                .foregroundColor(
                                    Color("text")
                                )



                                Image(
                                    systemName:
                                    "chevron.right"
                                )
                                .foregroundColor(
                                    Color("small text")
                                )
                            }
                            .padding(16)
                            .background(

                                RoundedRectangle(
                                    cornerRadius: 16
                                )
                                .fill(
                                    Color("card")
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)





                    Spacer(
                        minLength: 24
                    )
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
                _ in



                viewModel.symptomsVM.addMany(

                    names:
                    Array(selectedNames),

                    severity:
                    severityFromIndex(
                        selectedSeverityIndex
                    ),

                    time:
                    startTime,

                    on:
                    viewModel.calendarVM.selectedDate
                )
            }
        }






        .sheet(
            item:
            $selectedAlert
        ) { alert in


            ALERT(

                riskResult:

                    RiskResult(

                        score:
                        alert.score,


                        label:
                        alert.label,


                        triggers:
                        alert.triggers
                    )
            )
        }
    }










    private func alertColor(
        _ alert: AsthmaAlertLog
    ) -> Color {


        alert.score < 25

        ? Color("ColorR")

        : Color("ColorO")
    }








    private func severityFromIndex(
        _ idx: Int
    ) -> Severity {


        switch idx {


        case 0:
            return .mild


        case 1:
            return .moderate


        case 2:
            return .severe


        default:
            return .mild
        }
    }








    private func severityFromRaw(
        _ raw: String?
    ) -> Severity {


        switch raw {


        case "Moderate":

            return .mild


        case "Severe":

            return .moderate


        case "Very Severe":

            return .severe


        default:

            return .mild
        }
    }
}





#Preview {

    HomeView()
}
