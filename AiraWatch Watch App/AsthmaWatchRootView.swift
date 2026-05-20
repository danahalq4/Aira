//
//  AsthmaWatchRootView.swift
//  Aira
//
//  Created by aeshah mohammed alabdulkarim on 20/05/2026.
//
import SwiftUI

struct AsthmaWatchRootView: View {
    @StateObject private var viewModel = AsthmaOverviewViewModel()

    var body: some View {
        TabView {
            AsthmaWatchOverviewView(viewModel: viewModel)
            WatchAirDetailView(triggers: viewModel.triggers, score: viewModel.score)
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    AsthmaWatchRootView()
}
