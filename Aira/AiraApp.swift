//
//  AiraApp.swift
//  Aira
//
//  Created by Danah AlQahtani on 24/11/1447 AH.
//
//
//import SwiftUI
//
//@main
//struct AiraApp: App {
//    var body: some Scene {
//        WindowGroup {
//            RootTabView()
//        }
//    }
//}
import SwiftUI
import SwiftData

@main
struct AiraApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [SymptomLog.self])
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        RootTabView()
            .onAppear {
                _ = WatchConnectivityManager.shared
                WatchConnectivityManager.shared.modelContext = modelContext
                print("IPHONE WC MANAGER CONNECTED")
            }
    }
}
