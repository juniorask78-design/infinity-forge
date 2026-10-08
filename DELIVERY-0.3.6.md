# Infinity Forge 0.3.6 — interface et décors

Le client apporte les décors Hélios et Orvale, les plaques nuit et or et les nouveaux pictogrammes dessinés. La disposition place les héros et leurs ressources au centre, les piles à gauche et les commandes à droite. Les rangées de champions et les mains nombreuses restent accessibles par défilement. Les réglages conservent le choix du décor et le mode Grand texte.

Les illustrations des cartes, portraits, polices et règles sont conservés. Cette livraison concerne le client navigateur ; le serveur reste en 0.3.3, compatible par protocole 4, règles révision 6 et empreinte `e70e982e8094`. Aucune mise à jour serveur n'est nécessaire pour aligner les numéros de version cosmétiques.

## Identité du client

- Version : `0.3.6`.
- Build : `0e40161121c39bd15ee5e6cf6c74beb4c7cb838ce69ed424defff07f819903c2`.
- Empreinte des sources : `44b70e2ea0cbcc6a77b1ab46dd2eb621cb6996eb5813dac4e1da56dde70c9570`.
- Livraison : 16 fichiers décrits par `release.json`, plus ce manifeste et le service worker. Les binaires portent le préfixe du build ; le worker vérifie les empreintes avant la mise à jour consentie.
- Le manifeste décrit des sources extraites (`source_commit=null`), distinctes du commit Git de publication du site.

## Vérifications locales

Import et export Godot 4.7.2 terminés sans erreur ni avertissement. Suite actuelle : 187 tests réussis sur 187, 7 191 assertions. Sept formats natifs simulés, 3 720 contrôles et 29 contrôles de rotation réussis, dont densité, marges sûres, défilement et conservation de l'état.

Deux clients du nouveau paquet ont joué contre le paquet serveur 0.3.3 conservé : 265 coups, 891 contrôles des vues masquées, coupure puis reprise et fin normale concordante. L'identité publique HTTPS/WSS du serveur a été vérifiée avec TLS système. Le contrôle local ne certifie pas à lui seul un duel WSS public, Safari sur matériel Apple, une cadence d'images ou un budget mémoire mobile.

Le package a été joué dans un navigateur jusqu'à une défaite normale de Lyra face à Solen en difficulté Difficile, en huit manches. Cartes, recrutement, confirmations, piles, réglages, Grand texte, formats PC/tablette/téléphone et retour d'orientation ont été exercés ; la console ne contient aucune erreur ni avertissement. Les marges sûres et densités restent des simulations, pas une certification de Safari sur matériel Apple.

Cette notice accompagne le package validé. Le push et les contrôles publics après déploiement seront consignés séparément ; un commit local ne prouve pas une publication.

## Mise à jour et retour arrière

Accepter la proposition de mise à jour dans le jeu ; une autre fenêtre active peut différer le relancement. Les préférences doivent rester conservées, sans effacement manuel des données.

Le package contient 44 794 964 octets bruts. Les nouveaux décors et le kit augmentent sa taille par rapport à la version précédente ; aucune réduction du téléchargement ou du temps de lancement mobile n'est revendiquée.

Les anciens binaires restent disponibles. En cas de défaut, rétablir les fichiers client de 0.3.5 par un nouveau commit à partir de `9d8500fe826c94e026187d0fdb18e22a4214e4be`, conserver le serveur compatible et vérifier Pages, HTTPS et la proposition de mise à jour. Aucun reset ou force-push n'est nécessaire.
