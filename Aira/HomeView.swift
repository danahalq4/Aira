//
//  HomeView.swift
//  Aira
//
//  Created by MVVM.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 16) {
            CalendarMonthView(viewModel: viewModel.calendarVM)
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
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

