//
//  RiskScoreEngine.swift
//  Aira
//

import Foundation

// MARK: - Input snapshot

struct RiskInput {
    // Environment
    var temperature_2m: Double?
    var relative_humidity_2m: Double?           // 0–100 (%)
    // Pollen inputs
    var pollenCount: Int?           // dominant grains/m³ (highest of three)
    var treePollen: Int?
    var weedPollen: Int?
    var grassPollen: Int?
    var aqi: Int?

    // Health
    var sleepHours: Double?
    var heartRate: Double?
    var steps: Double?
    var respiratoryRate: Double?
}

// MARK: - Output

struct RiskResult {
    let score: Double                    // 0–100 (higher = safer)
    let label: String                    // "Good", "Fair", "Poor"
    let triggers: [RiskTrigger]          // full list for detail view (includes 3 pollen items)
}

struct RiskTrigger {
    let name: String
    let icon: String
    let level: TriggerLevel
    let displayValue: String             // "32°C", "AQI 45", "6.2 hrs"
    let deduction: Int                   // points removed from 100
    let reasonText: String
}

// MARK: - Engine

enum RiskScoreEngine {

    static func calculate(from input: RiskInput) -> RiskResult {
        var triggers: [RiskTrigger] = []
        var totalDeduction = 0

        // ── 1. Temperature (max –20) ──────────────────────────────
        if let temp = input.temperature_2m {
            let (level, reason, deduction) = evaluateTemperature(temp)
            triggers.append(RiskTrigger(
                name: "Temperature",
                icon: "thermometer.medium",
                level: level,
                displayValue: String(format: "%.0f°C", temp),
                deduction: deduction,
                reasonText: reason
            ))
            totalDeduction += deduction
        }

        // ── 2. Humidity (max –15) ─────────────────────────────────
        if let hum = input.relative_humidity_2m {
            let pct = hum
            let (level, reason, deduction) = evaluateHumidity(pct)
            triggers.append(RiskTrigger(
                name: "Humidity",
                icon: "drop.fill",
                level: level,
                displayValue: String(format: "%.0f%%", pct),
                deduction: deduction,
                reasonText: reason
            ))
            totalDeduction += deduction
        }

        // ── 3. Pollen — score uses dominant only; details show 3 items ──
        // Score impact (max –20) uses dominant to avoid double-penalizing
        if let dominant = input.pollenCount {
            let (level, reason, deduction) = evaluatePollen(dominant)
            // We add a summary trigger for ring segmentation clarity
            triggers.append(RiskTrigger(
                name: "Pollen (Total)",
                icon: "leaf.fill",
                level: level,
                displayValue: "\(dominant) gr/m³",
                deduction: deduction,
                reasonText: reason
            ))
            totalDeduction += deduction
        }

        // Detail items (no additional deduction to score — informational)
        // If you want them to also affect the ring segmentation visually without changing score,
        // set deduction to 0 for each.
        if let v = input.treePollen {
            let (lvl, reason, _) = evaluatePollen(v)
            triggers.append(RiskTrigger(
                name: "Tree Pollen",
                icon: "leaf.fill",
                level: lvl,
                displayValue: "\(v) gr/m³",
                deduction: 0,
                reasonText: reason
            ))
        }
        if let v = input.weedPollen {
            let (lvl, reason, _) = evaluatePollen(v)
            triggers.append(RiskTrigger(
                name: "Weed Pollen",
                icon: "leaf",
                level: lvl,
                displayValue: "\(v) gr/m³",
                deduction: 0,
                reasonText: reason
            ))
        }
        if let v = input.grassPollen {
            let (lvl, reason, _) = evaluatePollen(v)
            triggers.append(RiskTrigger(
                name: "Grass Pollen",
                icon: "leaf.arrow.circlepath",
                level: lvl,
                displayValue: "\(v) gr/m³",
                deduction: 0,
                reasonText: reason
            ))
        }

        // ── 4. Air Quality (max –20) ──────────────────────────────
        if let aqi = input.aqi {
            let (level, reason, deduction) = evaluateAQI(aqi)
            triggers.append(RiskTrigger(
                name: "Air Quality",
                icon: "aqi.low",
                level: level,
                displayValue: "AQI \(aqi)",
                deduction: deduction,
                reasonText: reason
            ))
            totalDeduction += deduction
        }

        // ── 5. Sleep (max –15) — affects score only, shown in Trends ──
        if let sleep = input.sleepHours {
            let (level, reason, deduction) = evaluateSleep(sleep)
            triggers.append(RiskTrigger(
                name: "Sleep",
                icon: "moon.zzz.fill",
                level: level,
                displayValue: String(format: "%.1f hrs", sleep),
                deduction: deduction,
                reasonText: reason
            ))
            totalDeduction += deduction
        }

        // ── 6. Heart Rate (max –10) ───────────────────────────────
        if let hr = input.heartRate {
            let (level, reason, deduction) = evaluateHeartRate(hr)
            triggers.append(RiskTrigger(
                name: "Heart Rate",
                icon: "heart.fill",
                level: level,
                displayValue: String(format: "%.0f bpm", hr),
                deduction: deduction,
                reasonText: reason
            ))
            totalDeduction += deduction
        }

        let score = max(0, min(100, Double(100 - totalDeduction)))
        let label = scoreLabel(score)

        return RiskResult(score: score, label: label, triggers: triggers)
    }

