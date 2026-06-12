const CACHE_NAME='merch-creativity-v1';
const ASSETS=['./','./index.html','./manifest.json','./service-worker.js','./assets/icon.png','./assets/logo_merch.png','./assets/product_blue.png','./assets/product_pink.png','./assets/product_monochrome.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE_NAME).then(c => c.addAll(ASSETS))); self.skipWaiting(); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))))); self.clients.claim(); });
self.addEventListener('fetch', e => { e.respondWith(caches.match(e.request).then(r => r || fetch(e.request))); });