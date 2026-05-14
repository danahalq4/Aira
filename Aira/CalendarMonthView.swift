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

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6, alignment: .center), count: 7)

    var body: some View {
        VStack(spacing: 6) {
            // زر + مستقل في الأعلى، كبير ومثبت يمين
            HStack {
                Spacer()
                Button {
                    onPlusTapped?()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold)) // أيقونة كبيرة
                        .foregroundColor(.white)                 // الأيقونة بيضاء
                        .frame(width: 42, height: 42)            // زر كبير
                        .background(
                            Circle()
                                .fill(Color.accentColor)         // الخلفية من AccentColor
                        )
                }
                .accessibilityLabel("Add")
            }
            .padding(.horizontal, 4)

            // شريط العنوان مع أسهم التنقل
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

            // عناوين أيام الأسبوع
            HStack(spacing: 0) {
                ForEach(viewModel.weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(Color("small text"))
                        .frame(maxWidth: .infinity)
                }
            }

            // بطاقة التقويم
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
                        .fill(Color.accentColor) // لون التحديد من Assets
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

