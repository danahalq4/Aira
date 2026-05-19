//
//  HomeView.swift
//  Aira
//

import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        let symptomsForDay = viewModel.symptomsVM.symptoms(
            on: viewModel.calendarVM.selectedDate
        )

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
                            viewModel.symptomsVM.count(on: day) > 0
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
                        toggleAction: { symptom in
                            viewModel.symptomsVM.toggleTracked(
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
        case 0: return .mild
        case 1: return .mild
        case 2: return .moderate
        case 3: return .severe
        default: return .mild
        }
    }
}

#Preview {
    HomeView()
}
