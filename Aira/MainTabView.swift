//
//  MainTabView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 14/05/2026.
//


import SwiftUI

// MARK: - Main Tab Container
struct RootTabView: View {
    var body: some View {
        TabView {
            // Tab 1
            AsthmaOverviewView()
                .tabItem {
                    Label("Air", systemImage: "wind")
                }
            
            // Tab 2
            CalendarMonthView(viewModel: CalendarViewModel())
                .tabItem {
                    Label("Log", systemImage: "clipboard")
                }
            
            // Tab 3
            TrendsScreenView()
                .tabItem {
                    Label("Trends", systemImage: "chart.bar.xaxis")
                }
        }
        .accentColor(.blue) // This makes the active tab blue so you know it's working
    }
}

// MARK: - Air View
struct AirScreenView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: "wind")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(.blue)
                    Text("Air Quality")
                        .font(.title2).bold()
                    Text("Weather and AQI data goes here")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Air")
        }
    }
}

// MARK: - Symptoms View
struct SymptomsScreenView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(.secondary)
                    Text("Log")
                        .font(.title2)
                    Text("Track your symptoms here")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Log")
        }
    }
}

// MARK: - Trends View
struct TrendsScreenView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(.secondary)
                    Text("Trends")
                        .font(.title2)
                    Text("View your progress over time")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Trends")
        }
    }
}

// MARK: - Previews
// Previews updated to use unique view names to avoid type collisions
#Preview("Full App") {
    RootTabView()
}

#Preview("Air Screen") {
    AirScreenView()
}

#Preview("Log Screen") {
    SymptomsScreenView()
}

#Preview("Trends Screen") {
    TrendsScreenView()
}

