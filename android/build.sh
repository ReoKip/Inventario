#!/usr/bin/env bash
# Construye Inventario.apk a partir de ../inventario.html sin Gradle.
# Requisitos (Ubuntu/Debian):
#   apt-get install android-sdk-platform-23 android-sdk-build-tools dalvik-exchange apksigner zipalign default-jdk
set -euo pipefail
cd "$(dirname "$0")"

SDK=/usr/lib/android-sdk
ANDROID_JAR="$SDK/platforms/android-23/android.jar"
KEYSTORE=inventario.keystore
KEYPASS=inventario
OUT=build

rm -rf "$OUT" && mkdir -p "$OUT/assets" "$OUT/classes" "$OUT/gen"
cp ../inventario.html "$OUT/assets/index.html"

# Clave de firma: debe ser siempre la misma para poder actualizar la app sin perder los datos.
if [ ! -f "$KEYSTORE" ]; then
  keytool -genkeypair -keystore "$KEYSTORE" -storepass "$KEYPASS" -keypass "$KEYPASS" \
    -alias inventario -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Inventario" >/dev/null
fi

aapt package -f -m -J "$OUT/gen" -M AndroidManifest.xml -S res -I "$ANDROID_JAR"
javac --release 8 -nowarn -classpath "$ANDROID_JAR" -d "$OUT/classes" \
  $(find src "$OUT/gen" -name '*.java') 2>&1 | grep -v 'bootstrap classpath\|^1 warning' || true
dalvik-exchange --dex --output="$OUT/classes.dex" "$OUT/classes"

aapt package -f -M AndroidManifest.xml -S res -A "$OUT/assets" -I "$ANDROID_JAR" -F "$OUT/unsigned.apk"
(cd "$OUT" && aapt add -f unsigned.apk classes.dex >/dev/null)
zipalign -f -p 4 "$OUT/unsigned.apk" "$OUT/aligned.apk"
apksigner sign --ks "$KEYSTORE" --ks-pass "pass:$KEYPASS" --key-pass "pass:$KEYPASS" --ks-key-alias inventario \
  --out Inventario.apk "$OUT/aligned.apk"
apksigner verify Inventario.apk
rm -f Inventario.apk.idsig
echo "Listo: $(pwd)/Inventario.apk ($(du -h Inventario.apk | cut -f1))"
