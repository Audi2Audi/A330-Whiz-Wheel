// A330 Whiz Wheel service worker
// Cache-first with background refresh (stale-while-revalidate):
// launch NEVER waits on the network — critical on restricted/captive
// in-flight Wi-Fi where fetches hang rather than fail. Updates are
// fetched in the background and apply on the next launch.
const CACHE = "whizwheel-v2";
const ASSETS = ["./", "./index.html", "./manifest.json", "./icon-192.png", "./icon-512.png"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  if (e.request.method !== "GET") return;
  e.respondWith(
    caches.match(e.request, { ignoreSearch: true }).then((cached) => {
      // Background refresh — never blocks the response
      const refresh = fetch(e.request)
        .then((resp) => {
          if (resp && resp.ok) {
            const copy = resp.clone();
            caches.open(CACHE).then((c) => c.put(e.request, copy));
          }
          return resp;
        })
        .catch(() => cached);
      // Serve cache instantly when available; fall back for navigations
      if (cached) return cached;
      if (e.request.mode === "navigate") {
        return refresh.then((r) => r || caches.match("./index.html"))
          .catch(() => caches.match("./index.html"));
      }
      return refresh;
    })
  );
});
