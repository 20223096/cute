import Foundation

/// Sync UserDefaults-backed storage for `SavedComfortMessage`s so that non-@MainActor
/// code (HealingEngine, widget extension) can blend them into message pools.
enum SavedComfortBank {
    private static let defaults = UserDefaults(suiteName: HealingStoreConfig.appGroupID)
    private static let key = "saved_comfort_v1"
    private static let lastPickedKey = "saved_comfort_lastpick_v1"

    static func all() -> [SavedComfortMessage] {
        guard let defaults,
              let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedComfortMessage].self, from: data)
        else { return [] }
        return decoded
    }

    static func save(_ list: [SavedComfortMessage]) {
        guard let defaults, let data = try? JSONEncoder().encode(list) else { return }
        defaults.set(data, forKey: key)
    }

    static func upsert(_ message: SavedComfortMessage) {
        var list = all()
        if let idx = list.firstIndex(where: { $0.id == message.id }) {
            list[idx] = message
        } else {
            list.insert(message, at: 0)
        }
        save(list)
    }

    static func remove(id: UUID) {
        var list = all()
        list.removeAll { $0.id == id }
        save(list)
    }

    static func touch(id: UUID, date: Date = Date()) {
        var list = all()
        guard let idx = list.firstIndex(where: { $0.id == id }) else { return }
        list[idx].lastUsedAt = date
        list[idx].useCount += 1
        save(list)
    }

    static func messages(for emotion: EmotionType, mood: VariantMood? = nil) -> [SavedComfortMessage] {
        let list = all()
        return list.filter { saved in
            guard saved.emotion == emotion else { return false }
            if let mood { return saved.mood == mood }
            return true
        }
    }

    // MARK: - Last-picked memo (to reduce repetition)
    private static func lastPickedMap() -> [String: String] {
        guard let defaults,
              let data = defaults.data(forKey: lastPickedKey),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return decoded
    }

    private static func saveLastPickedMap(_ map: [String: String]) {
        guard let defaults, let data = try? JSONEncoder().encode(map) else { return }
        defaults.set(data, forKey: lastPickedKey)
    }

    static func lastPickedMessage(for variantID: String) -> String? {
        lastPickedMap()[variantID]
    }

    static func rememberPicked(message: String, for variantID: String) {
        var map = lastPickedMap()
        map[variantID] = message
        saveLastPickedMap(map)
    }

    // MARK: - Pending queue (guarantees the next tap on that emotion shows this message once)
    private static let pendingKey = "saved_comfort_pending_v1"

    private static func pendingMap() -> [String: [String]] {
        guard let defaults,
              let data = defaults.data(forKey: pendingKey),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data)
        else { return [:] }
        return decoded
    }

    private static func savePendingMap(_ map: [String: [String]]) {
        guard let defaults, let data = try? JSONEncoder().encode(map) else { return }
        defaults.set(data, forKey: pendingKey)
    }

    static func pushPending(text: String, variantID: String) {
        var map = pendingMap()
        var list = map[variantID] ?? []
        list.removeAll { $0 == text }
        list.append(text)
        map[variantID] = list
        savePendingMap(map)
    }

    static func popPending(variantID: String) -> String? {
        var map = pendingMap()
        guard var list = map[variantID], !list.isEmpty else { return nil }
        let next = list.removeFirst()
        if list.isEmpty {
            map.removeValue(forKey: variantID)
        } else {
            map[variantID] = list
        }
        savePendingMap(map)
        return next
    }

    /// Return the variantIDs that still have pending messages for the given base emotion.
    static func pendingVariantIDs(for emotion: EmotionType) -> [String] {
        let map = pendingMap()
        return map.keys.filter { key in
            guard let variant = EmotionVariantCatalog.variant(id: key) else { return false }
            return variant.base == emotion && !(map[key]?.isEmpty ?? true)
        }
    }

    static func removePending(text: String, variantID: String) {
        var map = pendingMap()
        guard var list = map[variantID] else { return }
        list.removeAll { $0 == text }
        if list.isEmpty { map.removeValue(forKey: variantID) } else { map[variantID] = list }
        savePendingMap(map)
    }
}
