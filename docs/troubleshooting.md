# Troubleshooting

## Where to look

- **Container log** (Unraid: container icon → *Logs*). Shows component versions at startup and a warning if no password is set.
- **`<appdata>/logs/bolt.log`**: Bolt start and exit times, exit codes, and errors.
- **`<appdata>/logs/runelite.log`**: output from the RuneLite launcher.
- **`<appdata>/.runelite/logs/client.log`**: RuneLite's own client log.
- **Right-click menu → View logs** shows both log files live inside the stream.

## Common problems

**Black screen, but the Selkies sidebar is visible**
Bolt or RuneLite isn't running or isn't drawing. Right-click and choose **Bolt Launcher (restart)**, then check `bolt.log`:
- `The profile appears to be in use by another Chromium process`: a stale lock. The image clears it automatically on every start, so restart the container.
- `exited with code 132` or `134` repeating: send the log in a bug report.
- Nothing logged at all: check that `LAUNCH_MODE` is `bolt`.

**"This site can't be reached" or `400 The plain HTTP request was sent to HTTPS port`**
The reverse proxy or tunnel is using HTTP against the HTTPS port. See [remote-access.md](remote-access.md).

**Page loads, but the stream never starts or keeps reconnecting**
WebSockets are blocked by the proxy. Enable WebSocket support (Cloudflare: *Network → WebSockets*; NPM: *Websockets Support*).

**The certificate warning on every visit**
This is expected with the built-in self-signed certificate. Use a reverse proxy or tunnel with a real certificate, or replace `<appdata>/ssl/cert.pem` and `<appdata>/ssl/cert.key` with your own certificate and key.

**Low FPS or lag**
See [performance.md](performance.md).

**Bolt login window doesn't open, or login fails**
- Make sure the clock is right (`TZ`).
- Restart Bolt from the right-click menu.
- As a fallback, use a [credentials file](../README.md#login-options).

**No sound**
Click anywhere in the page once. Browsers only start audio after you interact with the page. Also check the speaker toggle in the Selkies sidebar.

**Copy and paste**
Use the clipboard panel in the Selkies sidebar, or allow clipboard access when the browser asks.

## Reset everything

Stop the container and delete or rename `<appdata>`, for example `/mnt/user/appdata/runelite-web`. You'll need to log in to Bolt again, and RuneLite settings that aren't synced to your RuneLite account are lost.

To reset only Bolt and keep RuneLite settings, delete `<appdata>/.local/share/bolt-launcher`.
