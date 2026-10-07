# Infinity Forge 0.3.1 — affichage iPad

Correction du cadrage de l’application web : fond et canvas utilisent toute la hauteur disponible, tandis que le contenu respecte les marges système. Le menu iPad est centré et agrandi ; textes et noms des cartes plus lisibles ; Réserve et commandes restent accessibles après redimensionnement. Le plateau reconstruit reste sous les fenêtres et les effets.

Ce lot modifie uniquement le client. Protocole 4, révision des règles 5 et empreinte `da42603253ac` sont identiques au serveur public 0.3.0 ; le serveur et sa configuration sont conservés. Les anciens binaires du client restent présents pour les fenêtres déjà ouvertes.

- Empreinte des sources : `93d1f8b60cfe8002564db5a59672f4ddf124c507b2bbbefff980ae889465eaaa`.
- Identifiant web : `3fe26aacafc4445cc694d46899ee215bae5bd01c9806f71b8e421fb9d186a489`.
- Sources issues de l’archive locale ; ces empreintes de contenu ne sont pas des commits de sources. Le commit de ce dépôt contient les livrables.
- Import et export Godot 4.7.2 contrôlés ; 178 tests GUT, 8122 assertions ; contrôles natifs de formats et de superposition, puis parcours du navigateur et mise à jour avec préférences conservées.
- Les marges iPad du navigateur de contrôle sont simulées ; la confirmation sur Safari/iPad matériel reste à faire.

La publication s’effectue par GitHub Pages. Ne pas déduire son résultat de ce fichier : vérifier le déploiement et les empreintes HTTPS de `release.json`. La mise à jour doit rester proposée depuis le menu et différée si une autre fenêtre du jeu est ouverte.

Retour client compatible : rétablir les fichiers du client `26665d88b8b5618a5520156aa271776a67c8db64` par un commit conservant l’historique, sans retirer les anciens assets ni modifier le serveur `9a80fb89db9aec055297aa09db3fb66be16c4c67`.
