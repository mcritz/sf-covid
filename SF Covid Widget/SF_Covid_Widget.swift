//
//  SF_Covid_Widget.swift
//  SF Covid Widget
//
//  Created by Critz, Michael on 2/14/22.
//

import Charts
import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CovidWidgetEntry {
        CovidWidgetEntry(date: Date(), model: SummaryViewModel(), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (CovidWidgetEntry) -> ()) {
        let summaryVM = SummaryViewModel()
        let entry = CovidWidgetEntry(date: Date(), model: summaryVM, configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<CovidWidgetEntry>) -> ()) {
        let summaryVM = SummaryViewModel()
        Task.detached(priority: .background) {
            var entries = [CovidWidgetEntry]()
            try? await summaryVM.update()
            let entry = CovidWidgetEntry(date: Date(), model: summaryVM, configuration: configuration)
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct CovidWidgetEntry: TimelineEntry {
    let date: Date
    let model: SummaryViewModel
    let configuration: ConfigurationIntent
}

struct SF_Covid_WidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            CovidSummaryView(summaryVM: entry.model)
        }
        .padding(10.0)
        .background {
            ZStack {
                LinearGradient(colors: [
                                    Color("AccentColor"),
                                    Color("Secondary")
                                ],
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()
                Chart(data: entry.model.chartValues)
                    .chartStyle(AreaChartStyle(.line, fill:
                                                LinearGradient(colors: [
                                                    Color.black.opacity(0.4),
                                                    Color.black.opacity(0.35),
                                                    Color.black.opacity(0.25),
                                                    Color.black.opacity(0.1)
                                                ],
                                                               startPoint: .top,
                                                               endPoint: .bottom)
                                              ))
                Chart(data: entry.model.chartAvaerageValues)
                    .chartStyle(LineChartStyle(.line,
                                               lineColor: Color("AccentContrastColor"),
                                               lineWidth: 3.0))
                    .opacity(0.5)
                    .shadow(radius: 3.0)
            }
        }
        
    }
}

@main
struct SF_Covid_Widget: Widget {
    let kind: String = "SF_Covid_Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SF_Covid_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("New SF Covid Cases")
        .description("New San Francisco Covid Cases from SF Department of health")
    }
}

struct SF_Covid_Widget_Previews: PreviewProvider {
    
    static let caseCount = "34"
    static var previews: some View {
        SF_Covid_WidgetEntryView(entry: CovidWidgetEntry(date: Date(), model: SummaryViewModel(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        SF_Covid_WidgetEntryView(entry: CovidWidgetEntry(date: Date(), model: SummaryViewModel(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        SF_Covid_WidgetEntryView(entry: CovidWidgetEntry(date: Date(), model: SummaryViewModel(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
