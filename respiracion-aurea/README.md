# Vórtice Áureo — respiración consciente en proporción áurea

App web de un solo archivo (`index.html`, sin dependencias ni build) que guía la respiración
siguiendo la secuencia de Fibonacci, cuyas razones consecutivas se aproximan a φ ≈ 1.618:

| Paso | Inhala | Exhala |
|------|--------|--------|
| 1 | 13 s | 13 s |
| 2 | 8 s *(opcional)* | 8 s |
| 3 | 5 s | 5 s |
| 4 | 3 s | 3 s |
| 5 | 2 s | 2 s |
| 6 | 1 s | 1 s |
| 7 | Sostener (libre, 5, 8, 13 o 21 s) | — |

## Funciones
- Espiral áurea animada (13×21) con el cuadro activo resaltado y un punto que recorre el arco.
- Tonos de inhalación/exhalación (Web Audio), voz guía opcional en es-MX, pulso por segundo.
- 1–5 ciclos, retención libre con botón **Soltar**, pausa con barra espaciadora.
- Mantiene la pantalla encendida (Wake Lock) y vibra en Android cuando el navegador lo permite.
- **Música áurea de fondo** generada en tiempo real (Web Audio, sin archivos): bordón en frecuencias
  de Fibonacci 89 · 144 · 233 · 377 Hz (razón ≈ φ), cada voz modulada con periodos de 8, 13, 21 y 34 s,
  filtro que abre y cierra cada 55 s y campanas con parciales f · fφ · fφ² en una escala φ^(k/4),
  espaciadas 3, 5, 8, 13 y 21 s. Volumen ajustable.
- Tema claro/oscuro automático; preferencias guardadas en `localStorage`.

## Uso web
Abrir `index.html` en cualquier navegador, o publicarlo con GitHub Pages / Vercel / cPanel tal cual.

## APK Android (100 % sin internet)
`android/` empaqueta la misma app en un WebView nativo, sin permiso de INTERNET y con las fuentes incluidas.
Añade voz guía con el TTS del teléfono (es-MX), vibración nativa y pantalla siempre encendida.

```bash
# Ubuntu 24.04 / WSL
sudo apt-get install -y aapt zipalign apksigner android-sdk-platform-23 dalvik-exchange openjdk-17-jdk
cd android && ./build.sh        # -> android/build/VorticeAureo.apk
```

- minSdk 21 (Android 5.0), targetSdk 34. ~110 KB.
- La primera compilación crea la llave de firma en `~/.vortice-aureo/release.jks`. Respáldala:
  las actualizaciones solo se instalan encima si están firmadas con la misma llave.
- Instalación: copiar el APK al teléfono → abrirlo → permitir "Instalar apps desconocidas".

## Descarga directa del APK
[VorticeAureo.apk (v1.1)](https://github.com/octadragon17/octadragon17/raw/claude/conscious-breathing-app-94y10d/respiracion-aurea/descargas/VorticeAureo.apk)
