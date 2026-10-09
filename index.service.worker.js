// Source du worker Infinity Forge. tools/local/package_web.py injecte une livraison vérifiée.
const RELEASE = {"version":"0.3.5","build_id":"a609864dae6ad9743486abb9f1f5490f2a8e3e16d7a09006bee1425b965d7dee","source_revision":"73dc3ba8e12ec5de96a305959b326081ddd4742803861ca87985b8a9ed4df716","protocol":4,"rules_revision":6,"source_commit":null,"source_archive":true,"files":{"COPYRIGHT_Godot.txt":{"bytes":100108,"sha256":"cb1980c88089573bcacd7221d777c689bb8bbd778799f24c27fca0fe5f774d6d"},"forge-a609864dae6ad974.audio.position.worklet.js":{"bytes":2973,"sha256":"be33985bc7160d6bf9646f259cd86b259cd67b02ccb297ee5c44f8ac84327bc8"},"forge-a609864dae6ad974.audio.worklet.js":{"bytes":7298,"sha256":"5b476a9c9ce642c0ee4256436d1bc31d9c38f868aca0f9a8e2a57c18d2dec2a3"},"forge-a609864dae6ad974.js":{"bytes":254525,"sha256":"662c951e5c2ca11c13a7afc3132c84ee6c7d7eaa43026a9aa61a55e8f290c737"},"forge-a609864dae6ad974.pck":{"bytes":11944712,"sha256":"53038bb946f0f48790a52cc4ca0b07061bb31a2eb89e9c84fed85d1bd340c310"},"forge-a609864dae6ad974.wasm":{"bytes":25019466,"sha256":"4d341042d0a211eb19ece46e2918d9f0b0baa3c4b1868e7dd4d803732be2c998"},"index.144x144.png":{"bytes":12627,"sha256":"25f5b0fc96b882c95b647b2734c22413c3ad50060f2d1397e69b69df4c4f3036"},"index.180x180.png":{"bytes":13954,"sha256":"d157638f10eacb292809d196a739ebe762819d38e6eee689fe1f507d412f2a62"},"index.512x512.png":{"bytes":82442,"sha256":"3f2314ae4fb6231d86f4b4605af2dc68367fcd04e33825f34a1134b3e1a5446d"},"index.apple-touch-icon.png":{"bytes":13954,"sha256":"d157638f10eacb292809d196a739ebe762819d38e6eee689fe1f507d412f2a62"},"index.html":{"bytes":19142,"sha256":"3fe64512f40a6d7481b5b8bf61c21ddc422402029c9da61825acf06e6d49ab19"},"index.icon.png":{"bytes":13954,"sha256":"d157638f10eacb292809d196a739ebe762819d38e6eee689fe1f507d412f2a62"},"index.manifest.json":{"bytes":488,"sha256":"2a971eedd570f0bc4774546e36354194081b86cb61b2ec872aa382a25a68b711"},"index.offline.html":{"bytes":971,"sha256":"b0a5d443e78f58717adac780bac91c1431bfa3b801c41f4707d507fb5ad2e47f"},"index.png":{"bytes":13959,"sha256":"f923378b12adf8954b4da4df9f8a1c8f897a71de1fdc2de9c1ff79fa282dcfd7"},"LICENSE_Godot.txt":{"bytes":1149,"sha256":"b0435e3b3e4e55238f05f4b306f30524a1b2e20147810d436eaa554fa6855c80"}}};
const PREFIX = 'infinity-forge:' + self.registration.scope + ':';
const CACHE = PREFIX + RELEASE.build_id;
const BASE = new URL('./', self.registration.scope);

async function verifiedResponse(name, entry) {
    // Les binaires immuables déjà chargés par le jeu peuvent venir du cache HTTP,
    // puis sont tout de même vérifiés. Le shell mutable doit être actualisé.
    const response = await fetch(new URL(name, BASE), {cache: name.startsWith('forge-') ? 'force-cache' : 'reload'});
    if (!response.ok) throw new Error('Livraison incomplète : ' + name);
    const bytes = await response.clone().arrayBuffer();
    const digest = await crypto.subtle.digest('SHA-256', bytes);
    const hash = Array.from(new Uint8Array(digest), n => n.toString(16).padStart(2, '0')).join('');
    if (hash !== entry.sha256 || bytes.byteLength !== entry.bytes) {
        throw new Error('Empreinte de livraison incorrecte : ' + name);
    }
    return response;
}

self.addEventListener('install', event => {
    event.waitUntil((async () => {
        const cache = await caches.open(CACHE);
        try {
            // Séquentiel pour éviter plusieurs tampons WASM/PCK simultanés sur téléphone.
            for (const [name, entry] of Object.entries(RELEASE.files)) {
                await cache.put(new URL(name, BASE), await verifiedResponse(name, entry));
            }
        } catch (error) {
            await caches.delete(CACHE);
            throw error;
        }
    })());
});

self.addEventListener('activate', event => {
    // Les caches précédents restent disponibles pour les anciens onglets et le retour de version.
    // Pas de clients.claim/navigate global : aucune partie voisine n'est rechargée.
    event.waitUntil(Promise.resolve());
});

self.addEventListener('fetch', event => {
    if (event.request.method !== 'GET') return;
    const url = new URL(event.request.url);
    if (!url.href.startsWith(BASE.href)) return;
    const name = url.href.slice(BASE.href.length).split('?')[0];
    const navigation = event.request.mode === 'navigate' && (name === '' || name === 'index.html');
    if (!navigation && !Object.hasOwn(RELEASE.files, name)) return;
    event.respondWith((async () => {
        const cache = await caches.open(CACHE);
        const key = navigation ? 'index.html' : name;
        const stored = await cache.match(new URL(key, BASE));
        if (stored) return stored;
        const response = await verifiedResponse(key, RELEASE.files[key]);
        await cache.put(new URL(key, BASE), response.clone());
        return response;
    })());
});

self.addEventListener('message', event => {
    event.waitUntil((async () => {
        const sender = event.source && await self.clients.get(event.source.id);
        if (!sender || !sender.url.startsWith(BASE.href)) return;
        if (!['update', 'claim'].includes(event.data)) return;
        const all = await self.clients.matchAll({type: 'window', includeUncontrolled: true});
        const others = all.filter(client => client.id !== sender.id && client.url.startsWith(BASE.href));
        if (others.length) {
            sender.postMessage({type: 'forge-update-deferred', other_tabs: others.length});
            return;
        }
        // Le seul onglet demandeur a consenti depuis son menu. Son shell décide du rechargement.
        sender.postMessage({type: 'forge-update-accepted', build_id: RELEASE.build_id});
        await self.skipWaiting();
        await self.clients.claim();
        // À cet instant il n'y a qu'une fenêtre consentante : garder la version
        // courante et le dernier cache précédent, sans accumuler chaque livraison.
        const previous = (await caches.keys()).filter(key => key.startsWith(PREFIX) && key !== CACHE);
        for (const key of previous.slice(0, -1)) await caches.delete(key);
    })());
});
