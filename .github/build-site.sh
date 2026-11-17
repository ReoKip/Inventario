#!/usr/bin/env bash
# Arma el sitio de GitHub Pages con las dos versiones de Stok:
#   /Inventario/        → versión normal (rama main), la que usan los usuarios
#   /Inventario/beta/   → versión de prueba (rama beta)
# Uso: .github/build-site.sh <carpeta-main> <carpeta-beta> <carpeta-salida>
# Si la carpeta beta no existe, el sitio se publica solo con la versión normal.
set -euo pipefail
MAIN="$1"; BETA="$2"; OUT="$3"

copy() { # copia el contenido publicable (sin git ni archivos de compilación)
  mkdir -p "$2"
  tar -C "$1" --exclude=.git --exclude=.github --exclude=android/build --exclude=docs -cf - . | tar -C "$2" -xf -
}

rm -rf "$OUT"
copy "$MAIN" "$OUT"
rm -rf "$OUT/beta"

if [ -d "$BETA" ] && [ -f "$BETA/inventario.html" ]; then
  copy "$BETA" "$OUT/beta"
  B="$OUT/beta"
  # Nombre e íconos propios, para que en la pantalla de inicio no se confunda con la versión normal.
  python3 - "$B" <<'PY'
import json, sys, pathlib
b = pathlib.Path(sys.argv[1])
m = json.loads((b / "manifest.webmanifest").read_text(encoding="utf8"))
m["name"] = "Stok Beta · versión de prueba"
m["short_name"] = "Stok Beta"
m["theme_color"] = m["background_color"] = "#e6ecf8"
(b / "manifest.webmanifest").write_text(json.dumps(m, ensure_ascii=False, indent=2) + "\n", encoding="utf8")
for name in ("inventario.html", "index.html"):
    f = b / name
    s = f.read_text(encoding="utf8")
    s = s.replace("<title>Stok · Inventario</title>", "<title>Stok Beta</title>").replace("<title>Stok</title>", "<title>Stok Beta</title>")
    s = s.replace('<meta name="apple-mobile-web-app-title" content="Stok">', '<meta name="apple-mobile-web-app-title" content="Stok Beta">')
    # que los buscadores no muestren la versión de prueba
    s = s.replace("<head>", '<head>\n<meta name="robots" content="noindex">', 1)
    f.write_text(s, encoding="utf8")
PY
  if [ -d "$B/icons-beta" ]; then cp "$B"/icons-beta/* "$B/icons/"; fi
  echo "Sitio armado: versión normal + beta"
else
  echo "Sitio armado: solo versión normal (no hay rama beta)"
fi
