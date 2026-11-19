# RuneLite in the browser, with Jagex Account login via the Bolt launcher.
# Desktop is streamed to the browser by linuxserver's Selkies base image.
FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

LABEL org.opencontainers.image.title="runelite-web" \
      org.opencontainers.image.description="RuneLite (Old School RuneScape) in your browser, with Jagex Account support via Bolt" \
      org.opencontainers.image.licenses="MIT"

# Bolt no longer publishes Linux binaries after 0.20.6; override at build time if needed.
ARG BOLT_URL="https://codeberg.org/Adamcake/Bolt/releases/download/0.20.6/Bolt-Linux.zip"
ARG BOLT_SHA256="f5a6c709290d73fb306858ac0526fb00afb02c804f1d92159dbd8459cd3318eb"
ARG JAVA_VERSION=17

ENV TITLE="RuneLite" \
    JAVA_HOME=/opt/java \
    PATH="/opt/java/bin:${PATH}" \
    LAUNCH_MODE=bolt \n    RESTART_APP=true

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates curl unzip jq \
      # CEF / Chromium runtime libraries used by Bolt
      libnss3 libnspr4 libxss1 libxcomposite1 libxdamage1 libxrandr2 libxkbcommon0 \
      libxkbcommon-x11-0 libxtst6 libxi6 libgbm1 libdrm2 libpango-1.0-0 libcairo2 \
      libasound2t64 libgtk-3-0t64 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 \
      libarchive13t64 libluajit-5.1-2 libxcb1 libx11-xcb1 libdbus-1-3 \
      # OpenGL (software rendering for RuneLite GPU plugin) + fonts
      libgl1 libgl1-mesa-dri libegl1 mesa-utils fonts-dejavu-core fontconfig \
      # Small terminal for troubleshooting from the right-click menu
      xterm; \
    \
    # Java runtime for RuneLite (Eclipse Temurin)
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in amd64) jarch=x64 ;; arm64) jarch=aarch64 ;; *) echo "unsupported arch $arch"; exit 1 ;; esac; \
    mkdir -p /opt/java; \
    curl -fsSL "https://api.adoptium.net/v3/binary/latest/${JAVA_VERSION}/ga/linux/${jarch}/jdk/hotspot/normal/eclipse" \
      | tar -xz -C /opt/java --strip-components=1; \
    /opt/java/bin/java -version; \
    \
    # RuneLite launcher jar (for direct / non-Bolt launching)
    mkdir -p /opt/runelite; \
    curl -fsSL -o /opt/runelite/RuneLite.jar \
      "https://github.com/runelite/launcher/releases/latest/download/RuneLite.jar"; \
    \
    # Bolt launcher (Jagex Account login)
    if [ "$arch" = "amd64" ]; then \
      curl -fsSL -o /tmp/bolt.zip "$BOLT_URL"; \
      if [ -n "$BOLT_SHA256" ]; then echo "$BOLT_SHA256  /tmp/bolt.zip" | sha256sum -c -; fi; \
      mkdir -p /opt/bolt; \
      unzip -q /tmp/bolt.zip -d /opt/bolt; \
      rm /tmp/bolt.zip; \
      boltbin="$(find /opt/bolt -maxdepth 4 -type f -name bolt | head -n1)"; \
      test -n "$boltbin"; \
      chmod -R a+rX /opt/bolt; chmod +x "$boltbin"; \
      ln -sf "$boltbin" /usr/local/bin/bolt; \
    fi; \
    \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY root/ /

RUN chmod +x /usr/local/bin/runelite-start /usr/local/bin/bolt-start /usr/local/bin/runelite-direct

# Selkies web UI (HTTPS)
EXPOSE 3001
VOLUME /config
