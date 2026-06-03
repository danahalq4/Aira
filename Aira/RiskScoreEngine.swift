//
//  RiskScoreEngine.swift
//  Aira
//

import Foundation


// MARK: - Input

struct RiskInput {

    // Environment

    var temperature_2m: Double?
    var relative_humidity_2m: Double?
    var windSpeed: Double?
    var aqi: Int?
    var pollenRisk: String?

    var treePollenCount: Double?
    var grassPollenCount: Double?
    var weedPollenCount: Double?



    // Health

    var sleepHours: Double?
    var heartRate: Double?
    var steps: Double?
    var respiratoryRate: Double?
}



// MARK: - Result

struct RiskResult {

    let score: Double
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





enum RiskScoreEngine {



    static func calculate(
        from input: RiskInput
    ) -> RiskResult {



        var triggers: [RiskTrigger] = []

        var totalDeduction = 0




        // MARK: AQI


        if let aqi = input.aqi {


            let r = evaluateAQI(aqi)


            triggers.append(
                RiskTrigger(
                    name: "Air Quality",
                    icon: "aqi.low",
                    level: r.0,
                    displayValue: "AQI \(aqi)",
                    deduction: r.2,
                    reasonText: r.1
                )
            )


            totalDeduction += r.2
        }







        // MARK: Humidity


        if let humidity =
            input.relative_humidity_2m {



            let r =
            evaluateHumidity(humidity)



            triggers.append(

                RiskTrigger(
                    name: "Humidity",
                    icon: "drop.fill",
                    level: r.0,
                    displayValue: "\(Int(humidity))%",
                    deduction: r.2,
                    reasonText: r.1
                )
            )



            totalDeduction += r.2
        }








        // MARK: Temperature


        if let temp =
            input.temperature_2m {



            let r =
            evaluateTemperature(temp)



            triggers.append(

                RiskTrigger(
                    name: "Temperature",
                    icon: "thermometer.medium",
                    level: r.0,
                    displayValue: "\(Int(temp))°C",
                    deduction: r.2,
                    reasonText: r.1
                )
            )



            totalDeduction += r.2
        }








        // MARK: Wind


        if let wind =
            input.windSpeed {



            let r =
            evaluateWind(wind)



            triggers.append(

                RiskTrigger(
                    name: "Wind Speed",
                    icon: "wind",
                    level: r.0,
                    displayValue: "\(Int(wind)) km/h",
                    deduction: r.2,
                    reasonText: r.1
                )
            )



            totalDeduction += r.2
        }








        // MARK: Pollen


        if let pollen =
            input.pollenRisk {



            let level: TriggerLevel

            let deduction: Int



            switch pollen {


            case "High":

                level = .high
                deduction = 20



            case "Moderate":

                level = .moderate
                deduction = 10



            default:

                level = .low
                deduction = 0
            }




            triggers.append(

                RiskTrigger(

                    name: "Pollen",

                    icon: "leaf.fill",

                    level: level,

                    displayValue: pollen,

                    deduction: deduction,

                    reasonText:

                    """
                    Tree pollen: \(Int(input.treePollenCount ?? 0))
                    Grass pollen: \(Int(input.grassPollenCount ?? 0))
                    Weed pollen: \(Int(input.weedPollenCount ?? 0))
                    """
                )
            )



            totalDeduction += deduction
        }









        // MARK: Sleep


        if let sleep = input.sleepHours,
           sleep >= 0 {



            let r =
            evaluateSleep(sleep)



            triggers.append(

                RiskTrigger(

                    name: "Sleep",

                    icon: "bed.double.fill",

                    level: r.0,

                    displayValue: "\(Int(sleep)) h",

                    deduction: r.2,

                    reasonText: r.1
                )
            )



            totalDeduction += r.2
        }









        // MARK: Heart


        if let heart = input.heartRate,
           heart >= 0 {



            let r =
            evaluateHeart(heart)



            triggers.append(

                RiskTrigger(

                    name: "Heart Rate",

                    icon: "heart.fill",

                    level: r.0,

                    displayValue: "\(Int(heart)) bpm",

                    deduction: r.2,

                    reasonText: r.1
                )
            )



            totalDeduction += r.2
        }









        // MARK: Respiratory


        if let resp = input.respiratoryRate,
           resp >= 0 {



            let r =
            evaluateResp(resp)



            triggers.append(

                RiskTrigger(

                    name: "Respiratory Rate",

                    icon: "lungs.fill",

                    level: r.0,

                    displayValue: "\(Int(resp))/min",

                    deduction: r.2,

                    reasonText: r.1
                )
            )



            totalDeduction += r.2
        }









        // MARK: Steps


        if let steps = input.steps,
           steps >= 0 {



            let r =
            evaluateSteps(steps)



            triggers.append(

                RiskTrigger(

                    name: "Activity",

                    icon: "figure.walk",

                    level: r.0,

                    displayValue: "\(Int(steps)) steps",

                    deduction: r.2,

                    reasonText: r.1
                )
            )



            totalDeduction += r.2
        }







        let score =
        max(
            0,
            min(
                100,
                Double(100 - totalDeduction)
            )
        )



        return RiskResult(
            score: score,
            label: scoreLabel(score),
            triggers: triggers
        )
    }







