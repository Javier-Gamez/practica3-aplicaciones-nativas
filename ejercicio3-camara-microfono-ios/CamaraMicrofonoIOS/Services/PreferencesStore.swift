import Foundation

/// Session persistence backed by UserDefaults: theme + last used category.
final class PreferencesStore: ObservableObject {
    static let shared = PreferencesStore()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let theme = "app.theme"
        static let lastCategory = "app.lastCategory"
    }

    @Published var theme: AppTheme {
        didSet { defaults.set(theme.rawValue, forKey: Keys.theme) }
    }

    @Published var lastCategory: String {
        didSet { defaults.set(lastCategory, forKey: Keys.lastCategory) }
    }

    private init() {
        theme = AppTheme(rawValue: defaults.string(forKey: Keys.theme) ?? "") ?? .guinda
        lastCategory = defaults.string(forKey: Keys.lastCategory) ?? "General"
    }
}
