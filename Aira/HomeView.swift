//
//  HomeView.swift
//  Aira
//
//  Created by MVVM.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingAddSheet = false

    var body: some View {
        VStack(spacing: 16) {
            CalendarMonthView(viewModel: viewModel.calendarVM, onPlusTapped: {
                showingAddSheet = true
            })
                .padding(.horizontal, 16)
                .padding(.top, 8)

            HStack {
                Text(viewModel.selectedDateTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color("text"))
                Spacer()
                Text(viewModel.loggedCountText)
                    .font(.caption)
                    .foregroundColor(Color("small text"))
            }
            .padding(.horizontal, 16)

            SymptomsListView(
                symptoms: viewModel.symptomsVM.symptoms(on: viewModel.calendarVM.selectedDate),
                toggleAction: { symptom in
                    viewModel.symptomsVM.toggleTracked(symptom, on: viewModel.calendarVM.selectedDate)
                }
            )
            .padding(.horizontal, 16)

            Spacer(minLength: 12)
        }
        .background(Color("background").ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddSheet) {
            AddSymptomView { selectedNames, selectedSeverityIndex, startTime, _ in
                let severity = severityFromIndex(selectedSeverityIndex)
                let date = viewModel.calendarVM.selectedDate
                viewModel.symptomsVM.addMany(
                    names: Array(selectedNames),
                    severity: severity,
                    time: startTime,
                    on: date
                )
            }
        }
    }

    private func severityFromIndex(_ idx: Int) -> Severity {
        switch idx {
        case 0: return .mild   // None -> treat as mild
        case 1: return .moderate
        case 2: return .severe
        default: return .moderate
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

