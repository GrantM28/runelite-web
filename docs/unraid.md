# Installing on Unraid

## Option A: install the template (recommended)

1. Open the Unraid web terminal (the **>_** icon in the top bar) and run:
   ```bash
   wget -O /boot/config/plugins/dockerMan/templates-user/my-runelite-web.xml \
     https://raw.githubusercontent.com/GrantM28/runelite-web/main/unraid/runelite-web.xml
   ```
2. Go to **Docker → Add Container**, open the **Template** dropdown, and pick **runelite-web** under *User templates*.
3. Fill in **Web password**. Change **WebUI (HTTPS)** if port 38443 is already in use.
4. Click **Apply**. The first pull is about 1.5 GB.
5. When the container is running, click its icon and choose **WebUI**.

## Option B: fill in the form by hand

Go to **Docker → Add Container**, switch to **Advanced View**, and enter:

| Field | Value |
|---|---|
| Repository | `ghcr.io/grantm28/runelite-web:latest` |
| Extra Parameters | `--security-opt seccomp=unconfined --shm-size=1g` |
| Port | Container port `3001`. Pick any free host port, e.g. `38443` |
| Path | Container `/config` → `/mnt/user/appdata/runelite-web` |
| Variable | `CUSTOM_USER` = a username |
| Variable | `PASSWORD` = a strong password |
| Variable | `PUID` = `99`, `PGID` = `100` |

## First run

1. Browse to `https://<unraid-ip>:<port>`. The certificate is self-signed, so accept the browser warning.
2. Sign in with your web username and password.
3. Bolt opens. Click **I Understand**, then **Login**, and sign in with your Jagex Account. 2FA works.
4. Pick **RuneLite** as the game client, choose your character, and click **Play**.

Your Bolt login stays saved in appdata, so later you only need to click **Play**.

## Updating

Click **Check for Updates** on the Docker tab, then **Apply update**. Your login, plugins, and settings are kept. If Unraid doesn't notice a new version, use the container's **Force Update**.

## CPU pinning

Rendering and video encoding both run on the CPU. Give the container at least 4 cores under **Edit → CPU Pinning**, and avoid sharing those cores with heavy containers. See [performance.md](performance.md).
