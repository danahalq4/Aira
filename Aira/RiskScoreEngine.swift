//
//  RiskScoreEngine.swift
//  Aira
//
import Foundation

// MARK: - Input snapshot

struct RiskInput {
    // Environment only — sleep/heart rate removed from air risk score
    var temperature_2m: Double?
    var relative_humidity_2m: Double?
    var pollenCount: Int?
    var treePollen: Int?
    var weedPollen: Int?
    var grassPollen: Int?
    var aqi: Int?

    // Health — kept in model for future Trends use, not scored here
    var sleepHours: Double?
    var heartRate: Double?
    var steps: Double?
    var respiratoryRate: Double?
}

// MARK: - Output

struct RiskResult {
    let score: Double           // 0–100 (higher = safer)
    let label: String
    let triggers: [RiskTrigger]
}

struct RiskTrigger {
    let name: String
    let icon: String
    let level: TriggerLevel
    let displayValue: String
    let deduction: Int
    let reasonText: String
}

// MARK: - Engine

enum RiskScoreEngine {

    // ─────────────────────────────────────────────
    // Max penalty budget per factor (total = 90,
    // leaving 10 as a baseline floor so score
    // never hits 0 unless everything is worst-case)
    //
    //  Pollen       → 30  (primary outdoor trigger)
    //  Air Quality  → 25  (direct lung irritant)
    //  Humidity     → 20  (both extremes harmful)
    //  Temperature  → 15  (extremes only, mild = 0)
    // ─────────────────────────────────────────────

    static func calculate(from input: RiskInput) -> RiskResult {
        var triggers: [RiskTrigger] = []
        var totalDeduction = 0

        // ── 1. Pollen (max –30) ───────────────────
        if let dominant = input.pollenCount {
            let (level, reason, deduction) = evaluatePollen(dominant)
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

        // Sub-pollen rows — informational only, deduction: 0
        if let v = input.treePollen {
            let (lvl, reason, _) = evaluatePollen(v)
            triggers.append(RiskTrigger(name: "Tree Pollen",  icon: "leaf.fill",
                                        level: lvl, displayValue: "\(v) gr/m³",
                                        deduction: 0, reasonText: reason))
        }
        if let v = input.weedPollen {
            let (lvl, reason, _) = evaluatePollen(v)
            triggers.append(RiskTrigger(name: "Weed Pollen",  icon: "leaf",
                                        level: lvl, displayValue: "\(v) gr/m³",
                                        deduction: 0, reasonText: reason))
        }
        if let v = input.grassPollen {
            let (lvl, reason, _) = evaluatePollen(v)
            triggers.append(RiskTrigger(name: "Grass Pollen", icon: "leaf.arrow.circlepath",
                                        level: lvl, displayValue: "\(v) gr/m³",
                                        deduction: 0, reasonText: reason))
        }

        // ── 2. Air Quality (max –25) ──────────────
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

        // ── 3. Humidity (max –20) ─────────────────
        if let hum = input.relative_humidity_2m {
            let (level, reason, deduction) = evaluateHumidity(hum)
            triggers.append(RiskTrigger(
                name: "Humidity",
                icon: "drop.fill",
                level: level,
                displayValue: String(format: "%.0f%%", hum),
                deduction: deduction,
                reasonText: reason
            ))
            totalDeduction += deduction
        }

        // ── 4. Temperature (max –15) ──────────────
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

        let score = max(0, min(100, Double(100 - totalDeduction)))
        return RiskResult(score: score, label: scoreLabel(score), triggers: triggers)
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

    // MARK: - Evaluators

    // Pollen — max 30
    // Based on European pollen calendar thresholds (grains/m³)
    private static func evaluatePollen(_ count: Int) -> (TriggerLevel, String, Int) {
        switch count {
        case 0...10:   return (.low,      "Very low — no concern",                  0)
        case 11...30:  return (.low,      "Low — minimal impact",                   5)
        case 31...80:  return (.moderate, "Moderate — limit prolonged outdoor time", 15)
        default:       return (.high,     "High — stay indoors if possible",         30)
        }
    }

    // AQI (US EPA scale) — max 25
    private static func evaluateAQI(_ aqi: Int) -> (TriggerLevel, String, Int) {
        switch aqi {
        case 0...50:   return (.low,      "Good — air quality is healthy",              0)
        case 51...100: return (.moderate, "Moderate — sensitive groups take care",      10)
        case 101...150:return (.high,     "Unhealthy for sensitive groups",             18)
        default:       return (.high,     "Unhealthy — avoid outdoor activity",         25)
        }
    }

    // Humidity — max 20
    // Ideal range for asthma is 40–60%
    private static func evaluateHumidity(_ pct: Double) -> (TriggerLevel, String, Int) {
        switch pct {
        case ..<20:    return (.high,     "Very dry — severely irritates airways",      20)
        case 20..<35:  return (.high,     "Dry — airways dry out faster",               14)
        case 35..<40:  return (.moderate, "Slightly dry — worth monitoring",             7)
        case 40...60:  return (.low,      "Ideal range — comfortable for breathing",     0)
        case 61..<75:  return (.moderate, "Elevated — dust mite and mold risk",          8)
        default:       return (.high,     "Very humid — mold spore risk",               16)
        }
    }

    // Temperature — max 15
    // Mild temps (18–26°C) should not penalize at all
    private static func evaluateTemperature(_ t: Double) -> (TriggerLevel, String, Int) {
        switch t {
        case ..<0:     return (.high,     "Freezing — severe airway constriction risk", 15)
        case 0..<8:    return (.high,     "Very cold — cold air triggers bronchospasm",  12)
        case 8..<14:   return (.moderate, "Cold — keep inhaler warm and accessible",      6)
        case 14...32:  return (.low,      "Comfortable — no impact on breathing",         0)
        case 33..<38:  return (.moderate, "Hot — may aggravate symptoms",                 8)
        default:       return (.high,     "Very hot — increases airway inflammation",     15)
        }
    }
}
