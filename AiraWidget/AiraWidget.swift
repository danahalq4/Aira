import WidgetKit
import SwiftUI

// MARK: - Data

struct SimpleEntry: TimelineEntry {
    let date: Date
    let score: Double
    let scoreLabel: String
}


// MARK: - Provider

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            score: 52,
            scoreLabel: "Moderate"
        )
    }


    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        completion(loadEntry())
    }


    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<SimpleEntry>) -> Void
    ) {

        let entry = loadEntry()

        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(60))
        )

        completion(timeline)
    }


    func loadEntry() -> SimpleEntry {

        let defaults = UserDefaults(
            suiteName: "group.com.fajr.aleid.Aira"
        )


        let savedScore = defaults?.object(
            forKey: "riskScore"
        ) as? Double


        let score = savedScore ?? 0


        let label = defaults?.string(
            forKey: "riskLabel"
        ) ?? "No Data"


        return SimpleEntry(
            date: Date(),
            score: score,
            scoreLabel: label
        )
    }
}



// MARK: - Widget UI

struct AiraWidgetView: View {

    var entry: Provider.Entry


    var body: some View {

        VStack(spacing: 8) {


            Text("Asthma Risk")
                .font(.headline)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )


            ZStack {


                Circle()
                    .stroke(
                        Color.gray.opacity(0.25),
                        lineWidth: 9
                    )


                Circle()
                    .trim(
                        from: 0,
                        to: entry.score / 100
                    )
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(
                            lineWidth: 9,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(
                        .degrees(-90)
                    )



                VStack(spacing: 2) {


                    Text("\(Int(entry.score))%")
                        .font(
                            .system(
                                size: 25,
                                weight: .bold
                            )
                        )


                    Text(entry.scoreLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

            }
            .frame(
                width: 105,
                height: 105
            )

        }
        .padding()
        .containerBackground(
            .fill.tertiary,
            for: .widget
        )
    }
}



// MARK: - Widget

struct AiraWidget: Widget {


    let kind = "AiraWidget"


    var body: some WidgetConfiguration {


        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in


            AiraWidgetView(
                entry: entry
            )


        }
        .configurationDisplayName("Aira")
        .description(
            "Asthma risk overview"
        )
        .supportedFamilies([
            .systemSmall
        ])
    }
}