    // MARK: - Label

    static func scoreLabel(_ score: Double) -> String {
        switch score {
        case 80...100: return "Good"
        case 60..<80:  return "Fair"
        case 40..<60:  return "Moderate"
        default:       return "Poor"
        }
    }

    // MARK: - Individual Evaluators

    private static func evaluateTemperature(_ t: Double) -> (TriggerLevel, String, Int) {
        switch t {
        case ..<0:
            return (.high,     "Very cold — airway irritation risk", 15)
        case 0..<10:
            return (.high,     "Cold air — can trigger bronchospasm", 12)
        case 10..<18:
            return (.moderate, "Cool — worth monitoring",            8)
        case 18..<26:
            return (.low,      "Comfortable range",                  2)
        case 26..<34:
            return (.moderate, "Warm — slightly elevated",           10)
        default:
            return (.high,     "Hot — increases airway inflammation", 15)
        }
    }

    private static func evaluateHumidity(_ pct: Double) -> (TriggerLevel, String, Int) {
        switch pct {
        case ..<30:
            return (.high,     "Very dry — irritates airways",       12)
        case 30..<40:
            return (.moderate, "Slightly dry — worth monitoring",    6)
        case 40..<60:
            return (.low,      "Comfortable range",                  2)
        case 60..<75:
            return (.moderate, "Elevated — mold/dust mite risk",     8)
        default:
            return (.high,     "Very humid — mold spore risk",       12)
        }
    }

    private static func evaluatePollen(_ count: Int) -> (TriggerLevel, String, Int) {
        switch count {
        case 0...20:
            return (.low,      "Low — not a concern today",          2)
        case 21...80:
            return (.moderate, "Moderate — limit outdoor exposure",  10)
        default:
            return (.high,     "High — stay indoors if possible",    18)
        }
    }

    private static func evaluateAQI(_ aqi: Int) -> (TriggerLevel, String, Int) {
        switch aqi {
        case 0...50:
            return (.low,      "Good air quality",                   2)
        case 51...100:
            return (.moderate, "Acceptable — sensitive groups caution", 10)
        case 101...150:
            return (.high,     "Unhealthy for sensitive groups",     15)
        default:
            return (.high,     "Unhealthy — avoid outdoor activity", 20)
        }
    }

    private static func evaluateSleep(_ hours: Double) -> (TriggerLevel, String, Int) {
        switch hours {
        case ..<5:
            return (.high,     "Poor sleep — major asthma aggravator", 14)
        case 5..<7:
            return (.moderate, "Below recommended — worth improving",  7)
        default:
            return (.low,      "Good sleep quality",                    1)
        }
    }

    private static func evaluateHeartRate(_ hr: Double) -> (TriggerLevel, String, Int) {
        switch hr {
        case ..<60:
            return (.low,      "Normal resting rate",                2)
        case 60..<80:
            return (.low,      "Normal resting rate",                2)
        case 80..<100:
            return (.moderate, "Slightly elevated",                  5)
        default:
            return (.high,     "Elevated — may precede flare-up",    9)
        }
    }
}
