# Stocky

**Stocky** (antes "Inventario") es una app para llevar el inventario de una tienda: productos con fotos y variantes (tallas, números, formatos…),
ventas, entradas, cierre de caja, lista de compra, toma de inventario, Excel y respaldos.

- **App web:** [`inventario.html`](inventario.html), un solo archivo que funciona en el navegador.
- **App de Android (versión 0.1):** [descargar `Inventario.apk`](android/Inventario.apk?raw=1).
  Instrucciones de instalación en [`android/README.md`](android/README.md).
- **iPhone (y cualquier teléfono):** la app web se instala desde el navegador y funciona sin internet.
  Una vez publicada en una dirección web (por ejemplo con GitHub Pages), ábrela en **Safari**, toca
  **Compartir → Agregar a pantalla de inicio**. Los pasos también aparecen dentro de la app, en Ajustes.

Archivos de la app web instalable: `manifest.webmanifest`, `sw.js` (uso sin conexión), `icons/` e `index.html`
(redirige a `inventario.html`).
