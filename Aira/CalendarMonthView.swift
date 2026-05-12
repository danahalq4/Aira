//
//  CalendarMonthView.swift
//  Aira
//
//  Created by MVVM.
//

import SwiftUI

struct CalendarMonthView: View {
    @ObservedObject var viewModel: CalendarViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6, alignment: .center), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    viewModel.goToPreviousMonth()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("text"))
                        .padding(8)
                }
                Spacer()
                Text(viewModel.monthTitle())
                    .font(.headline)
                    .foregroundColor(Color("text"))
                Spacer()
                Button {
                    viewModel.goToNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("text"))
                        .padding(8)
                }
            }

            // Weekday symbols
            HStack {
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
                        isSelected: viewModel.isSelected(date)
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
        private let calendar = Calendar.current

        var body: some View {
            let day = calendar.component(.day, from: date)

            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color("text")) // استخدام لون النص كبديل لـ Accent
                        .frame(width: 30, height: 30)
                }
                Text("\(day)")
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? Color.white : Color("text"))
                    .frame(width: 32, height: 32)
            }
            .frame(maxWidth: .infinity, minHeight: 36)
            .opacity(isCurrentMonth ? 1 : 0.4)
        }
    }
}

#Preview {
    CalendarMonthView(viewModel: CalendarViewModel())
        .padding()
        .background(Color("background"))
}
