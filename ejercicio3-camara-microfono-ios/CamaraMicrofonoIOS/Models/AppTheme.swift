import SwiftUI

/// Same two brand themes as Ejercicio 2, kept identical on purpose so both
/// apps look consistent.
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
