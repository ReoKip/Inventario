# Inventario para Android

`Inventario.apk` es la app de inventario (`../inventario.html`) empaquetada para Android.
Funciona sin conexión; solo necesita internet para importar o exportar Excel.

## Instalar
1. Descarga `Inventario.apk` en el teléfono.
2. Ábrelo y permite "Instalar apps desconocidas" para el navegador o el gestor de archivos.
3. Si Play Protect avisa que la app es desconocida, elige "Instalar de todas formas".

Los datos se guardan en el teléfono. Para pasar tu inventario desde la versión de Claude:
en Claude usa **Ajustes → Descargar respaldo**, y en la app de Android **Ajustes → Restaurar respaldo**.

## Volver a construirla
Requiere Ubuntu o Debian con:

    apt-get install android-sdk-platform-23 android-sdk-build-tools dalvik-exchange apksigner zipalign default-jdk

Luego:

    ./build.sh

`inventario.keystore` es la clave con la que se firma la app. Usa siempre la misma: si cambia,
Android no deja actualizar la app instalada y habría que desinstalarla (y se perderían los datos).
Para una nueva versión, sube `versionCode` y `versionName` en `AndroidManifest.xml`.
