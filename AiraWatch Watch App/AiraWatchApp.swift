//
//  AiraWatchApp.swift
//  AiraWatch Watch App
//
//  Created by aeshah mohammed alabdulkarim on 19/05/2026.
//
import SwiftUI
import WatchConnectivity

@main
struct AiraWatch_Watch_AppApp: App {

    init() {
        _ = WatchConnectivityManager.shared
    }

    var body: some Scene {
        WindowGroup {
            AsthmaWatchRootView()
        }
    }
}
