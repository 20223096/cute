import Foundation

struct VariantSelector {
    private let defaults = UserDefaults(suiteName: HealingStoreConfig.appGroupID)
    private let recentKey = "variant_recent_v1"
    private let avoidWindow = 2

    func select(for base: EmotionType) -> EmotionVariant {
        let pool = EmotionVariantCatalog.variants(for: base)
        guard !pool.isEmpty else {
            return EmotionVariantCatalog.fallback(for: base)
        }

        // If the user just saved a comfort message, make sure the variant that hosts it
        // is chosen next so the saved message can be delivered exactly once.
        let pendingIDs = SavedComfortBank.pendingVariantIDs(for: base)
        if let firstPendingID = pendingIDs.first,
           let pendingVariant = EmotionVariantCatalog.variant(id: firstPendingID) {
            remember(variantID: pendingVariant.id, for: base)
            return pendingVariant
        }

        guard pool.count > 1 else {
            let only = pool[0]
            remember(variantID: only.id, for: base)
            return only
        }

        var recentMap = loadRecentMap()
        let recent = recentMap[base.rawValue] ?? []
        let candidates = pool.filter { !recent.contains($0.id) }
        let chosen = (candidates.isEmpty ? pool : candidates).randomElement() ?? pool[0]

        var updated = recent
        updated.append(chosen.id)
        if updated.count > avoidWindow {
            updated.removeFirst(updated.count - avoidWindow)
        }
        recentMap[base.rawValue] = updated
        saveRecentMap(recentMap)

        return chosen
    }

    func select(variantID: String, fallbackBase: EmotionType) -> EmotionVariant {
        if let v = EmotionVariantCatalog.variant(id: variantID) {
            remember(variantID: v.id, for: v.base)
            return v
        }
        return select(for: fallbackBase)
    }

    func remember(variantID: String, for base: EmotionType) {
        var recentMap = loadRecentMap()
        var list = recentMap[base.rawValue] ?? []
        list.append(variantID)
        if list.count > avoidWindow {
            list.removeFirst(list.count - avoidWindow)
        }
        recentMap[base.rawValue] = list
        saveRecentMap(recentMap)
    }

    private func loadRecentMap() -> [String: [String]] {
        guard let defaults,
              let data = defaults.data(forKey: recentKey),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data)
        else { return [:] }
        return decoded
    }

    private func saveRecentMap(_ map: [String: [String]]) {
        guard let defaults, let data = try? JSONEncoder().encode(map) else { return }
        defaults.set(data, forKey: recentKey)
    }
}
