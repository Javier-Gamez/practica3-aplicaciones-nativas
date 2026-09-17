# Ejercicio 5 — Kotlin Multiplatform: Cámara y Micrófono

Proyecto KMP completo en `CamaraMicKMP/`. **Opción B** (cámara/micrófono, la contraria a la del
Ejercicio 4) para experimentar con el otro tipo de acceso a recursos, como sugiere el enunciado.

**Estado: lado Android compilado, instalado y probado en el emulador** — `./gradlew
:androidApp:assembleDebug` genera el APK, y se verificó en ejecución: preview de cámara en vivo
(CameraX enlazado a través del `CameraController` compartido), tema Guinda aplicado, navegación
entre pestañas Cámara/Micrófono/Galería y el flujo de permisos en tiempo de ejecución. Captura en
`docs/evidencia/ejercicio5/01-camara-preview-guinda.png`. El lado iOS está escrito pero pendiente
de compilar en Xcode (ver sección de abajo).

## Estructura

```
CamaraMicKMP/
├── shared/                          # Módulo compartido (commonMain/androidMain/iosMain)
│   └── src/
│       ├── commonMain/kotlin/mx/ipn/escom/camaramic/
│       │   ├── MediaItem.kt         # Modelo + MediaKind (@Serializable)
│       │   ├── AppTheme.kt          # Colores Guinda/Azul compartidos
│       │   ├── PlatformFileStore.kt # expect: acceso a filesystem
│       │   ├── CameraController.kt  # expect: captura de fotos
│       │   ├── AudioRecorderController.kt # expect: grabación de audio
│       │   └── MediaRepository.kt   # Lógica de negocio 100% común (Coroutines/Flow)
│       ├── androidMain/kotlin/.../  # actual: java.io.File, CameraX, MediaRecorder
│       └── iosMain/kotlin/.../      # actual: NSFileManager, AVCaptureSession, AVAudioRecorder
├── androidApp/                      # App Android: Jetpack Compose consumiendo :shared
├── iosApp/                          # App iOS: SwiftUI consumiendo el framework "Shared"
├── build.gradle.kts / settings.gradle.kts / gradle.properties
└── gradlew / gradlew.bat            # Wrapper (Gradle 9.3.1, ya compatible con lo usado en Ej. 4)
```

## Cómo abrir y compilar

**Android (se puede hacer en Windows, sin macOS):**
```bash
cd CamaraMicKMP
./gradlew :androidApp:assembleDebug
```
O ábrelo directamente en Android Studio (File > Open) y déjalo sincronizar — si sugiere
actualizar AGP/Kotlin, acepta la sugerencia, son versiones fijadas a mano fuera de Xcode/Android
Studio y podrían necesitar el bump automático que ofrece el IDE.

**iOS (requiere macOS/Xcode, en el entorno macOS-Docker de la práctica):**
1. Genera el framework compartido: `./gradlew :shared:linkDebugFrameworkIosSimulatorArm64` (o el
   target que corresponda a tu Mac/simulador).
2. Crea un proyecto Xcode en `iosApp/` (iOS App, SwiftUI, Swift) y enlaza el framework `Shared`
   generado en `shared/build/bin/...` (o usa el plugin `co.touchlab:kmmbridge` /
   configuración manual de "Embed & Sign" apuntando a esa carpeta).
3. Sustituye los archivos generados por Xcode con `iosApp/iosApp/iOSApp.swift` y
   `ContentView.swift` ya incluidos aquí.
4. Compila y corre en el simulador de iPhone.

## Por qué esta arquitectura

- **`expect`/`actual` para recursos del dispositivo**: `PlatformFileStore`, `CameraController` y
  `AudioRecorderController` son los tres puntos donde Android e iOS difieren de verdad
  (filesystem, cámara, micrófono). Todo lo demás — el modelo de datos, la serialización JSON del
  índice de medios, y la lógica de guardar/eliminar/listar (`MediaRepository`) — vive una sola vez
  en `commonMain`.
- **UI nativa por plataforma** (no Compose Multiplatform): Jetpack Compose en Android, SwiftUI en
  iOS, ambas consumiendo el mismo `MediaRepository`. Es la opción que permite comparar mejor
  contra Flutter en la tabla del punto 5.5 (Flutter si usa un solo árbol de UI; aquí no).
