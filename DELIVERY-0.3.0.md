# Livraison locale Infinity Forge 0.3.0 — 7 octobre 2026

Cette branche prépare la version 0.3.0. Aucun push, déploiement Render ou publication Pages n'a été effectué pour sa préparation. La présence de cet export local ne démontre pas la disponibilité du service public.

## Identité des exports

- Version : **0.3.0** ; protocole : **4** ; révision de règles : **5**.
- Empreinte SHA256 des sources archivées : `f204c529d3a6e51b3997ff52f2d0a813f515c58cfe1d87c19afa68e0664bfe66`.
- Identifiant du build web : `bf049ba13363bc456ea8180c7b92ef398a93616fce1bc6e93148cb4f0a0843e6`.
- SHA256 du paquet serveur : `613033fe5f942837db902c62666d6a6f44ec4a28220b25e4c91034ea78f45c03` ; 545 820 octets.
- Les sources proviennent d'une archive extraite sans historique Git source : `source_archive=true`, `source_commit=null`. L'empreinte source est une identité de contenu, **pas un commit de sources**. Les commits de cette branche concernent les livrables de déploiement.
- `release.json` décrit les empreintes du contenu web versionné. Les règles `.gitattributes` préservent exactement les octets des exports et manifestes.

Le parent commun Git de cette préparation est `b31a1b1b190075d1304b11aad25b13c408cbcf87`. Le premier commit est `9a80fb89db9aec055297aa09db3fb66be16c4c67` et ne change que le paquet serveur, Dockerfile, render.yaml et leurs attributs Git. Le commit suivant ajoute l'export client et cette notice.

## Conditions avant publication

**Publication bloquée tant que le proxy Render n'est pas confirmé et que le conteneur Docker/Linux n'est pas réellement contrôlé.** L'inspection du Dockerfile, les essais Windows et le paquet local ne remplacent pas la construction et l'exécution Linux. Confirmer les IP exactes des proxies et leur assainissement de `X-Forwarded-For` avant de configurer `INFINITY_FORGE_TRUSTED_PROXIES` ; ne pas autoriser tous les proxies. Sans configuration vérifiée, les utilisateurs derrière une même IP partagent la limite de huit connexions.

Vérifier aussi l'accès au dépôt/hébergeur, les branches et mécanismes Pages/Render réellement utilisés, ainsi que l'impact du redémarrage sur les salons en mémoire. Aucun abonnement ni modification d'offre n'est nécessaire à cette préparation.

## Ordre de livraison à respecter

1. Livrer uniquement le **commit serveur**. Ne pas pousser les deux commits ensemble en supposant que Render et Pages finiront dans le bon ordre. Vérifier les déclencheurs avant toute opération externe.
2. Attendre le serveur réellement déployé : HTTPS `/healthz` retourne 200, `ready=true`, version 0.3.0, protocole 4, règles 5 et empreinte source attendue. Le `welcome` WSS doit annoncer la même identité. Un health local n'est pas une preuve de routage HTTPS/WSS public.
3. Livrer ensuite le **commit client**. Contrôler le site réellement servi, les empreintes, le cache/PWA existant et neuf, les préférences, un duel et une reprise sur le serveur public.

Les fichiers anciens `index.js`, `index.wasm`, `index.pck`, `index.audio.worklet.js` et `index.audio.position.worklet.js` sont conservés sans changement. Les nouveaux fichiers `forge-bf049ba13363bc45.*` sont ajoutés à côté. Cette conservation évite de retirer les fichiers demandés par des clients déjà en cache ; elle ne garantit pas qu'un ancien client puisse jouer avec les nouvelles règles du serveur.

## Retour arrière

Conserver le parent commun et la paire serveur/client précédente. Le parent commun ci-dessus est le candidat disponible dans ce clone ; son statut de dernière version publique validée doit être confirmé avant emploi. Préparer le rétablissement en deux lots compatibles : serveur précédent, contrôle health/WSS, puis client précédent. Préserver l'historique avec des commits de rétablissement, sans reset forcé ni suppression des fichiers versionnés nécessaires aux caches existants. Un retour ne restaure pas les salons perdus lors d'un redémarrage.

Le bundle Git accompagne cette branche pour son transfert local. L'importer, inspecter les commits et vérifier ses empreintes n'effectue aucune publication ; le pousser peut déclencher Render/Pages et nécessite donc la levée des conditions ci-dessus.
