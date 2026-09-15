# Ejercicio 2 — Gestor de Archivos para iPhone (Swift/SwiftUI)

Código fuente completo en `GestorArchivosIOS/`. Se escribió fuera de Xcode (no hay Mac/Xcode
disponible en esta máquina), así que **no viene con un `.xcodeproj`** — lo creas tú en 2 minutos
dentro del entorno macOS-Docker/Mac y agregas estos archivos. El código en sí está completo y
listo para compilar.

## Cómo crear el proyecto Xcode y usar este código

1. En macOS, abre Xcode → **File → New → Project → iOS → App**.
   - Product Name: `GestorArchivosIOS`
   - Interface: **SwiftUI**, Language: **Swift**
   - Guarda el proyecto en esta misma carpeta (`ejercicio2-gestor-archivos-ios/`), sustituyendo
     la carpeta `GestorArchivosIOS` que genera Xcode por la que ya está aquí, **o** arrastra los
     archivos `.swift` de aquí dentro del proyecto que generó Xcode (checkbox "Copy items if
     needed" desactivado si ya están en la carpeta del proyecto).
2. Borra el `ContentView.swift` de plantilla que crea Xcode (ya está reemplazado por
   `Views/RootTabView.swift` + `GestorArchivosApp.swift`).
3. Abre **Target → Info** y agrega las claves de `Info-additions.plist` (`UIFileSharingEnabled`,
   `LSSupportsOpeningDocumentsInPlace`).
4. Compila y corre en el simulador de iPhone (⌘R).

## Estructura del código

```
GestorArchivosIOS/
├── GestorArchivosApp.swift        # Punto de entrada (@main)
├── Models/
│   ├── AppTheme.swift             # Temas Guinda/Azul (adaptan claro/oscuro vía tint)
│   └── FileItem.swift             # Modelo de archivo/carpeta + SortOption
├── Services/
│   ├── FileManagerService.swift   # Operaciones de FileManager, sandbox-only
│   ├── PreferencesStore.swift     # UserDefaults: tema, orden, última carpeta, favoritos, recientes
│   └── ThumbnailCache.swift       # NSCache de miniaturas de imágenes
├── ViewModels/
│   └── FileBrowserViewModel.swift # Estado y navegación del explorador
└── Views/
    ├── RootTabView.swift          # TabView: Archivos / Favoritos / Recientes
    ├── FileBrowserView.swift      # Lista, breadcrumb, búsqueda, swipe, menú contextual
    ├── FileRowView.swift          # Fila con ícono/miniatura + favorito
    ├── FileViewerView.swift       # Preview de imagen (zoom/rotar) y texto + QuickLook fallback
    ├── FavoritesView.swift
    ├── RecentsView.swift
    ├── QuickLookView.swift        # Wrapper de QLPreviewController
    └── DocumentPickerView.swift   # Wrappers de UIDocumentPickerViewController y UIActivityViewController
```

## Cobertura de requisitos (2.1 – 2.5 del enunciado)

- **Exploración del sandbox**: `FileManagerService` solo opera dentro de `Documents` (obtenido
  con `FileManager.default.urls(for: .documentDirectory, ...)`).
- **Íconos por tipo (UTType)**: `FileItem.systemImageName` usa `UTType.conforms(to:)`.
- **Texto e imágenes**: `FileViewerView` (SelectableText/monospace para texto; `Image` +
  gestos de pinza/rotación para imágenes vía `PinchZoomModifier`).
- **Quick Look**: `QuickLookView` para todo lo demás (PDF, audio, video…).
- **CRUD de archivos**: crear carpeta, copiar/cortar+pegar, renombrar, eliminar con
  confirmación (`confirmationDialog`) — en `FileBrowserViewModel` + `FileBrowserView`.
- **Importar**: `DocumentPickerView` (UIDocumentPickerViewController) + security-scoped bookmark
  resuelto en `FileManagerService.importExternalFile`.
- **Compartir**: `ActivityView` (UIActivityViewController) desde `FileViewerView`.
- **Temas Guinda/Azul + claro/oscuro**: `AppTheme` aplicado como `.tint()`; el modo claro/oscuro
  lo maneja el sistema automáticamente (no forzamos `preferredColorScheme`).
- **NavigationStack + breadcrumb**: `FileBrowserView.breadcrumbBar`.
- **Búsqueda y orden**: `.searchable()` + menú de `SortOption` (nombre/fecha/tamaño).
- **Gestos**: `.swipeActions` (eliminar), `.contextMenu` (mantener presionado), `.refreshable`
  (deslizar hacia abajo).
- **Historial, favoritos, caché de miniaturas, preferencias de sesión**: `PreferencesStore`
  (UserDefaults) + `ThumbnailCache` (NSCache).
- **Info.plist**: ver `Info-additions.plist`.

## Pendiente de hacer en macOS (no automatizable desde aquí)

- Crear el `.xcodeproj` real y compilar.
- Probar en simulador de iPhone y tomar las capturas para el informe.
- Ajustar `Bundle Identifier` / firma si se prueba en un iPhone físico.
