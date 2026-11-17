# Cuentas en Stok — plan

Estado: **propuesta, sin implementar**. Este documento describe cómo agregar cuentas de usuario a Stok,
paso a paso, sin romper lo que hoy funciona.

## Por qué

Hoy cada instalación guarda sus datos por separado (Claude, iPhone, Android). Eso significa que:

- si se pierde o se cambia el teléfono, se pierde el inventario (salvo que haya un respaldo descargado);
- no se puede ver la misma tienda en dos teléfonos;
- no pueden trabajar dos personas en la misma tienda (por ejemplo, la dueña y un vendedor).

Con cuentas, los datos de la tienda viven en un servidor y cada teléfono es una ventana a esos datos.

## Cómo lo vería la persona que usa la app

1. Al abrir Stok por primera vez: **"Crear cuenta"** o **"Entrar"** (con correo y contraseña, o con Google).
   También **"Seguir sin cuenta"**, que funciona como hoy, solo en el teléfono.
2. Si ya tenía datos en el teléfono: **"¿Subir tu inventario a tu cuenta?"** → se suben una vez.
3. En otro teléfono, al entrar con la misma cuenta, aparece todo.
4. En Ajustes → **Tu cuenta**: correo, cerrar sesión, y (más adelante) invitar a otras personas.
5. Sin internet la app sigue funcionando; los cambios se envían solos cuando vuelve la conexión.

## Servicio recomendado: Supabase

| | **Supabase** (recomendado) | Firebase |
|---|---|---|
| Base de datos | PostgreSQL (tablas, como Excel con reglas) | Documentos (Firestore) |
| Cuentas | Correo, Google, Apple, enlace mágico | Correo, Google, Apple, teléfono |
| Fotos | Storage incluido | Storage incluido |
| Plan gratis | 500 MB de datos, 1 GB de fotos, 50.000 usuarios/mes | Generoso, pero se cobra por lectura |
| Costo al crecer | Fijo: ~25 USD/mes (plan Pro) | Variable según uso; más difícil de prever |
| Reportes (ventas, márgenes) | Fácil con SQL | Más trabajo |
| Salirse después | Es PostgreSQL estándar: se exporta todo | Más amarrado a Google |

Para una app de inventario con ventas y reportes, las tablas de Supabase calzan mejor y el costo es predecible.

## Cómo se guardarían los datos

```
tiendas          id, nombre, tipo, aviso_stock, creada
miembros         tienda_id, usuario_id, rol (dueño | encargado | vendedor)
productos        id, tienda_id, código, nombre, categoría, uso, proveedor, mínimo, costo, precio, unidad, por_caja, foto
variantes        id, producto_id, nombre (talla/número/formato), stock, mínimo
movimientos      id, tienda_id, producto_id, variante, tipo, motivo, cantidad, precio, costo, pago, nota, usuario_id, fecha, anulado
lista_compra     tienda_id, producto_id, variante, cantidad
```

**Seguridad:** cada tabla tiene reglas en el servidor ("row level security"): una persona solo puede leer y
escribir las tiendas donde es miembro. Aunque alguien copie la clave pública de la app, no puede ver datos ajenos.

**Roles** (fase 3):
- **Dueño:** todo, incluidos costos, márgenes, respaldos e invitar personas.
- **Encargado:** productos, entradas, ajustes, ventas y reportes.
- **Vendedor:** solo vender y ver stock; no ve costos ni márgenes.

## Funcionar sin internet

La app seguirá guardando todo primero en el teléfono (como hoy) y tendrá una **cola de cambios pendientes**
que se envía cuando hay conexión. Los movimientos (ventas, entradas) nunca chocan entre sí porque cada uno
es un registro nuevo; el stock se recalcula a partir de ellos. Si dos personas editan el mismo producto a la
vez (por ejemplo el precio), gana el último cambio y queda registrado quién lo hizo.

## Fases

| Fase | Qué se logra | Esfuerzo aprox. |
|---|---|---|
| **1. Cuenta + copia en la nube** | Entrar con correo/Google. Cada vez que se guarda, se sube una copia completa de la tienda. En otro teléfono, al entrar, se descarga. Un solo teléfono a la vez editando. | 1–2 días |
| **2. Sincronización real** | Datos en tablas; varios teléfonos al mismo tiempo; cambios en vivo; funciona sin internet con cola de cambios. Fotos en Storage. | 4–6 días |
| **3. Equipo y roles** | Invitar por correo, roles dueño/encargado/vendedor, "registrado por" en cada venta. | 2–3 días |
| **4. Varias tiendas** | Una cuenta con más de una tienda o sucursal; cambiar de tienda desde Ajustes. | 1–2 días |

La fase 1 ya resuelve lo más urgente (no perder datos y cambiar de teléfono) y es fácil de deshacer.

## Qué pasa con cada versión

- **iPhone (GitHub Pages) y Android (APK):** reciben cuentas desde la fase 1.
- **Versión dentro de Claude:** guarda sus datos en la propia página de Claude y no puede conectarse a un
  servidor externo. Seguiría como está; para pasar datos se usa el respaldo.

## Qué se necesita de ti

1. Crear una cuenta gratis en **supabase.com** y un proyecto llamado `stok` (región: São Paulo, la más cercana a Chile).
2. Pasarme dos datos del proyecto (Settings → API): la **URL** (`https://xxxx.supabase.co`) y la **clave pública
   "anon"**. Ambas son públicas por diseño; la clave secreta ("service_role") **no** se comparte nunca.
3. Si quieres "Entrar con Google": crear las credenciales en Google Cloud (te guío paso a paso).
4. Una **política de privacidad** (la redacto yo): es obligatoria apenas la app guarda datos de personas,
   y también la pide Google Play.

Con eso, yo creo las tablas y las reglas de seguridad, programo la pantalla de entrada y la copia en la nube,
y lo pruebo antes de activarlo para todos.

## Decisiones pendientes

- ¿Entrar solo con correo, o también con Google? (Recomendado: ambos.)
- ¿"Seguir sin cuenta" se mantiene para siempre o solo como período de prueba?
- ¿Desde el inicio habrá más de una persona por tienda? (Define si conviene saltar directo a la fase 2.)
