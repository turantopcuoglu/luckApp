// Kader — iOS Ana Ekran Widget'ı (WidgetKit)
//
// TASLAK: Bu dosya Xcode'da bir Widget Extension target'ına eklenmelidir.
// Kurulum adımları için bkz. docs/ios_widget_setup.md. Veri, Flutter
// tarafından `home_widget` ile App Group UserDefaults'a yazılır; anahtarlar
// (skor/tarih/teaser) Dart'taki WidgetConfig ile birebir eşleşir.

import SwiftUI
import WidgetKit

// App Group kimliği: Dart WidgetConfig.appGroupId ile aynı olmalı.
private let appGroupId = "group.com.turan.kader"

struct KaderEntry: TimelineEntry {
    let date: Date
    let skor: String
    let tarih: String
    let teaser: String
}

struct KaderProvider: TimelineProvider {
    private func oku() -> KaderEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return KaderEntry(
            date: Date(),
            skor: defaults?.string(forKey: "skor") ?? "--",
            tarih: defaults?.string(forKey: "tarih") ?? "",
            teaser: defaults?.string(forKey: "teaser") ?? ""
        )
    }

    func placeholder(in context: Context) -> KaderEntry {
        KaderEntry(date: Date(), skor: "--", tarih: "", teaser: "Kader")
    }

    func getSnapshot(in context: Context, completion: @escaping (KaderEntry) -> Void) {
        completion(oku())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KaderEntry>) -> Void) {
        // Tek girişli zaman çizelgesi; veri uygulama açıldığında güncellenir.
        completion(Timeline(entries: [oku()], policy: .never))
    }
}

struct KaderWidgetEntryView: View {
    var entry: KaderProvider.Entry

    // Marka renkleri (uygulama paletiyle aynı).
    private let navy = Color(red: 0x0A / 255, green: 0x0E / 255, blue: 0x1A / 255)
    private let gold = Color(red: 0xF4 / 255, green: 0xC9 / 255, blue: 0x5D / 255)
    private let secondary = Color(red: 0x9A / 255, green: 0xA1 / 255, blue: 0xB5 / 255)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Kader")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(gold)
            Spacer(minLength: 2)
            Text(entry.skor)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(gold)
            Text(entry.tarih)
                .font(.system(size: 12))
                .foregroundColor(secondary)
            Text(entry.teaser)
                .font(.system(size: 12))
                .foregroundColor(secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .background(navy)
    }
}

@main
struct KaderWidget: Widget {
    let kind: String = "KaderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KaderProvider()) { entry in
            KaderWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kader")
        .description("Bugünün kader skorunu ana ekranında gör.")
        .supportedFamilies([.systemSmall])
    }
}
