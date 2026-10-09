# Restauration temporaire d’Infinity Forge 0.3.2

La version jouable revient au client historique 0.3.2, sans modification de ses fichiers exportés. Les travaux plus récents restent conservés et l’historique Git est préservé.

- Client d’origine : `bc434a3b58f185cc88a6cfb5c2ef731df439af42`.
- Build : `f923315be5fe52fcffe19bbd0b873f8e4fc9cd05e6b223f8888f59df45cf8cde`.
- Source embarquée : `3205a999677b9225f79399b3e3cbceea4fc092e2e8fd079ad82c35aac0245554`.
- Contrat réseau : protocole 4, règles 5, empreinte `da42603253ac`.
- Serveur compatible d’origine : `9a80fb89db9aec055297aa09db3fb66be16c4c67`, restauré par `afbf0e15a25c541ca869eeee266107dfb96f6d8f` avant le client.

Le serveur annonce historiquement 0.3.0 avec ces mêmes règles ; il est compatible avec le client 0.3.2. Ce retour rétablit notamment l’Éclat taillé et les comportements réseau de cette version. Les améliorations de reprise ajoutées après 0.3.2 ne sont pas incluses.

Les 18 fichiers du client sont identiques à l’export historique et à leurs empreintes. Le paquet serveur est également celui du commit d’origine ; Dockerfile et configuration Render sont conservés. La paire a été contrôlée localement avec deux clients, actions, fin et reconnexion.

La restauration du serveur ferme les salons en mémoire. Terminez vos duels et fermez les autres fenêtres du jeu avant d’accepter la mise à jour proposée depuis le menu. Les préférences ne doivent pas être effacées pour changer de version.

Les anciens binaires sont conservés pour le retour de secours. La publication et sa disponibilité sont vérifiées séparément de la préparation de ce commit.
