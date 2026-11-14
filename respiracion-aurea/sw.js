// Service worker: guarda la app completa para usarla sin internet. Sube VERSION al publicar cambios.
const VERSION = 'vortice-aureo-v1.2';
const FILES = ['./', './index.html', './manifest.webmanifest', './fonts/fonts.css',
  './fonts/Sora.woff2', './fonts/IBMPlexMono-400.woff2', './fonts/IBMPlexMono-500.woff2',
  './icons/icon-192.png', './icons/icon-512.png', './icons/apple-touch-icon.png'];
self.addEventListener('install', e => e.waitUntil(caches.open(VERSION).then(c => c.addAll(FILES)).then(() => self.skipWaiting())));
self.addEventListener('activate', e => e.waitUntil(
  caches.keys().then(ks => Promise.all(ks.filter(k => k !== VERSION).map(k => caches.delete(k)))).then(() => self.clients.claim())));
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(caches.match(e.request, {ignoreSearch: true}).then(r => r || fetch(e.request)));
});
