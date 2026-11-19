# Playing away from home

Whoever can open this page can play your account. Put real authentication in front of it before it's reachable from the internet.

| Method | Effort | Notes |
|---|---|---|
| [Tailscale / WireGuard VPN](#vpn-tailscale-or-wireguard) | Low | Most secure. Nothing is exposed publicly. |
| [Cloudflare Tunnel + Access](#cloudflare-tunnel) | Medium | No open ports, and you can log in with email or SSO. Adds roughly 40–80 ms latency. |
| [Reverse proxy (SWAG, NPM, Traefik)](#reverse-proxy) | Medium | Use your own domain and certificate. Add an auth layer such as Authelia or Authentik. |

## VPN (Tailscale or WireGuard)

Install Tailscale on Unraid (*Apps → Tailscale*) and on your laptop or phone. Then browse to `https://<server-tailscale-ip>:38443`. No other changes are needed.

## Cloudflare Tunnel

The container serves HTTPS with a self-signed certificate on port `3001`, and plain HTTP on port `3000`. Use either one.

**Option 1: HTTPS to the container**

In *Zero Trust → Networks → Tunnels → your tunnel → Public Hostnames*:
- **Service:** `HTTPS` → `<unraid-ip>:38443`
- **Additional application settings → TLS → No TLS Verify:** On

**Option 2: HTTP to the container**

Map an extra host port to container port `3000` (the *WebUI (HTTP, reverse proxy only)* field in the Unraid template). Then use **Service:** `HTTP` → `<unraid-ip>:<that port>`. Cloudflare still provides HTTPS to your browser.

If you get a `400 The plain HTTP request was sent to HTTPS port` error, the service type is `HTTP` but it points at the HTTPS port.

**Protect it with Cloudflare Access.** Go to *Zero Trust → Access → Applications → Add → Self-hosted*, enter your hostname, and add a policy such as *Emails: you@example.com*. Keep the container's own `PASSWORD` set as well.

WebSockets must be enabled for the zone (*Network → WebSockets*). They're on by default.

## Reverse proxy

Point the proxy at `http://<container>:3000`, or at `https://<container>:3001` with certificate verification turned off. WebSocket upgrade headers are required.

**Nginx / SWAG**
```nginx
location / {
    proxy_pass http://runelite-web:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_read_timeout 3600s;
    proxy_buffering off;
}
```

**Traefik (Docker labels)**
```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.runelite.rule=Host(`runelite.example.com`)
  - traefik.http.routers.runelite.entrypoints=websecure
  - traefik.http.routers.runelite.tls.certresolver=letsencrypt
  - traefik.http.services.runelite.loadbalancer.server.port=3000
```

**Nginx Proxy Manager:** scheme `http`, forward port `3000`, and turn on **Websockets Support**.

To serve the app under a path such as `example.com/runelite/`, set `SUBFOLDER=/runelite/` on the container. It needs both slashes.
