//
//  HomeView.swift
//  Aira
//

import SwiftUI
import SwiftData
struct HomeView: View {
    @Query private var symptomLogs: [SymptomLog]
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        let phoneSymptoms = viewModel.symptomsVM.symptoms(
            on: viewModel.calendarVM.selectedDate
        )

        let watchSymptoms = symptomLogs
            .filter {
                Calendar.current.isDate($0.date, inSameDayAs: viewModel.calendarVM.selectedDate)
            }
            .compactMap { log -> Symptom? in
                guard let name = log.name else { return nil }

                return Symptom(
                    name: name,
                    time: log.date,
                    severity: severityFromRaw(log.severityRaw),
                    isTracked: true,
                    iconSystemName: "lungs.fill"
                )
            }

        let symptomsForDay = phoneSymptoms + watchSymptoms

        VStack(spacing: 0) {

            // ── Page Header (matches "Asthma / Overview") ──
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Symptom")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color("text"))
                    Text("Log")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("small text"))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    CalendarMonthView(
                        viewModel: viewModel.calendarVM,
                        onPlusTapped: { showingAddSheet = true },
                        hasSymptoms: { day in
                            viewModel.symptomsVM.count(on: day) > 0 ||
                            symptomLogs.contains { log in
                                Calendar.current.isDate(log.date, inSameDayAs: day)
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // ── Date title + count (card-title style) ──
                    HStack {
                        Text(viewModel.selectedDateTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("text"))
                        Spacer()
                        Text(viewModel.loggedCountText)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color("small text"))
                    }
                    .padding(.horizontal, 16)

                    SymptomsListView(
                        symptoms: symptomsForDay,
                        deleteAction: { symptom in
                            viewModel.symptomsVM.delete(
                                symptom,
                                on: viewModel.calendarVM.selectedDate
                            )
                        }
                    )
                    .padding(.horizontal, 16)

                    Spacer(minLength: 24)
                }
            }
        }
        .background(Color("background").ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddSheet) {
            AddSymptomView { selectedNames, selectedSeverityIndex, startTime, _ in
                let severity = severityFromIndex(selectedSeverityIndex)
                viewModel.symptomsVM.addMany(
                    names: Array(selectedNames),
                    severity: severity,
                    time: startTime,
                    on: viewModel.calendarVM.selectedDate
                )
            }
        }
    }

    private func severityFromIndex(_ idx: Int) -> Severity {
        switch idx {
        case 0:
            return .mild        // Yellow / Moderate
        case 1:
            return .moderate    // Orange / Severe
        case 2:
            return .severe      // Red / Very Severe
        default:
            return .mild
        }
    }
    private func severityFromRaw(_ raw: String?) -> Severity {
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
