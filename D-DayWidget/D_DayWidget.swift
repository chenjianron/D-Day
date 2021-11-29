//
//  D_DayWidget.swift
//  D-DayWidget
//
//  Created by GC on 2021/11/17.
//

import WidgetKit
import SwiftUI
import Intents

@available(iOS 14.0, *)
struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> AnniversaryEntry {
        return AnniversaryEntry(date: Date())
    }

    func getSnapshot(for configuration: AnniversaryIntent, in context: Context, completion: @escaping (AnniversaryEntry) -> ()) {
        let entry = AnniversaryEntry(date: Date(),configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: AnniversaryIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [AnniversaryEntry] = []
        let currentDate = Date()
        
        for offset in 0 ..< 2 {
            let entryDate = Calendar.current.date(byAdding: .second, value: offset, to: currentDate)!
            let entry = AnniversaryEntry(date: entryDate,configuration:configuration)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
        
    }
}

@available(iOS 12.0, *)
struct AnniversaryEntry: TimelineEntry {
    let date: Date
    var configuration: AnniversaryIntent? = nil
}

@available(iOS 14.0, *)
struct D_DayWidgetEntryView : View {
    
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let anniversary = getAnniversary(){
            switch family {
            case .systemSmall:
                AnniversarySmallView(title:anniversary.title,date:anniversary.date)
            case .systemMedium:
                AnniversaryMediumView(title: anniversary.title, date: anniversary.date)
            case .systemLarge:
                AnniversaryLargeView(title: anniversary.title, date: anniversary.date)
            default:
                AnniversarySmallView(title:anniversary.title,date:anniversary.date)
            }
        } else {
            EmptyHintView()
        }
    }
    
    func getAnniversary() -> AnniversaryModel? {
        let anniversarys = LoveAnniversariesManager.default.getAllAnniversary()
        if anniversarys.count > 0 {
            // identifier: "下标-标识符"
            if let identifier = entry.configuration?.parameter?.identifier {
                for i in 0..<anniversarys.count {
                    if anniversarys[i].id == identifier {
                        return anniversarys[i]
                    }
                }
            } else {
                return anniversarys[0]
            }
        }
        return nil
    }
}

@available(iOS 14.0, *)
@main
struct D_DayWidget: Widget {
    
    let kind: String = "D_DayWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: AnniversaryIntent.self, provider: Provider()) { entry in
            D_DayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("D-Day")
        .description(LocalizedStringKey("随时查看你的重要日子.\n添加后长按桌面组件点击「编辑小组件」可选择显示的事件或分类。"))
    }
}

@available(iOS 14.0, *)
struct D_DayWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            D_DayWidgetEntryView(entry: AnniversaryEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            D_DayWidgetEntryView(entry: AnniversaryEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            D_DayWidgetEntryView(entry: AnniversaryEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
    
}
