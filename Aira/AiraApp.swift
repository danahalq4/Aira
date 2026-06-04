//
//  AiraApp.swift//
//  AiraApp.swift
//  Aira
//

import SwiftUI
import SwiftData


@main
struct AiraApp: App {



    // MARK: - Init

    init() {


        NotificationService.shared
            .requestPermission()
    }






    var body: some Scene {


        WindowGroup {


            RootView()
        }


        .modelContainer(
            for: [
                SymptomLog.self
            ]
        )
    }
}









struct RootView: View {


    @Environment(\.modelContext)
    private var modelContext






    var body: some View {


        RootTabView()


            .onAppear {


                // Apple Watch connection

                _ =
                WatchConnectivityManager.shared



                WatchConnectivityManager
                    .shared
                    .modelContext =
                modelContext



                print(
                    "IPHONE WC MANAGER CONNECTED"
                )
            }
    }
}
