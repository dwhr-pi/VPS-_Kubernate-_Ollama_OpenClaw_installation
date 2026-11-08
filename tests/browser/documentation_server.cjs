/* Browser fixtures use intercepted local responses, never start an installed service. */
'use strict';
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const assert = require('node:assert/strict');
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const root = path.resolve(__dirname, '../..');
const web = path.join(root, 'scripts/documentation_server/web');
const origin = 'http://127.0.0.1:8765';
const pages = [
  {path: 'readme.md', title: 'OpenClaw Handbuch', group: 'Projekt'},
  {path: 'docs/GPU.md', title: 'GPU und Betrieb', group: 'Betrieb'}
];
async function main() {
  const options = {headless: true};
  if (process.env.BROWSER_EXECUTABLE) options.executablePath = process.env.BROWSER_EXECUTABLE;
  const browser = await chromium.launch(options);
  try {
    const context = await browser.newContext({viewport: {width: 1440, height: 1000}});
    const page = await context.newPage();
    const errors = [], external = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.route('**/*', async route => {
      const url = new URL(route.request().url());
      if (url.origin !== origin) { external.push(url.origin); return route.abort(); }
      const staticFiles = {'/': 'index.html', '/static/app.js': 'app.js', '/static/style.css': 'style.css'};
      if (staticFiles[url.pathname]) {
        const name = staticFiles[url.pathname];
        return route.fulfill({body: fs.readFileSync(path.join(web, name)), contentType: name.endsWith('.js') ? 'text/javascript' : name.endsWith('.css') ? 'text/css' : 'text/html'});
      }
      let body;
      if (url.pathname === '/api/index') body = {pages, quick: pages};
      else if (url.pathname === '/api/search') body = [pages[1]];
      else if (url.pathname === '/api/page') {
        const title = url.searchParams.get('path') === 'docs/GPU.md' ? pages[1].title : pages[0].title;
        body = {html: '<h1 id="md-start">' + title + '</h1><p>Lokales Wissen, sicher erreichbar.</p><h2 id="md-check">Abnahme</h2><pre><code>python3 --version</code></pre><table><tr><th>Tool</th><th>Status</th></tr><tr><td>Ollama</td><td>Optional</td></tr></table>', toc: [{id: 'md-start', title, level: 1}, {id: 'md-check', title: 'Abnahme', level: 2}]};
      } else return route.fulfill({status: 404, body: 'Not found'});
      return route.fulfill({json: body});
    });
    await page.goto(origin);
    await page.locator('article h1').waitFor();
    assert.equal(await page.locator('#quick a').count(), 2);
    assert.equal(await page.locator('#toc a').count(), 2);
    await page.keyboard.press('/');
    assert.equal(await page.locator('#search').evaluate(element => element === document.activeElement), true);
    await page.locator('#search').fill('GPU');
    await page.locator('#results a').waitFor();
    await page.locator('#results a').click();
    await page.waitForFunction(() => document.querySelector('article h1').textContent === 'GPU und Betrieb');
    const output = fs.mkdtempSync(path.join(os.tmpdir(), 'openclaw-docs-browser-'));
    await page.screenshot({path: path.join(output, 'desktop.png'), fullPage: true});
    await page.setViewportSize({width: 390, height: 844});
    await page.locator('#menu').click();
    assert.equal(await page.locator('#navigation').isVisible(), true);
    await page.keyboard.press('Escape');
    assert.equal(await page.locator('#navigation').isVisible(), false);
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
    await page.screenshot({path: path.join(output, 'mobile.png'), fullPage: true});
    assert.deepEqual(errors, []);
    assert.deepEqual(external, []);
    console.log(JSON.stringify({passed: true, externalRequests: 0, screenshots: output}));
    await context.close();
  } finally { await browser.close(); }
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
