# Stok

**Stok** es una app para llevar el inventario de una tienda: productos con fotos y variantes (tallas, números, formatos…),
ventas, entradas, cierre de caja, lista de compra, toma de inventario, Excel y respaldos.

- **App web (iPhone, Android o computador):** **https://reokip.github.io/Inventario/**
  En iPhone: ábrela en Safari → Compartir → Agregar a pantalla de inicio. El código es [`inventario.html`](inventario.html).
- **App de Android (versión 0.2):** [descargar `Inventario.apk`](android/Inventario.apk?raw=1).
  Instrucciones de instalación en [`android/README.md`](android/README.md).
- **iPhone (y cualquier teléfono):** la app web se instala desde el navegador y funciona sin internet.
  Ábrela en **Safari** desde https://reokip.github.io/Inventario/ y toca **Compartir → Agregar a pantalla de inicio**. Los pasos también aparecen dentro de la app, en Ajustes.

Archivos de la app web instalable: `manifest.webmanifest`, `sw.js` (uso sin conexión), `icons/` e `index.html`
(redirige a `inventario.html`).

## Versión de prueba (beta)

Cada cambio se publica primero en la **versión de prueba**. Cuando se aprueba, pasa a la versión normal.
La beta tiene otro nombre (Stok Beta), ícono azul con la palabra BETA y **datos separados**: se puede usar
al lado de la versión normal sin tocar el inventario real.

| | Versión normal (usuarios) | Versión de prueba |
|---|---|---|
| Web / iPhone | https://reokip.github.io/Inventario/ | https://reokip.github.io/Inventario/beta/ |
| Android | [`Inventario.apk`](android/Inventario.apk?raw=1) | [`Stok-Beta.apk`](https://github.com/ReoKip/Inventario/raw/beta/android/Stok-Beta.apk) |
| Rama de GitHub | `main` | `beta` |

Cómo avanza un cambio: se sube a la rama `beta` → se prueba en la beta → si está bien, se pasa a `main`.
GitHub publica las dos versiones solo, en menos de un minuto.

## En camino

- [Plan para agregar cuentas](docs/cuentas.md): entrar con correo o Google, datos en la nube y varios teléfonos por tienda.
