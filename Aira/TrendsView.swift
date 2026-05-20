//
//  TrendsView.swift
//  Aira
//

import SwiftUI
import SwiftData

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    // Header
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Weekly Trends")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("small text"))
                        Text("This Week")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color("text"))
                    }
                    .padding(.top, 16)

                  
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            viewModel.modelContext = modelContext
            viewModel.loadWeeklySymptomData()
        }
    }

    

    // MARK: - Symptoms Card

    private var symptomsCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Symptoms")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("text"))
                Spacer()
                HStack(spacing: 6) {
                    Circle().fill(Color("ColorB")).frame(width: 8, height: 8)
                    Text("SYM")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color("small text"))
                }
            }

            HStack(alignment: .bottom, spacing: 17) {
                ForEach(viewModel.weeklyData) { item in
                    VStack(spacing: 10) {
                        Capsule()
                            .fill(item.isHighSeverity ? Color("ColorR") : Color("ColorB"))
                            .frame(width: 36, height: 10)
                            .opacity(item.severity <= 0.05 ? 0.25 : 1)
                        Text(item.day)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color("small text"))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
        }
        .padding(20)
        .background(Color("card"))
        .cornerRadius(20)
    }

    // MARK: - Top Triggers Card (HealthKit)

    private var topTriggersCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color("text"))
                Text("Top Triggers")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("text"))
                Spacer()
            }

            VStack(spacing: 12) {
                ForEach(viewModel.topTriggers) { trigger in
                    triggerRow(trigger)
                }
            }
        }
        .padding(20)
        .background(Color("card"))
        .cornerRadius(20)
    }

    private func triggerRow(_ trigger: TopTrigger) -> some View {
        HStack(spacing: 12) {
            // Rounded square icon bubble
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(trigger.iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: trigger.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(trigger.iconColor)
            }

            Text(trigger.title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color("text"))
                .frame(width: 110, alignment: .leading)

            ProgressView(value: trigger.percentage)
                .tint(Color("ColorB"))
                .frame(height: 8)

            Text("\(Int(trigger.percentage * 100))%")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color("small text"))
                .frame(width: 42, alignment: .trailing)
        
        }
    }

    private func levelColor(_ level: TriggerLevel) -> Color {
        switch level {
        case .low:      return Color("ColorG")
        case .moderate: return Color("ColorY")
        case .high:     return Color("ColorR")
        }
    }
}

#Preview {
    TrendsView()
}
