#!/usr/bin/env bash
# Construye la APK de Stok a partir de ../inventario.html sin Gradle.
#   ./build.sh          → Inventario.apk  (versión normal, la de los usuarios)
#   ./build.sh beta     → Stok-Beta.apk   (versión de prueba: otro nombre, otro ícono y datos separados;
#                                          se instala al lado de la normal sin reemplazarla)
# Requisitos (Ubuntu/Debian):
#   apt-get install android-sdk-platform-23 android-sdk-build-tools dalvik-exchange apksigner zipalign default-jdk
set -euo pipefail
cd "$(dirname "$0")"

CHANNEL="${1:-stable}"
case "$CHANNEL" in stable|beta) ;; *) echo "Uso: ./build.sh [beta]" >&2; exit 1;; esac

SDK=/usr/lib/android-sdk
ANDROID_JAR="$SDK/platforms/android-23/android.jar"
KEYSTORE=inventario.keystore
KEYPASS=inventario
OUT=build

rm -rf "$OUT" && mkdir -p "$OUT/assets" "$OUT/classes" "$OUT/gen"
cp ../inventario.html "$OUT/assets/index.html"

MANIFEST=AndroidManifest.xml
RES=res
APK=Inventario.apk
if [ "$CHANNEL" = beta ]; then
  # Marca la página como beta (usa otras claves de guardado y muestra la etiqueta BETA).
  grep -q 'const BUILD_CHANNEL="";' "$OUT/assets/index.html"
  sed -i 's/const BUILD_CHANNEL="";/const BUILD_CHANNEL="beta";/' "$OUT/assets/index.html"
  # Otro identificador de app (para instalarse junto a la normal) y otro nombre.
  sed -e 's/package="com.reokip.inventario"/package="com.reokip.inventario.beta"/' \
      -e 's/android:label="Stok"/android:label="Stok Beta"/' AndroidManifest.xml > "$OUT/AndroidManifest.xml"
  grep -q 'com.reokip.inventario.beta' "$OUT/AndroidManifest.xml"
  MANIFEST="$OUT/AndroidManifest.xml"
  # Íconos azules con la palabra BETA.
  cp -r res "$OUT/res" && cp -r res-beta/. "$OUT/res/"
  RES="$OUT/res"
  APK=Stok-Beta.apk
fi

# Clave de firma: debe ser siempre la misma para poder actualizar la app sin perder los datos.
if [ ! -f "$KEYSTORE" ]; then
  keytool -genkeypair -keystore "$KEYSTORE" -storepass "$KEYPASS" -keypass "$KEYPASS" \
    -alias inventario -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Inventario" >/dev/null
fi

aapt package -f -m -J "$OUT/gen" -M "$MANIFEST" -S "$RES" -I "$ANDROID_JAR"
javac --release 8 -nowarn -classpath "$ANDROID_JAR" -d "$OUT/classes" \
  $(find src "$OUT/gen" -name '*.java') 2>&1 | grep -v 'bootstrap classpath\|^1 warning' || true
dalvik-exchange --dex --output="$OUT/classes.dex" "$OUT/classes"

# La versión visible es la de AndroidManifest.xml (versionName). El número interno (versionCode)
# sale de la cantidad de commits, así cada compilación nueva se instala encima de la anterior.
VERSION_CODE=$(( $(git rev-list --count HEAD 2>/dev/null || echo 1) + 100 ))
aapt package -f -M "$MANIFEST" -S "$RES" -A "$OUT/assets" -I "$ANDROID_JAR" -F "$OUT/unsigned.apk" \
  --version-code "$VERSION_CODE"
(cd "$OUT" && aapt add -f unsigned.apk classes.dex >/dev/null)
zipalign -f -p 4 "$OUT/unsigned.apk" "$OUT/aligned.apk"
apksigner sign --ks "$KEYSTORE" --ks-pass "pass:$KEYPASS" --key-pass "pass:$KEYPASS" --ks-key-alias inventario \
  --out "$APK" "$OUT/aligned.apk"
apksigner verify "$APK"
rm -f "$APK.idsig"
echo "Listo: $(pwd)/$APK ($(du -h "$APK" | cut -f1), versionCode $VERSION_CODE, canal $CHANNEL)"
