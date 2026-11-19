import Foundation
import SwiftUI

@MainActor
final class JournalStore: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []

    private let fileURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = docs.appendingPathComponent("journal.json")
        load()
    }

    @discardableResult
    func save(_ entry: JournalEntry) -> JournalEntry {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.insert(entry, at: 0)
        }
        entries.sort { $0.createdAt > $1.createdAt }
        persist()
        return entry
    }

    func delete(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        persist()
    }

    func entry(for id: UUID) -> JournalEntry? {
        entries.first { $0.id == id }
    }

    var isEmpty: Bool { entries.isEmpty }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data)
        else { return }
        entries = decoded.sorted { $0.createdAt > $1.createdAt }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
