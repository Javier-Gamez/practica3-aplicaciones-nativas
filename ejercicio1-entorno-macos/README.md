# Ejercicio 1 — Entorno macOS/iOS en la mejor PC del equipo

Este ejercicio no se resuelve con código: es instalación, documentación y trabajo en equipo.
Aquí tienes la guía y las plantillas listas para llenar; el contenido real (specs, capturas,
bitácora) lo pone el equipo.

## 1.1 Identificación del equipo — plantilla

Completa `especificaciones-equipo.md` con la tabla comparativa. Ejemplo de estructura:

| Integrante | Boleta | CPU | RAM | Almacenamiento libre | GPU/Virtualización (VT-x/AMD-V) | SO |
|---|---|---|---|---|---|---|
| Nombre 1 | 2024XXXXXX | ... | ... | ... | Habilitada/Deshabilitada | Windows 11 |
| Nombre 2 | 2024XXXXXX | ... | ... | ... | ... | ... |

Justifica la elección de la PC ganadora (normalmente la de más RAM + virtualización habilitada
+ más núcleos, ya que macOS en Docker es pesado en CPU/RAM).

## 1.2 Bitácora de sesiones

Usa `docs/bitacora.md` (en la raíz del repo) para registrar cada sesión de trabajo del equipo
completo — no solo de este ejercicio, sino de toda la práctica.

## 1.3 Instalación de macOS con Docker

Repositorio oficial: https://github.com/gabrielhuav/MacOS-Docker

Pasos generales (ajusta según el README real del repo al momento de instalar):

```bash
git clone https://github.com/gabrielhuav/MacOS-Docker.git
cd MacOS-Docker
```

1. Revisa los requisitos del repo (Docker Desktop, virtualización habilitada en BIOS/UEFI,
   espacio en disco — normalmente 60-100+ GB libres, RAM asignada recomendada 8 GB o más).
2. Sigue el `docker-compose up -d` (o el comando que indique el README del repo) para levantar
   el contenedor macOS.
3. Conéctate por VNC/RDP según indique el repo para ver el escritorio de macOS.
4. Ajusta en el `docker-compose.yml` los recursos (`RAM`, `CPU`, `disk size`) según las specs de
   la PC elegida en 1.1 — deja margen para el sistema anfitrión (Windows).
5. Verifica que macOS arranca, tiene red (App Store accesible) y responde con fluidez aceptable.

Documenta cada paso con capturas de pantalla en `docs/informe/ejercicio1-instalacion.md`.

## 1.4 Configuración del entorno de desarrollo iOS

Dentro de macOS:

1. Abre la Mac App Store → instala **Xcode** (puede tardar bastante por la virtualización; ten
   paciencia y espacio en disco).
2. Abre Xcode → Settings → Platforms → instala los simuladores de iPhone/iPad que necesites.
3. Instala Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
4. Instala CocoaPods: `brew install cocoapods` (o `sudo gem install cocoapods`).
5. Verifica Swift Package Manager: `swift package --version` (viene con Xcode).
6. Crea un proyecto de prueba: Xcode → File → New → Project → iOS → App → Interface: SwiftUI,
   Language: Swift → ejecútalo en el simulador (▶) y confirma que compila y corre.

## 1.5 Entregables

- [ ] `especificaciones-equipo.md` completado
- [ ] Capturas del hardware de cada integrante
- [ ] Capturas paso a paso de la instalación (Docker + macOS arrancando + Xcode instalado)
- [ ] Proyecto Swift de prueba corriendo en el simulador (captura)
- [ ] `docs/bitacora.md` con al menos las sesiones reales del equipo
- [ ] Registro del integrante responsable del equipo utilizado
