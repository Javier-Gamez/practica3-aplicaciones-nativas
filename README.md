# Práctica 3 — Aplicaciones Nativas

Instituto Politécnico Nacional · Escuela Superior de Cómputo
Unidad de aprendizaje: Desarrollo de aplicaciones móviles nativas
**Entrega: lunes 28 de septiembre de 2026**

## Integrantes del equipo

| Nombre completo | Boleta |
|---|---|
| Javier de Jesús Gamez Rosas | 2022630007 |

> Práctica realizada de forma individual (equipo de un solo integrante).

## Estructura del repositorio

| Carpeta | Ejercicio | Estado |
|---|---|---|
| [`ejercicio1-entorno-macos/`](ejercicio1-entorno-macos) | 1. Instalación de macOS/Xcode (MacOS-Docker) | Specs de la PC documentadas; instalación de macOS-Docker/Xcode pendiente |
| [`ejercicio2-gestor-archivos-ios/`](ejercicio2-gestor-archivos-ios) | 2. Gestor de archivos iPhone (Swift/SwiftUI) | Código completo, pendiente crear `.xcodeproj` y compilar en Xcode |
| [`ejercicio3-camara-microfono-ios/`](ejercicio3-camara-microfono-ios) | 3. Cámara y micrófono iPhone (Swift/AVFoundation) | Código completo, pendiente crear `.xcodeproj` y compilar en Xcode |
| [`ejercicio4-flutter-gestor-archivos/`](ejercicio4-flutter-gestor-archivos) | 4. Multiplataforma Flutter (Opción A: gestor de archivos) | **Compilado, probado en emulador y APK release generado** (Android); iOS pendiente de Xcode |
| [`ejercicio5-kmp-camara-microfono/`](ejercicio5-kmp-camara-microfono) | 5. Multiplataforma Kotlin Multiplatform (Opción B: cámara/mic) | **Lado Android compilado, probado y APK release generado**; lado iOS pendiente de Xcode |
| [`docs/`](docs) | Bitácora e informe | Bitácora con datos reales; informe aún por redactar |

## Por qué esta estructura

Los ejercicios 2 y 3 requieren Xcode/macOS para compilar y ejecutar; se desarrollaron en un
entorno Windows sin Mac disponible, así que el código Swift está completo y documentado pero
**no compilado localmente** — el paso de abrir Xcode, crear el proyecto y compilar en el
simulador de iPhone queda pendiente para cuando el equipo tenga acceso al entorno macOS-Docker
(Ejercicio 1). Cada carpeta de esos ejercicios trae su propio README con instrucciones exactas.

Los ejercicios 4 y 5 sí se pudieron compilar parcialmente en esta máquina:
- **Ejercicio 4 (Flutter)**: compilado, instalado y probado de extremo a extremo en un emulador
  Android (navegación de archivos, favoritos, búsqueda, orden, cambio de tema Guinda/Azul en
  vivo con persistencia). La parte iOS (simulador o dispositivo) se compila desde el mismo código
  Dart una vez en macOS — no requiere cambios.
- **Ejercicio 5 (Kotlin Multiplatform)**: el módulo compartido (`shared`) y la app Android
  (`androidApp`, Jetpack Compose) se compilaron con Gradle **y se instalaron y probaron en el
  emulador** — preview de cámara en vivo vía CameraX enlazado a través del `CameraController`
  compartido, tema Guinda, navegación por pestañas y flujo de permisos, todo funcionando. El
  módulo iOS (framework "Shared" + app SwiftUI) está escrito pero requiere Xcode para compilarse
  y enlazarse.

## Próximos pasos

1. Instalar macOS-Docker (o conseguir acceso a una Mac) y Xcode — ver la advertencia de espacio en
   disco en [`ejercicio1-entorno-macos/especificaciones-equipo.md`](ejercicio1-entorno-macos/especificaciones-equipo.md)
   antes de empezar.
2. Con Xcode disponible: crear los proyectos de los ejercicios 2, 3 y 5 (parte iOS), compilar,
   probar en simulador/dispositivo y tomar las capturas para el informe.
3. Llenar [`docs/informe/`](docs/informe) con capturas, pruebas realizadas y conclusiones.
4. Seguir registrando sesiones reales en [`docs/bitacora.md`](docs/bitacora.md) conforme avances.
