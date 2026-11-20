# RuneLite in the browser, with Jagex Account login via the Bolt launcher.
# The desktop is streamed to the browser by linuxserver's Selkies base image.
FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

ARG VERSION="dev"
# Bolt no longer publishes Linux binaries after 0.20.6; override at build time if needed.
ARG BOLT_VERSION="0.20.6"
ARG BOLT_URL="https://codeberg.org/Adamcake/Bolt/releases/download/${BOLT_VERSION}/Bolt-Linux.zip"
ARG BOLT_SHA256="f5a6c709290d73fb306858ac0526fb00afb02c804f1d92159dbd8459cd3318eb"
ARG JAVA_VERSION=17

LABEL org.opencontainers.image.title="runelite-web" \
      org.opencontainers.image.description="RuneLite (Old School RuneScape) in your browser, with Jagex Account login via Bolt" \
      org.opencontainers.image.source="https://github.com/GrantM28/runelite-web" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.licenses="MIT"

ENV TITLE="RuneLite" \
    JAVA_HOME=/opt/java \
    PATH="/opt/java/bin:${PATH}" \
    LAUNCH_MODE=bolt \
    RESTART_APP=true \
    # Stream defaults tuned for OSRS on CPU-only servers (all overridable at runtime)
    SELKIES_FRAMERATE="30,8-60" \
    SELKIES_WEBCAM_ENABLED=false \
    SELKIES_UI_SIDEBAR_SHOW_WEBCAM=false \
    SELKIES_MICROPHONE_ENABLED=false \
    SELKIES_UI_SIDEBAR_SHOW_APPS=false \
    SELKIES_PRINTING_ENABLED=false \
    NO_GAMEPAD=true

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates curl unzip jq \
      # CEF / Chromium runtime libraries used by Bolt
      libnss3 libnspr4 libxss1 libxcomposite1 libxdamage1 libxrandr2 libxkbcommon0 \
      libxkbcommon-x11-0 libxtst6 libxi6 libgbm1 libdrm2 libpango-1.0-0 libcairo2 \
      libasound2t64 libgtk-3-0t64 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 \
      libarchive13t64 libluajit-5.1-2 libxcb1 libx11-xcb1 libdbus-1-3 \
      # OpenGL (software rendering for RuneLite's GPU plugin) + fonts
      libgl1 libgl1-mesa-dri libegl1 mesa-utils fonts-dejavu-core fontconfig \
      # Troubleshooting tools (right-click menu) and screenshot/smoke-test helpers
      xterm x11-utils xdotool imagemagick librsvg2-bin; \
    \
    # Java runtime for RuneLite (Eclipse Temurin)
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in amd64) jarch=x64 ;; arm64) jarch=aarch64 ;; *) echo "unsupported arch $arch"; exit 1 ;; esac; \
    mkdir -p /opt/java; \
    curl -fsSL "https://api.adoptium.net/v3/binary/latest/${JAVA_VERSION}/ga/linux/${jarch}/jdk/hotspot/normal/eclipse" \
      | tar -xz -C /opt/java --strip-components=1; \
    \
    # RuneLite launcher jar (used directly, and the same launcher Bolt runs)
    mkdir -p /opt/runelite; \
    rl_ver="$(curl -fsSL https://api.github.com/repos/runelite/launcher/releases/latest | jq -r .tag_name || echo unknown)"; \
    curl -fsSL -o /opt/runelite/RuneLite.jar \
      "https://github.com/runelite/launcher/releases/latest/download/RuneLite.jar"; \
    \
    # Bolt launcher (Jagex Account login)
    if [ "$arch" = "amd64" ]; then \
      curl -fsSL -o /tmp/bolt.zip "$BOLT_URL"; \
      if [ -n "$BOLT_SHA256" ]; then echo "$BOLT_SHA256  /tmp/bolt.zip" | sha256sum -c -; fi; \
      mkdir -p /opt/bolt; \
      unzip -q /tmp/bolt.zip -d /opt/bolt; \
      boltbin="$(find /opt/bolt -maxdepth 4 -type f -name bolt | head -n1)"; \
      test -n "$boltbin"; \
      chmod -R a+rX /opt/bolt; chmod +x "$boltbin"; \
      ln -sf "$boltbin" /usr/local/bin/bolt; \
    fi; \
    \
    # Record component versions (shown in the container log at start)
    mkdir -p /etc/runelite-web; \
    { echo "runelite-web      ${VERSION}"; \
      echo "Bolt launcher     ${BOLT_VERSION}"; \
      echo "RuneLite launcher ${rl_ver}"; \
      echo "Java              $(/opt/java/bin/java -version 2>&1 | head -n1)"; } > /etc/runelite-web/versions; \
    \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY root/ /
COPY assets/icon.svg /usr/share/runelite-web/icon.svg

RUN set -eux; \
    chmod +x /usr/local/bin/* /etc/s6-overlay/s6-rc.d/init-runelite-config/run; \
    # Stored as menu.openbox in the repo so the Unraid CA scanner doesn't treat it as a template
    mv /defaults/menu.openbox /defaults/menu.xml; \
    # Browser tab / PWA icon
    rsvg-convert -w 256 -h 256 /usr/share/runelite-web/icon.svg -o /usr/share/runelite-web/icon.png; \
    mkdir -p /usr/share/selkies/www; \
    cp /usr/share/runelite-web/icon.png /usr/share/selkies/www/icon.png

# Healthy once the web server answers (any HTTP status, including 401 when a password is set)
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -s -o /dev/null http://127.0.0.1:3000/ || exit 1

# Selkies web UI (HTTPS, self-signed). 3000 is plain HTTP for TLS-terminating reverse proxies.
EXPOSE 3000 3001
VOLUME /config
