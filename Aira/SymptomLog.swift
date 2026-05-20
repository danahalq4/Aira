//
//  SymptomLog.swift
//  Aira
//

import Foundation
import SwiftData

@Model
final class SymptomLog {
    // Required fields
    var id: UUID
    var date: Date

    // Optional fields you may use later
    var name: String?
    var severityRaw: String?

    init(id: UUID = UUID(), date: Date, name: String? = nil, severityRaw: String? = nil) {
        self.id = id
        self.date = date
        self.name = name
        self.severityRaw = severityRaw
    }
}
