# Changelog

All notable changes to this project are listed here. Versions follow [Semantic Versioning](https://semver.org).

## [Unreleased]

### Added
- RuneLite in the browser, streamed by linuxserver's Selkies base (Debian trixie).
- Jagex Account login via the bundled Bolt launcher (0.20.6).
- Direct RuneLite mode (`LAUNCH_MODE=runelite`) for legacy accounts or a `credentials.properties` login file.
- Right-click menu: restart Bolt, run RuneLite without Bolt, terminal, live logs.
- Stream defaults tuned for CPU-only servers (30 fps, unused webcam/mic/gamepad/apps panels hidden).
- Startup banner with component versions, plus a warning when no password is set.
- Healthcheck, log rotation, a custom icon, and an Unraid template.
- CI: smoke test on every build (including container recreate) before `latest` is updated, and a weekly rebuild.

### Fixed
- Bolt crash loop caused by Selkies' `LD_PRELOAD` shims.
- Bolt black window on hosts without a GPU (forced software rendering).
- Bolt refusing to start after a container update because of a stale Chromium profile lock.
