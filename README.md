# runelite-web

Play Old School RuneScape with [RuneLite](https://runelite.net) from any web browser. The game runs in a Docker container (built for Unraid) and its desktop is streamed to your browser by [linuxserver's Selkies base image](https://github.com/linuxserver/docker-baseimage-selkies).

To log in with a **Jagex Account**, the image includes the open-source [Bolt launcher](https://codeberg.org/Adamcake/Bolt), a Linux replacement for the Jagex Launcher. Bolt handles the Jagex login and then starts RuneLite.

## Quick start (Unraid)

1. In Unraid, open **Docker → Add Container** and fill in:
   - **Repository:** `ghcr.io/grantm28/runelite-web:latest`
   - **Extra Parameters** (switch to Advanced View): `--security-opt seccomp=unconfined --shm-size=1g`
   - **Port:** host `38443` → container `3001` (any free host port works)
   - **Path:** `/config` → `/mnt/user/appdata/runelite-web`
   - **Variables:** `PUID=99`, `PGID=100`, `CUSTOM_USER=runelite`, `PASSWORD=<something>`

   Or copy [`unraid/runelite-web.xml`](unraid/runelite-web.xml) to `/boot/config/plugins/dockerMan/templates-user/my-runelite-web.xml` on the server. It will then appear under **Add Container → Template**.
2. Open `https://<unraid-ip>:38443` and accept the self-signed certificate warning.
3. Bolt opens. Click **Log in**, sign in with your Jagex Account (including 2FA), choose your character, pick **RuneLite** as the client, and click **Play**.

Everything is stored in `/config`: your Bolt login, RuneLite settings, plugins, and logs (`/config/logs`). It survives container updates.

## Docker Compose

```bash
docker compose up -d
```

See [`docker-compose.yml`](docker-compose.yml).

## Settings

| Variable | Default | Purpose |
|---|---|---|
| `CUSTOM_USER` / `PASSWORD` | – | Basic-auth login for the web page. **Set a password.** Without one, anyone who can reach the port can play your account. |
| `LAUNCH_MODE` | `bolt` | `bolt` opens the Bolt launcher. `runelite` starts RuneLite directly. |
| `BOLT_ARGS` | – | Extra flags for Bolt, such as `--no-sandbox` if its window stays blank. |
| `RUNELITE_JAVA_OPTS` / `RUNELITE_ARGS` | – | Extra JVM and launcher arguments for direct RuneLite launches. |
| `PUID` / `PGID` / `TZ` | – | The standard linuxserver user, group, and timezone settings. |

Right-click the desktop to relaunch Bolt or RuneLite, or to open a terminal.

## Login options

- **Jagex Account via Bolt** (default): log in inside the browser as described above.
- **Jagex Account via credentials file** (fallback if Bolt stops working):
  1. On a Windows or Mac PC, follow RuneLite's guide for the `--insecure-write-credentials` option. This writes `.runelite/credentials.properties`.
  2. Copy that file to `/mnt/user/appdata/runelite-web/.runelite/credentials.properties`.
  3. Set `LAUNCH_MODE=runelite`.

  Treat this file like a password.
- **Legacy (non-Jagex) accounts:** set `LAUNCH_MODE=runelite` and log in on the game's login screen.

## Troubleshooting

- **Logs:** Bolt writes to `/config/logs/bolt.log` and RuneLite to `/config/logs/runelite.log`. Both record start times and exit codes.
- **Black screen or no Bolt window:** right-click the desktop and choose **Bolt Launcher (restart)**, then check `bolt.log`.
- **Built-in fixes:** the launcher already handles the issues found so far:
  - It removes Selkies' `LD_PRELOAD` input shims, which crash Bolt.
  - It forces software rendering. Set `BOLT_GPU=true` only if you pass a working GPU through to the container.
  - It clears Chromium's stale profile lock, which would otherwise stop Bolt from starting after the container is recreated.
- **Behind Cloudflare Tunnel:** set the service type to `HTTPS` (pointing at the container's port) and turn on **No TLS Verify**, because the container uses a self-signed certificate.

## Notes and limitations

- The image is **amd64 only**. Bolt publishes Linux binaries only for x86-64.
- Bolt stopped publishing Linux binaries after **0.20.6**, so that version is pinned. To use a different build, rebuild with `--build-arg BOLT_URL=... --build-arg BOLT_SHA256=...`.
- Rendering is done in software with no GPU. RuneLite's GPU plugin still works through Mesa's llvmpipe, but it uses CPU. Turn it off if the server struggles.
- A GitHub Actions workflow rebuilds the image weekly to pick up base-image and RuneLite launcher updates. RuneLite also updates its own client each time it launches.
- Don't expose the web port to the internet without a password and, ideally, a reverse proxy or VPN in front of it.

This project is not affiliated with Jagex, RuneLite, or Bolt.
