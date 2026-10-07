# Infinity Forge 0.3.4 — champions centrés

Le premier champion apparaît au milieu de sa rangée ; les suivants forment un groupe centré, puis défilant si nécessaire. Les dimensions et les autres zones de l’affichage iPad 0.3.3 validé par Ange sont conservées. Présentation téléphone, règles, ressources et serveur inchangés.

Sources modifiées puis importées et exportées avec Godot 4.7.2 installé sur le PC. Validation : 187 tests GUT / 7191 assertions ; 1582 contrôles géométriques indépendants, 48 gestes et 30 contrôles d’export ; duel complet Lyra gagné dans l’export navigateur, console propre. Les formats iPad sont simulés sur PC ; le retour matériel initial est la photo d’Ange.

Client : source `123b16f642a19fa1fa2177ffe55811285892b86056fa099f2a781aa41783a241`, build `46bcdb23f844389080123ce7d40defad650bca9852a9de217af8dd91fbbb498f`.

Serveur Render 0.3.3 conservé : commit `79fc6a929aea076aae83876bad1f6b7c676bb932`, protocole 4, règles révision 6 / `e70e982e8094`. Aucun redémarrage nécessaire pour ce correctif compatible de présentation.

Retour : rétablir le client `8d8b82fdd70cecf217c0e8701b43ddb011d7a2ca` ; conserver le serveur actuel. Les anciens binaires client sont conservés pour les installations en cache.
