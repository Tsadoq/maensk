import { chromium } from "patchright";

const capMs = 10_000;
const url = process.argv[2];
if (!url) {
  console.error("usage: node read-page.mjs <url>");
  process.exit(2);
}
if (!["http:", "https:"].includes(URL.parse(url)?.protocol)) {
  console.error(`not an http or https URL: ${url}`);
  process.exit(2);
}

const browser = await chromium.launch();
try {
  const page = await browser.newPage();
  const response = await page.goto(url, { waitUntil: "domcontentloaded" });
  if (!response) throw new Error(`no response from ${url}`);
  if (!response.ok()) throw new Error(`HTTP ${response.status()} from ${url}`);
  await page.waitForLoadState("networkidle", { timeout: capMs }).catch(() => {});
  process.stdout.write(`${await page.evaluate(() => document.body.innerText)}\n`);
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
} finally {
  await browser.close();
}
