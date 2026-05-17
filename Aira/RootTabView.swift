//
//  MainTabView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 14/05/2026.
//
import SwiftUI

// MARK: - Root Tab Container
struct RootTabView: View {
    var body: some View {
        TabView {
            // Tab 1 - Your actual Air/Asthma Page
            AsthmaOverviewView()
                .tabItem {
                    Label("Air", systemImage: "wind")
                }
            
            // Tab 2 - Your Log/Symptoms Page
            HomeView(viewModel: HomeViewModel())
                .tabItem {
                    Label("Log", systemImage: "clipboard")
                }
            
            // Tab 3 - Your Trends Page
            TrendsScreenView()
                .tabItem {
                    Label("Trends", systemImage: "chart.bar.xaxis")
                }
        }
        // Tint color for the active icon
        .accentColor(.blue)
    }
}

// MARK: - Symptoms View (Placeholder)
struct SymptomsScreenView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "clipboard")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Symptom Log")
                    .font(.title2)
                Text("Your logging UI will go here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Log")
        }
    }
}

// MARK: - Trends View (Placeholder)
struct TrendsScreenView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Trends")
                    .font(.title2)
                Text("Your charts will go here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Trends")
        }
    }
}

// MARK: - Previews
#Preview {
    RootTabView()
}