    static func scoreLabel(
        _ score: Double
    ) -> String {



        switch score {


        case 80...100:
            return "Good"


        case 60..<80:
            return "Fair"


        case 40..<60:
            return "Moderate"


        default:
            return "Poor"
        }
    }






    // MARK: Evaluation Logic


    private static func evaluateAQI(_ v: Int)
    -> (TriggerLevel,String,Int) {


        switch v {

        case 0...50:
            return (.low,"Good air quality",0)

        case 51...100:
            return (.moderate,"Moderate air quality",10)

        case 101...150:
            return (.high,"Poor air quality",18)

        default:
            return (.high,"Unhealthy air quality",25)
        }
    }




    private static func evaluateHumidity(_ v: Double)
    -> (TriggerLevel,String,Int) {


        switch v {

        case 40...60:
            return (.low,"Ideal humidity",0)

        case 20..<40,61..<70:
            return (.moderate,"Humidity may affect breathing",10)

        default:
            return (.high,"Humidity asthma trigger risk",18)
        }
    }




    private static func evaluateTemperature(_ v: Double)
    -> (TriggerLevel,String,Int) {


        switch v {

        case 18...30:
            return (.low,"Comfortable temperature",0)

        case 10..<18,31..<35:
            return (.moderate,"Temperature may trigger symptoms",8)

        default:
            return (.high,"Extreme temperature risk",15)
        }
    }




    private static func evaluateWind(_ v: Double)
    -> (TriggerLevel,String,Int) {


        switch v {

        case 0..<15:
            return (.low,"Calm wind",0)

        case 15..<30:
            return (.moderate,"Wind may carry pollen",8)

        default:
            return (.high,"Strong wind asthma risk",15)
        }
    }





    private static func evaluateSleep(_ v: Double)
    -> (TriggerLevel,String,Int) {


        if v < 5 {
            return (.high,"Poor sleep may worsen asthma",15)
        }


        if v < 7 {
            return (.moderate,"Low sleep duration",8)
        }


        return (.low,"Healthy sleep",0)
    }




    private static func evaluateHeart(_ v: Double)
    -> (TriggerLevel,String,Int) {


        if v > 100 {
            return (.high,"High heart rate",15)
        }


        if v > 90 {
            return (.moderate,"Elevated heart rate",8)
        }


        return (.low,"Normal heart rate",0)
    }





    private static func evaluateResp(_ v: Double)
    -> (TriggerLevel,String,Int) {


        if v > 24 {
            return (.high,"High breathing rate",18)
        }


        if v > 20 {
            return (.moderate,"Slightly elevated breathing",10)
        }


        return (.low,"Normal breathing",0)
    }






    private static func evaluateSteps(_ v: Double)
    -> (TriggerLevel,String,Int) {


        if v < 500 {
            return (.high,"Very low activity",10)
        }


        if v < 2000 {
            return (.moderate,"Low activity today",5)
        }


        return (.low,"Normal activity",0)
    }
}
