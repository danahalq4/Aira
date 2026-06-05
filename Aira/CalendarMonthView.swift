//
//  CalendarMonthView.swift
//  Aira
//
//  Created by MVVM.
//

import SwiftUI

struct CalendarMonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var onPlusTapped: (() -> Void)? = nil

    var hasSymptoms: ((Date) -> Bool)? = nil

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6, alignment: .center), count: 7)

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Spacer()
                Button {
                    onPlusTapped?()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                }
                .accessibilityLabel("Add")
            }
            .padding(.horizontal, 4)

            HStack(alignment: .center, spacing: 0) {
                Button {
                    viewModel.goToPreviousMonth()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("text"))
                        .padding(8)
                }

                Spacer(minLength: 8)

                Text(viewModel.monthTitle())
                    .font(.headline)
                    .foregroundColor(Color("text"))

                Spacer(minLength: 8)

                Button {
                    viewModel.goToNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("text"))
                        .padding(8)
                }
            }
            .padding(.horizontal, 2)

            HStack(spacing: 0) {
                ForEach(viewModel.weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(Color("small text"))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(viewModel.daysInMonth(), id: \.self) { date in
                    DayCell(
                        date: date,
                        isCurrentMonth: viewModel.isSameMonth(date),
                        isSelected: viewModel.isSelected(date),
                        hasSymptoms: hasSymptoms?(date) ?? false
                    )
                    .onTapGesture {
                        viewModel.select(date)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color("card"))
            )
        }
    }

    private struct DayCell: View {
        let date: Date
        let isCurrentMonth: Bool
        let isSelected: Bool
        let hasSymptoms: Bool
        private let calendar = Calendar.current

        var body: some View {
            let day = calendar.component(.day, from: date)

            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 30, height: 30)
                    }
                    Text("\(day)")
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? Color.white : Color("text"))
                        .frame(width: 32, height: 32)
                }

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 5, height: 5)
                    .opacity(hasSymptoms ? 1 : 0)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .opacity(isCurrentMonth ? 1 : 0.4)
        }
    }
}

#Preview {
    CalendarMonthView(viewModel: CalendarViewModel(), hasSymptoms: { _ in Bool.random() })
        .padding()
        .background(Color("background"))
}
