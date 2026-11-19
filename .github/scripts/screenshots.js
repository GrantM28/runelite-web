// Drives the web UI like a user would and saves README screenshots.
// Usage: node screenshots.js <outdir>
const { execSync } = require('child_process');
const { chromium } = require(process.env.PW);
const out = process.argv[2] || '.';
const sleep = ms => new Promise(r => setTimeout(r, ms));
const xshot = name => execSync(`docker exec -u abc -e DISPLAY=:1 rl import -window root /tmp/${name}.png && docker cp rl:/tmp/${name}.png ${out}/${name}.png`);

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ ignoreHTTPSErrors: true, viewport: { width: 1280, height: 800 } });
  await page.goto('https://localhost:3001/');
  await sleep(20000);
  await page.screenshot({ path: `${out}/browser-bolt-disclaimer.png` });

  // Dismiss Bolt's disclaimer by clicking through the stream (also exercises input).
  await page.mouse.click(640, 463);
  await sleep(4000);
  await page.screenshot({ path: `${out}/bolt.png` });
  xshot('bolt-x11');

  // Start RuneLite directly and wait for the client to download and reach the login screen.
  execSync('docker exec -d -u abc -e HOME=/config -e DISPLAY=:1 rl /usr/local/bin/runelite-direct');
  for (let i = 0; i < 24; i++) {
    await sleep(10000);
    const wins = execSync('docker exec -u abc -e DISPLAY=:1 rl xwininfo -root -tree').toString();
    if (/"RuneLite"/.test(wins) && i > 6) break;
  }
  await sleep(15000);
  await page.screenshot({ path: `${out}/runelite.png` });
  xshot('runelite-x11');
  await browser.close();
})().catch(e => { console.error(e); process.exit(1); });
