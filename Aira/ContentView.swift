//
//  ContentView.swift
//  Aira
//
//  Created by Danah AlQahtani on 24/11/1447 AH.
//
import SwiftUI

// MARK: - Main Tab Container
struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1
            AirView()
                .tabItem {
                    Label("Air", systemImage: "wind")
                }
            
            // Tab 2
            SymptomsView()
                .tabItem {
                    Label("Symptoms", systemImage: "clipboard")
                }
            
            // Tab 3
            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.bar.xaxis")
                }
        }
    }
}

// MARK: - Air View
struct AirView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "wind")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(.secondary)
                Text("Air")
                    .font(.title2)
                    .foregroundStyle(.primary)
                Text("Air Quality and Weather Content")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Symptoms View
struct SymptomsView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "clipboard")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(.secondary)
                Text("Symptoms")
                    .font(.title2)
                    .foregroundStyle(.primary)
                Text("Track your symptoms here")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
//
//// MARK: - Trends View
struct PreTrendsView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(.secondary)
                Text("Trends")
                    .font(.title2)
                    .foregroundStyle(.primary)
                Text("View your progress over time")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Previews
// Preview the whole app with the Tab Bar
#Preview("Full App") {
    MainTabView()
}

#Preview("Air Screen")      { AsthmaOverviewView() }
#Preview("Symptoms Screen") { AddSymptomView() }
#Preview("Trends Screen")   { TrendsView() }
