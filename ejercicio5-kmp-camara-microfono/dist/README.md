# Binario — Ejercicio 5 (Kotlin Multiplatform)

`camara-mic-kmp-android-debug.apk` — build debug de `androidApp` (`./gradlew :androidApp:assembleDebug`),
18 MB, generado el 16/09/2026. Instalable directamente:

```bash
adb install camara-mic-kmp-android-debug.apk
```

También se generó un build release sin firmar (`androidApp-release-unsigned.apk`, 12.0 MB) usado
únicamente para medir el tamaño real del binario en la tabla comparativa del punto 5.5 del README
principal de este ejercicio; no se incluye aquí porque no es instalable sin firmar.

Pendiente: compilar y adjuntar el binario/capturas de iOS una vez disponible el entorno macOS/Xcode
del Ejercicio 1.
