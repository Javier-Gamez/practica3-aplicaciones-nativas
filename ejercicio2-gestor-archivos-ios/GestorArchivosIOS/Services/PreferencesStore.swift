import Foundation

/// Session persistence backed by UserDefaults: theme, sort order, last
/// visited folder, favorites and recent files history.
final class PreferencesStore: ObservableObject {
    static let shared = PreferencesStore()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let theme = "app.theme"
        static let sortOption = "app.sortOption"
        static let lastFolderPath = "app.lastFolderPath"
        static let favorites = "app.favorites"
        static let recents = "app.recents"
    }

    @Published var theme: AppTheme {
        didSet { defaults.set(theme.rawValue, forKey: Keys.theme) }
    }

    @Published var sortOption: SortOption {
        didSet { defaults.set(sortOption.rawValue, forKey: Keys.sortOption) }
    }

    @Published var favorites: Set<String> {
        didSet { defaults.set(Array(favorites), forKey: Keys.favorites) }
    }

    @Published var recents: [String] {
        didSet { defaults.set(recents, forKey: Keys.recents) }
    }

    var lastFolderPath: String? {
        get { defaults.string(forKey: Keys.lastFolderPath) }
        set { defaults.set(newValue, forKey: Keys.lastFolderPath) }
    }

    private init() {
        theme = AppTheme(rawValue: defaults.string(forKey: Keys.theme) ?? "") ?? .guinda
        sortOption = SortOption(rawValue: defaults.string(forKey: Keys.sortOption) ?? "") ?? .name
        favorites = Set(defaults.stringArray(forKey: Keys.favorites) ?? [])
        recents = defaults.stringArray(forKey: Keys.recents) ?? []
    }

    func toggleFavorite(_ path: String) {
        if favorites.contains(path) {
            favorites.remove(path)
        } else {
            favorites.insert(path)
        }
    }

    func isFavorite(_ path: String) -> Bool { favorites.contains(path) }

    func pushRecent(_ path: String, limit: Int = 30) {
        var updated = recents.filter { $0 != path }
        updated.insert(path, at: 0)
        recents = Array(updated.prefix(limit))
    }

    func clearRecents() { recents = [] }
}
