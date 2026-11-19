# Security

This container gives full control of your logged-in RuneScape account to anyone who can open its web page. Treat it like remote access to a PC.

- Always set `CUSTOM_USER` and `PASSWORD`.
- Don't publish the port straight to the internet. Use a VPN (Tailscale, WireGuard) or an authenticating reverse proxy such as Cloudflare Access or Authelia. See [docs/remote-access.md](docs/remote-access.md).
- `/config` holds your Bolt session tokens and RuneLite settings. Back it up and protect it like a password.

## Reporting a vulnerability

Please report security problems privately via **GitHub → Security → Report a vulnerability** on this repository, not in a public issue.
