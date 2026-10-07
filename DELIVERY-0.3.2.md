# Client Infinity Forge 0.3.2

Correction des cartes déplacées qui restaient sur le terrain après un glissement : seule la copie animée bouge, les cartes réelles restent dans leurs rangées. Gestes et animations sont annulés proprement à la reprise, à la perte de focus et au changement de format.

Le bouton Abandonner dispose d'une place séparée des commandes. Les cartes adverses déjà jouées sont affichées dans une bande défilante avec accès à leur fiche. La main non jouée reste masquée en duel en ligne.

Le cadrage iPad de 0.3.1 est inclus. Ce lot ne modifie ni les règles ni le serveur : protocole 4, révision des règles 5, empreinte `da42603253ac`. Les anciens binaires immuables restent disponibles pour les fenêtres déjà ouvertes. Retour compatible au client publié `26665d88b8b5618a5520156aa271776a67c8db64`, par un nouveau commit de rétablissement sans redémarrage du serveur.

Version préparée et vérifiée : import, 178 tests GUT (8122 assertions), 151 contrôles de gestes, 23 contrôles HUD et 31 contrôles des cartes publiques. Export final joué dans le navigateur : achats acceptés/refusés, deux clients contre le serveur local, redimensionnement, reprise, abandon concordant et épreuve solo gagnée. Consoles sans avertissement ni erreur. Mise à jour locale 0.3.1→0.3.2 réussie avec préférences conservées. Les formats PC/iPad/téléphone sont contrôlés ; validation sur iPad matériel encore nécessaire.

Build `f923315be5fe52fcffe19bbd0b873f8e4fc9cd05e6b223f8888f59df45cf8cde`, sources `3205a999677b9225f79399b3e3cbceea4fc092e2e8fd079ad82c35aac0245554`. Cette note décrit le lot prêt et ne confirme pas sa publication. Journal des sources : `docs/implementation/2026-10-07/BATTLE-0.3.2.md`.