- **Persistencia**: un índice JSON (`kotlinx-serialization`) + archivos crudos en el sandbox de
  cada plataforma, en vez de SQLDelight/Room — mismo espíritu que "solución equivalente" que
  permite el enunciado, sin depender de generación de código (KSP) que añadiría fragilidad a un
  proyecto armado sin IDE.
- **Verificado en este entorno**: el lado Android (`shared` + `androidApp`) se puede compilar y
  correr en Windows con Android Studio/`gradlew`. El lado iOS necesita compilarse en el entorno
  macOS-Docker/Xcode de la práctica — el código está escrito y es coherente con los patrones
  estándar de interop Kotlin/Native + AVFoundation, pero **no se pudo compilar/verificar en esta
  máquina** (sin Xcode). Déjalo como primer paso al llegar a macOS.

## 5.5 Tabla comparativa

| Criterio | Flutter (Ej. 4) | Kotlin Multiplatform (Ej. 5) |
|---|---|---|
| Lenguaje | Dart | Kotlin |
| Construcción de UI | Un solo árbol de widgets (Flutter engine, Skia/Impeller) | UI nativa separada por plataforma (Compose / SwiftUI) consumiendo lógica compartida |
| Acceso a APIs nativas | Plugins (canales de plataforma) | Directo vía `expect`/`actual`, sin capa de mensajería |
| % de código compartido | Muy alto (UI + lógica) | Medio (solo lógica de negocio; UI 0% compartida en este enfoque) |
| Tamaño del binario (Android, release) | 49.3 MB (`app-release.apk`, universal — incluye las 4 ABIs de Android) | 12.0 MB (`androidApp-release-unsigned.apk`) |
| Tamaño del binario (iOS) | — (pendiente compilar IPA en macOS/Xcode) | — (pendiente compilar en macOS/Xcode) |
| Curva de aprendizaje | Baja si ya sabes Dart/Flutter | Media-alta (dos toolchains + interop nativo) |
| Madurez del ecosistema | Muy madura, gran catálogo de paquetes | Madura en Android; interop iOS más artesanal |

> Medido en esta máquina (Windows, Android SDK 36) el 16/09/2026 con `flutter build apk --release`
> y `./gradlew :androidApp:assembleRelease`. El APK de Flutter es "universal" (contiene código
> nativo para armeabi-v7a, arm64-v8a, x86 y x86_64 en un solo archivo); generando APKs divididos
> por ABI (`--split-per-abi`) el tamaño por dispositivo bajaría a ~15-20 MB, más comparable al de
> KMP. Aun así, KMP resultó considerablemente más ligero porque no arrastra el motor de renderizado
> de Flutter (Skia/Impeller) ni la VM de Dart: la UI se compila a bytecode/Compose nativo de
> Android directamente. Los tamaños de IPA (iOS) quedan pendientes de medir una vez compilados en
> el entorno macOS/Xcode (Ejercicio 1).

### Conclusión

Para este tipo de aplicación (acceso a hardware del dispositivo — cámara/micrófono, sistema de
archivos), **Kotlin Multiplatform resultó el enfoque más adecuado**: al usar UI nativa por
plataforma con `expect`/`actual` solo en los puntos que realmente difieren (`CameraController`,
`AudioRecorderController`, `PlatformFileStore`), el acceso a APIs de plataforma es directo — sin
la capa de serialización de mensajes por *platform channel* que exige Flutter para lo mismo — y el
binario resultante es notablemente más pequeño. El costo es una curva de aprendizaje más alta (hay
que mantener dos UIs y entender la interoperabilidad Kotlin/Native con Objective-C/Swift) y un
ecosistema iOS menos maduro que el de Flutter. Flutter, en cambio, es preferible cuando la lógica
de UI se puede compartir casi al 100% y el acceso a hardware nativo es secundario, gracias a su
enorme catálogo de plugins y menor curva de entrada — como fue el caso, en menor medida, del
gestor de archivos del Ejercicio 4, donde casi toda la app (navegación, favoritos, temas) es UI
compartida y solo el acceso al sandbox de archivos necesita un plugin nativo.
