# Ejercicio 3 — Cámara y Micrófono para iPhone (Swift/AVFoundation)

Igual que en el Ejercicio 2: código Swift completo en `CamaraMicrofonoIOS/`, escrito fuera de
Xcode. Crea el proyecto en macOS y agrega estos archivos.

## Cómo crear el proyecto Xcode

1. Xcode → **File → New → Project → iOS → App**
   - Product Name: `CamaraMicrofonoIOS`, Interface: **SwiftUI**, Language: **Swift**
2. Sustituye/agrega los archivos de `CamaraMicrofonoIOS/` en el proyecto (borra el
   `ContentView.swift` de plantilla).
3. En **Target → Info**, agrega las 3 claves de `Info-additions.plist`
   (`NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, `NSPhotoLibraryUsageDescription`).
4. Compila y corre.

## ⚠️ El simulador de iOS no tiene cámara física

La app lo detecta (`CameraService.isCameraAvailable`, basado en
`UIImagePickerController.isSourceTypeAvailable(.camera)`) y muestra un selector de fototeca
(`PHPickerViewController`) como fuente alternativa, tal como pide el enunciado (3.2). Para
probar la captura real con `AVCaptureSession`, se necesita un **iPhone físico** conectado y
firmado con tu Apple ID (Xcode → Signing & Capabilities → Team).

El micrófono (`AVAudioRecorder`) sí funciona en el simulador usando el micrófono de la Mac.

## Estructura del código

```
CamaraMicrofonoIOS/
├── CamaraMicrofonoApp.swift
├── Models/
│   ├── AppTheme.swift
│   └── MediaItem.swift
├── Services/
│   ├── CameraService.swift          # AVCaptureSession, flash, temporizador, filtros CIFilter
│   ├── AudioRecorderService.swift   # AVAudioRecorder + medidor de nivel + AVAudioPlayer
│   ├── MediaLibraryService.swift    # Guarda archivos en Documents/Media + Core Data
│   ├── PersistenceController.swift  # Core Data con modelo programático (sin .xcdatamodeld)
│   └── PreferencesStore.swift       # UserDefaults: tema, última categoría
└── Views/
    ├── RootTabView.swift            # Tabs: Cámara / Micrófono / Galería
    ├── CameraView.swift             # Preview + flash/temporizador/filtro + fallback PHPicker
    ├── CameraPreviewView.swift      # Wrapper de AVCaptureVideoPreviewLayer
    ├── PhotoLibraryPickerView.swift # Wrapper de PHPickerViewController
    ├── AudioRecorderView.swift      # Medidor de nivel, sensibilidad, límite de tiempo
    ├── GalleryView.swift            # Grid por categorías/álbumes
    └── MediaDetailView.swift        # Visor de foto (zoom/rotar) y reproductor de audio
```

## Nota sobre Core Data

`PersistenceController` construye el `NSManagedObjectModel` **por código** en lugar de un
archivo `.xcdatamodeld` (ese formato normalmente se edita con el editor visual de Xcode, no
disponible aquí). Funciona igual en tiempo de ejecución. Si prefieres el editor visual, puedes
reemplazarlo por un `.xcdatamodeld` real una vez estés en Xcode — solo actualiza `MediaLibraryService`
para usar el `NSManagedObjectContext` que prefieras.

## Cobertura de requisitos (3.1 – 3.6 del enunciado)

- **Captura de fotos**: `CameraService` (AVCaptureSession + AVCapturePhotoOutput).
- **Grabación de audio**: `AudioRecorderService` (AVAudioRecorder).
- **Personalización**: flash, temporizador (3/10s) y filtros CIFilter para fotos; sensibilidad
  (ganancia visual del medidor) y límite de tiempo para audio.
- **Simulador sin cámara → PHPickerViewController**: `PhotoLibraryPickerView`, documentado en
  este README (se usó la fuente alternativa por defecto; cambia a prueba en dispositivo físico
  para AVCaptureSession real).
- **Info.plist**: `Info-additions.plist`.
- **Galería con edición básica** (rotar) **y reproductor de audio**: `MediaDetailView`.
- **Categorías/álbumes**: campo `category` en `MediaItem`, filtro por segmented control en
  `GalleryView`.
- **Temas Guinda/Azul + modo claro/oscuro**: `AppTheme` + `.tint()`, igual que en Ejercicio 2.
- **Core Data para metadatos**: `PersistenceController` + `MediaLibraryService`.
