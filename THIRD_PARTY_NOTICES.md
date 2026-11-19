# Third-party software

The MIT license in [LICENSE](LICENSE) covers this repository's own files: the Dockerfile, scripts, templates and docs. The published container image also bundles the third-party software below, each under its own license.

| Component | License | Source |
|---|---|---|
| [Bolt launcher](https://codeberg.org/Adamcake/Bolt) 0.20.6 (unmodified binary) | AGPL-3.0 | https://codeberg.org/Adamcake/Bolt/src/tag/0.20.6 |
| [Chromium Embedded Framework](https://bitbucket.org/chromiumembedded/cef), shipped with Bolt | BSD-3-Clause | https://bitbucket.org/chromiumembedded/cef |
| [RuneLite launcher](https://github.com/runelite/launcher) | BSD-2-Clause | https://github.com/runelite/launcher |
| [Eclipse Temurin](https://adoptium.net) JDK 17 | GPL-2.0 with Classpath Exception | https://github.com/adoptium |
| [linuxserver/baseimage-selkies](https://github.com/linuxserver/docker-baseimage-selkies) | GPL-3.0 | https://github.com/linuxserver/docker-baseimage-selkies |
| [Selkies](https://github.com/selkies-project/selkies) | MPL-2.0 | https://github.com/selkies-project/selkies |
| Debian packages | Various | https://sources.debian.org |

RuneLite downloads its game client from runelite.net when it starts. The client is not included in the image.

## Trademarks

Old School RuneScape, RuneScape and Jagex are trademarks of Jagex Ltd. RuneLite is a trademark of its respective owners. This project is not affiliated with or endorsed by Jagex, RuneLite or Bolt. Using third-party clients is subject to Jagex's rules. RuneLite is an approved client.
