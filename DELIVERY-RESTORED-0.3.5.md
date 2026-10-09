# Infinity Forge 0.3.5 — version historique rétablie

Le client exact 0.3.5 est rétabli après le retour temporaire à 0.3.2. Les fichiers du jeu sont ceux de la livraison historique ; les travaux plus récents et l’historique Git restent conservés.

- Client d’origine : `9d8500fe826c94e026187d0fdb18e22a4214e4be`.
- Build : `a609864dae6ad9743486abb9f1f5490f2a8e3e16d7a09006bee1425b965d7dee`.
- Source embarquée : `73dc3ba8e12ec5de96a305959b326081ddd4742803861ca87985b8a9ed4df716`.
- Réseau : protocole 4, règles 6, empreinte `e70e982e8094`.
- Serveur compatible d’origine : `79fc6a929aea076aae83876bad1f6b7c676bb932`, rétabli avant le client par `7bf5c7d465c6f9bbdd39b991c00de3b5d4e6abb1`.

Le serveur annonce 0.3.3 avec ces mêmes règles ; il est compatible avec le client 0.3.5. L’Éclat taillé/Réserve de 0.3.2 est retiré par ces règles. Les dispositions et finitions ultérieures ne sont pas incluses dans cette restauration exacte.

Les 18 fichiers du client et le paquet serveur ont été comparés aux fichiers historiques et à leurs empreintes. Une partie solo locale complète s’est terminée normalement en dix manches, et un duel local à deux clients a confirmé les actions, la reprise et la fin concordante. Le serveur rétabli annonce les règles attendues en HTTPS et WSS.

Un redémarrage du serveur ferme les salons en mémoire. Terminez les duels et fermez les autres fenêtres du jeu avant d’accepter la mise à jour proposée depuis le menu. L’effacement des préférences n’est pas nécessaire.

Les anciens binaires et une paire de retour restent conservés. La publication Pages, les fichiers HTTPS et le parcours public sont vérifiés séparément de la préparation de ce commit.
