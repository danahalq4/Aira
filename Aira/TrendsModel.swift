
//  TrendsModel.swift
//  Aira
//

import Foundation
import SwiftUI





// MARK: - Top Triggers

struct TopTrigger: Identifiable {

    let id = UUID()


    let icon: String


    let title: String


    // مثال:
    // AQI 91
    // Sleep 4h
    let subtitle: String


    // قوة تأثيره بالرسم
    // جاي من deduction
    let percentage: Double


    let level: TriggerLevel
}
