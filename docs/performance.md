# Performance tuning

Without a GPU, the CPU does two jobs at once:

1. **Rendering the game.** This is Java plus, if RuneLite's GPU plugin is on, Mesa's `llvmpipe` software 3D renderer.
2. **Encoding the video stream** to your browser.

Older server CPUs (Xeon E5 v2–v4, for example) have many cores but slow single-core speed, and both jobs are limited by single-core speed.

## Biggest wins, in order

1. **Turn off RuneLite's GPU plugin** if FPS is low. Go to *Configuration (wrench icon)* → search "GPU" → toggle it off. On CPU-only servers this usually makes the biggest difference. You lose the extended draw distance and some visual effects.
2. **Stream at a lower resolution.** By default the stream matches your browser window's size, and a 1440p or 4K window is expensive to encode. In the Selkies sidebar (the tab at the left edge), set a manual resolution such as **1280×720** or **1600×900**, or set it on the container:
   ```
   SELKIES_MANUAL_WIDTH=1600
   SELKIES_MANUAL_HEIGHT=900
   ```
3. **Frame rate.** The image defaults to **30 fps** (`SELKIES_FRAMERATE=30,8-60`). OSRS runs at 50 fps at most, and 30 feels smooth. Raise it to `60,8-60` only on fast CPUs.
4. **Encoder.** Try **JPEG** in the sidebar's video settings. It only sends the parts of the screen that changed, which suits OSRS's mostly still screen and can use less CPU than H.264. Compare it with **H.264** on your hardware.
5. **CPU pinning.** On Unraid, give the container 4 or more cores, ideally not shared with other heavy containers.

## Finding the bottleneck

While playing, open **Terminal** from the right-click menu and run `top`:

- **`java` is the top process:** the game rendering is the bottleneck. Focus on step 1.
- **`selkies` or `python3` is the top process:** video encoding is the bottleneck. Focus on steps 2–4.

## Hardware acceleration (optional)

If the server has an Intel iGPU or an AMD/NVIDIA GPU, pass it into the container to offload both jobs:

- Add the device `--device=/dev/dri:/dev/dri` (in Unraid: *Add another Path, Port, Variable → Device*).
- Selkies detects it automatically (`AUTO_GPU`). To choose a specific device, set `DRI_NODE=/dev/dri/renderD128` for encoding and `DRINODE=/dev/dri/renderD128` for rendering.
- Set `BOLT_GPU=true` so Bolt stops forcing software rendering.

NVIDIA cards also need the Nvidia Driver plugin on Unraid, and `--runtime=nvidia` with `NVIDIA_VISIBLE_DEVICES=all`.

## Latency

Input latency is mostly the network round trip. On your home network expect 5–20 ms. Through Cloudflare Tunnel expect 40–100 ms. OSRS processes the game in 600 ms ticks, so either is fine for normal play.
