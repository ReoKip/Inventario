// Permite usar la app web sin conexión una vez instalada.
// La página se pide primero a la red (para recibir actualizaciones) y, sin conexión, se usa la copia guardada.
// La versión normal vive en /Inventario/ y la de prueba en /Inventario/beta/: cada una tiene su propio
// service worker y su propia copia guardada, y ninguna borra la de la otra.
const BETA = self.registration.scope.includes("/beta/");
const PREFIX = BETA ? "stok-beta-" : "stok-";
const CACHE = PREFIX + "v4";
const SHELL = ["./", "./inventario.html", "./manifest.webmanifest", "./icons/apple-touch-icon.png", "./icons/icon-192.png", "./icons/icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  const mine = k => BETA ? k.startsWith("stok-beta-") : !k.startsWith("stok-beta-");
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => mine(k) && k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  // La cuenta en la nube (Supabase) siempre va directo a internet: nunca se guarda una copia.
  if (url.hostname.endsWith(".supabase.co")) return;
  // La versión normal no guarda archivos de la beta (la beta tiene su propio service worker).
  if (!BETA && url.origin === location.origin && url.pathname.includes("/beta/")) return;
  const isPage = req.mode === "navigate" || url.pathname.endsWith(".html");
  if (isPage) {
    e.respondWith(fetch(req).then(res => {
      const copy = res.clone(); caches.open(CACHE).then(c => c.put(req, copy)); return res;
    }).catch(() => caches.match(req, { cacheName: CACHE }).then(r => r || caches.match("./inventario.html", { cacheName: CACHE }))));
    return;
  }
  // Íconos, fuentes y la librería de Excel: copia guardada al instante y se actualiza en segundo plano.
  e.respondWith(caches.open(CACHE).then(c => c.match(req).then(hit => {
    const net = fetch(req).then(res => {
      if (res && (res.ok || res.type === "opaque")) c.put(req, res.clone());
      return res;
    }).catch(() => hit);
    return hit || net;
  })));
});
