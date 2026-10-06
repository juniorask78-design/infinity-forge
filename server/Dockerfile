# Serveur en ligne d'Infinity Forge pour Render (ou tout hébergeur Docker).
# Ce dossier ne contient PAS les sources du jeu : seulement le paquet serveur exporté
# (infinity_forge_server.pck : règles, réseau, données ; ni images ni sons).
# Régénérer le paquet : tools/server/exporter_serveur.sh (projet Godot, préréglage « Serveur »).
#   docker build -t infinity-forge-serveur server
#   docker run -p 8910:8910 -e PORT=8910 infinity-forge-serveur
# Le serveur écoute sur 0.0.0.0:$PORT. GET / → « Infinity Forge – serveur en ligne » ;
# les WebSocket arrivent sur le même port. Le chiffrement (wss://) est fait par l'hébergeur.

FROM ubuntu:24.04 AS godot
ARG GODOT_VERSION=4.7.2
# Empreinte officielle (SHA512-SUMS.txt de la version sur github.com/godotengine/godot-builds).
ARG GODOT_SHA512=9aa00f7a605200940bce3027a567b782f49bd8e940dd06ae9e987bd65aee1b1467edd56ed84fcdcbdd44354bf613bdbb4e5d2913e925850368e150c59ed54c65
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl unzip \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL -o /tmp/godot.zip \
      "https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
    && echo "${GODOT_SHA512}  /tmp/godot.zip" | sha512sum -c - \
    && unzip -q /tmp/godot.zip -d /tmp/godot \
    && install -m 755 "/tmp/godot/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot \
    && rm -rf /tmp/godot /tmp/godot.zip

FROM ubuntu:24.04
COPY --from=godot /usr/local/bin/godot /usr/local/bin/godot
COPY infinity_forge_server.pck /app/infinity_forge_server.pck
# Utilisateur sans droits particuliers ; HOME accueille le petit dossier de données de Godot.
RUN useradd --create-home --uid 10001 serveur
USER serveur
ENV PORT=8910
EXPOSE 8910
CMD ["/usr/local/bin/godot", "--headless", "--main-pack", "/app/infinity_forge_server.pck", "-s", "res://tools/server/server.gd"]
