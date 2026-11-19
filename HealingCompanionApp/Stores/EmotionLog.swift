import Foundation
import SwiftUI

@MainActor
final class EmotionLog: ObservableObject {
    @Published private(set) var entries: [EmotionEntry] = []

    private let fileURL: URL
    private var cal: Calendar { Calendar.current }

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = docs.appendingPathComponent("emotion_log.json")
        load()
    }

    func record(emotion: EmotionType, reaction: CompanionReaction, date: Date = Date()) {
        let entry = EmotionEntry(
            date: date,
            emotion: emotion,
            characterID: reaction.character.id,
            message: reaction.message
        )
        entries.append(entry)
        entries.sort { $0.date > $1.date }
        save()
    }

    func moments(on day: Date) -> [EmotionEntry] {
        entries
            .filter { cal.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date < $1.date }
    }

    func summary(for day: Date) -> DaySummary? {
        let m = moments(on: day)
        guard !m.isEmpty else { return nil }
        return DaySummary(day: cal.startOfDay(for: day), moments: m)
    }

    func summaries(inMonth referenceDate: Date) -> [DaySummary] {
        let comps = cal.dateComponents([.year, .month], from: referenceDate)
        let monthEntries = entries.filter {
            let c = cal.dateComponents([.year, .month], from: $0.date)
            return c.year == comps.year && c.month == comps.month
        }
        let grouped = Dictionary(grouping: monthEntries) { cal.startOfDay(for: $0.date) }
        return grouped.map { day, ms in
            DaySummary(day: day, moments: ms.sorted { $0.date < $1.date })
        }
        .sorted { $0.day > $1.day }
    }

    func recentSummaries(limit: Int = 6) -> [DaySummary] {
        let grouped = Dictionary(grouping: entries) { cal.startOfDay(for: $0.date) }
        return grouped
            .map { day, ms in DaySummary(day: day, moments: ms.sorted { $0.date < $1.date }) }
            .sorted { $0.day > $1.day }
            .prefix(limit)
            .map { $0 }
    }

    var todaySummary: DaySummary? {
        summary(for: Date())
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            seedSample()
            return
        }
        if let decoded = try? JSONDecoder().decode([EmotionEntry].self, from: data) {
            entries = decoded.sorted { $0.date > $1.date }
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func seedSample() {
        let now = Date()
        let samples: [(Int, EmotionType, Int)] = [
            (-1, .talk, 9), (-1, .tired, 20),
            (-2, .rest, 13),
            (-4, .tired, 10), (-4, .annoyed, 15), (-4, .numb, 22),
            (-5, .numb, 14),
            (-7, .annoyed, 16), (-7, .worthless, 21),
            (-9, .rest, 23)
        ]
        let sample: [EmotionEntry] = samples.compactMap { offset, emotion, hour in
            guard let day = cal.date(byAdding: .day, value: offset, to: now) else { return nil }
            let startOfDay = cal.startOfDay(for: day)
            guard let date = cal.date(byAdding: .hour, value: hour, to: startOfDay) else { return nil }
            let character = HealingCatalog.characters.randomElement() ?? HealingCatalog.characters[0]
            let message = HealingCatalog.responses[emotion]?.randomElement() ?? ""
            return EmotionEntry(
                date: date,
                emotion: emotion,
                characterID: character.id,
                message: message
            )
        }
        entries = sample.sorted { $0.date > $1.date }
        save()
    }
}
