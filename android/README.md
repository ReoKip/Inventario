# Stok para Android

`Inventario.apk` es Stok, la app de inventario (`../inventario.html`) empaquetada para Android.
Funciona sin conexión; solo necesita internet para importar o exportar Excel.

## Instalar
1. Descarga `Inventario.apk` en el teléfono.
2. Ábrelo y permite "Instalar apps desconocidas" para el navegador o el gestor de archivos.
3. Si Play Protect avisa que la app es desconocida, elige "Instalar de todas formas".

Los datos se guardan en el teléfono. Para pasar tu inventario desde la versión de Claude:
en Claude usa **Ajustes → Descargar respaldo**, y en la app de Android **Ajustes → Restaurar respaldo**.

## Versión de prueba

`./build.sh beta` crea `Stok-Beta.apk`: se llama "Stok Beta", tiene ícono azul y se instala **al lado**
de la versión normal (otro identificador de app: `com.reokip.inventario.beta`), con sus datos separados.

## Volver a construirla
Requiere Ubuntu o Debian con:

    apt-get install android-sdk-platform-23 android-sdk-build-tools dalvik-exchange apksigner zipalign default-jdk

Luego:

    ./build.sh

`inventario.keystore` es la clave con la que se firma la app. Usa siempre la misma: si cambia,
Android no deja actualizar la app instalada y habría que desinstalarla (y se perderían los datos).
La versión visible (`versionName`, hoy 0.2) se cambia a mano en `AndroidManifest.xml` solo cuando hay cambios importantes.
El número interno (`versionCode`) lo calcula `build.sh` a partir de los commits, para que cada APK nueva se instale encima de la anterior.
