# Especificaciones comparativas de las PCs del equipo

Práctica realizada de forma individual (equipo de un solo integrante), por lo que no hay
comparación entre varias PCs: se documenta la única máquina disponible.

| Integrante | Boleta | CPU | RAM | Almacenamiento libre | Virtualización (VT-x/AMD-V) | SO |
|---|---|---|---|---|---|---|
| Javier de Jesús Gamez Rosas | 2022630007 | AMD Ryzen 7 3750H con Radeon Vega Mobile Gfx (4 núcleos / 8 hilos) | 29.9 GB | 50.2 GB libres de 476 GB (unidad C:) | Habilitada (AMD-V) | Windows 11 Home (Build 26200) |

## PC seleccionada para el entorno macOS

- **Integrante responsable:** Javier de Jesús Gamez Rosas
- **Boleta:** 2022630007
- **Justificación:** único integrante y única PC disponible del equipo; cuenta con RAM suficiente (30 GB) y virtualización por hardware habilitada (AMD-V), requisitos mínimos para correr macOS en Docker.
- **¿Alguien tiene Mac física?** No.

> ⚠️ **Riesgo detectado:** el repositorio `MacOS-Docker` recomienda 60–100+ GB libres para la instalación, y esta PC solo tiene ~50 GB libres en el disco C:. Antes de iniciar la instalación, liberar espacio (o usar un disco/partición con más espacio) para evitar que la instalación falle a la mitad.

## Capturas de hardware

Pendiente: agregar captura de `Configuración > Sistema > Acerca de` (Windows) confirmando estos
datos.
