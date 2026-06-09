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


    @State private var showingAddSheet = false


    @State private var selectedAlert: AsthmaAlertLog?




    var body: some View {


        let symptomsForDay = symptomLogs

            .filter { log in

                Calendar.current.isDate(
                    log.date,
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
                    iconSystemName: "lungs.fill"
                )
            }





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
                        .font(.largeTitle.weight(.bold))
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
            .padding(.bottom,8)







            ScrollView(showsIndicators: false) {


                VStack(spacing:16) {


                    CalendarMonthView(

                        viewModel:
                            viewModel.calendarVM,


                        onPlusTapped: {

                            showingAddSheet = true
                        },


                        hasSymptoms: { day in

                            symptomLogs.contains { log in

                                Calendar.current.isDate(
                                    log.date,
                                    inSameDayAs: day
                                )
                            }
                        }
                    )
                    .padding(.horizontal,16)
                    .padding(.top,8)








                    HStack {


                        Text(
                            viewModel.selectedDateTitle
                        )
                        .font(.headline)
                        .foregroundColor(
                            Color("text")
                        )


                        Spacer()


                        Text(
                            symptomsForDay.count == 1
                            ? "1 symptom logged"
                            : "\(symptomsForDay.count) symptoms logged"
                        )
                        .font(.footnote)
                        .foregroundColor(
                            Color("small text")
                        )

                    }
                    .padding(.horizontal,16)







                    SymptomsListView(

                        symptoms:
                            symptomsForDay,


                        deleteAction: { symptom in


                            if let log =
                                symptomLogs.first(
                                    where: {
                                        $0.name == symptom.name &&
                                        $0.date == symptom.time
                                    }
                                ) {

                                modelContext.delete(log)

                                try? modelContext.save()
                            }
                        }
                    )
                    .padding(.horizontal,16)








                    // MARK: Alerts

                    ForEach(alertsForDay) { alert in


                        Button {

                            selectedAlert = alert

                        } label: {


                            HStack(spacing:14) {


                                Image(
                                    systemName:
                                    "exclamationmark.triangle.fill"
                                )
                                .font(.title2)
                                .foregroundColor(
                                    alertColor(alert)
                                )



                                VStack(
                                    alignment:.leading,
                                    spacing:4
                                ) {

                                    Text("Alert")
                                        .font(.headline)
                                        .foregroundColor(
                                            Color("text")
                                        )


                                    Text(alert.label)
                                        .font(.footnote)
                                        .foregroundColor(
                                            Color("small text")
                                        )
                                }



                                Spacer()


                                Text(
                                    "\(Int(alert.score))%"
                                )
                                .font(
                                    .subheadline.weight(.bold)
                                )


                                Image(
                                    systemName:
                                    "chevron.right"
                                )
                            }
                            .padding(16)
                            .background(

                                RoundedRectangle(
                                    cornerRadius:16
                                )
                                .fill(
                                    Color("card")
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal,16)




                    Spacer(minLength:24)
                }
            }
        }

        .background(
            Color("background")
                .ignoresSafeArea()
        )







        // ADD SYMPTOM

        .sheet(
            isPresented:
                $showingAddSheet
        ) {


            AddSymptomView {
                selectedNames,
                selectedSeverityIndex,
                startTime,
                _ in



                for name in selectedNames {


                    let log = SymptomLog(

                        date: startTime,

                        name: name,

                        severityRaw:
                            severityFromIndex(
                                selectedSeverityIndex
                            ).rawValue
                    )


                    modelContext.insert(log)
                }


                try? modelContext.save()
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


        case "mild":
            return .mild

        case "moderate":
            return .moderate

        case "severe":
            return .severe


        default:
            return .mild
        }
    }
}






#Preview {

    HomeView()
}
