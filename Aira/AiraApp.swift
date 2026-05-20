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
            RootTabView()
        }
        .modelContainer(for: [SymptomLog.self])
    }
}
