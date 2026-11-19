import Foundation
import SwiftUI

@MainActor
final class CustomEmotionStore: ObservableObject {
    @Published private(set) var recent: [CustomEmotion] = []

    private let fileURL: URL
    private let maxCount = 10

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = docs.appendingPathComponent("custom_emotions.json")
        load()
    }

    func add(text rawText: String) -> CustomEmotion? {
        let text = CustomEmotionMapper.sanitize(rawText)
        guard !text.isEmpty else { return nil }

        let base = CustomEmotionMapper.map(text)
        let entry = CustomEmotion(text: text, mappedBase: base)

        recent.removeAll { $0.text == entry.text }
        recent.insert(entry, at: 0)
        if recent.count > maxCount {
            recent.removeLast(recent.count - maxCount)
        }
        save()
        return entry
    }

    func touch(_ entry: CustomEmotion) {
        recent.removeAll { $0.id == entry.id }
        recent.insert(entry, at: 0)
        save()
    }

    func remove(_ entry: CustomEmotion) {
        recent.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CustomEmotion].self, from: data)
        else { return }
        recent = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(recent) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
