import SwiftUI

/// The two brand themes required by the practice: Guinda (IPN) and Azul (ESCOM).
/// Both adapt automatically to light/dark mode because the accent colors are
/// only used as the SwiftUI `tint`, letting system materials handle the rest.
enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case guinda
    case azul

    var id: String { rawValue }

    var label: String {
        switch self {
        case .guinda: return "Guinda (IPN)"
        case .azul: return "Azul (ESCOM)"
        }
    }

    var accentColor: Color {
        switch self {
        case .guinda: return Color(red: 0.549, green: 0.114, blue: 0.251) // #8C1D40
        case .azul: return Color(red: 0.0, green: 0.341, blue: 0.718)    // #0057B7
        }
    }
}
