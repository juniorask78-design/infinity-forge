# Infinity Forge 0.3.3 — serveur

Suppression de la Réserve et de l'Éclat taillé ; six emplacements de marché. Reprise sans résultat inventé, vues capturées stables. Export avec Godot 4.7.2 déjà installé sur le PC.

Identité : version 0.3.3, protocole 4, règles révision 6, empreinte e70e982e8094. Source : 0df05d9f60c5e46db806028f0c5abb16428745dd901b4071961b0d6b76addf93.
Paquet serveur SHA256 : 41643e1c8f2342e0a3a8f5c89b02a8998e974425cd5dbffd32dd24b3d25b556c.
Client compatible : build 121c811e6bc0fa71ba1f4c634a9a8bff56d1921ba0e3a5721e1c0d4ce19656c7.

Validation : 187 tests GUT, 7191 assertions ; contrat final 29 contrôles ; serveur PCK réellement lancé localement avec identité concordante. La dernière correction de deux champs de texte a passé 12 contrôles ciblés. Infrastructure Docker/Render inchangée.

Déployer ce serveur avant le client. Les salons en mémoire sont fermés au redémarrage. Les anciens clients reçoivent une demande de mise à jour explicite.
Retour compatible : rétablir par nouveaux commits le serveur du commit 9a80fb89db9aec055297aa09db3fb66be16c4c67 puis le client bc434a3b58f185cc88a6cfb5c2ef731df439af42. Les anciens fichiers immuables du site sont conservés ; les salons perdus ne sont pas restaurés.
