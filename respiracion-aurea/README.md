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
- Tema claro/oscuro automático; preferencias guardadas en `localStorage`.

## Uso
Abrir `index.html` en cualquier navegador, o publicarlo con GitHub Pages / Vercel / cPanel tal cual.
