package mx.ipn.escom.camaramic

// Shared brand colors (as 0xAARRGGBB longs) so both the Compose (Android)
// and SwiftUI (iOS) UIs use the exact same Guinda/Azul values.
enum class AppThemeOption(val label: String, val argb: Long) {
    GUINDA("Guinda (IPN)", 0xFF8C1D40),
    AZUL("Azul (ESCOM)", 0xFF0057B7),
}
