// Explicit manual start only; the installer checks syntax, never invokes --run.
'use strict';
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');
const { createRequire } = require('node:module');

function canonicalPath(candidate) {
  const tail = [];
  let existing = candidate;
  while (!fs.existsSync(existing)) {
    const parent = path.dirname(existing);
    if (parent === existing) throw new Error('Cannot resolve runtime data path.');
    tail.unshift(path.basename(existing));
    existing = parent;
  }
  return path.join(fs.realpathSync(existing), ...tail);
}

async function main() {
  if (process.argv.length !== 3 || process.argv[2] !== '--run') {
    console.log('Manual start: NOCODB_ACCEPT_INITIALIZATION=1 node run-native.cjs --run');
    console.log('First start may initialize/migrate the selected database. Back up existing data first.');
    return;
  }
  if (process.env.NOCODB_ACCEPT_INITIALIZATION !== '1') {
    throw new Error('Database initialization not approved; set NOCODB_ACCEPT_INITIALIZATION=1 after review.');
  }
  const host = process.env.NOCODB_BIND_HOST || '127.0.0.1';
  if (!['127.0.0.1', '::1'].includes(host)) {
    throw new Error('This starter only supports loopback. Use a secured reverse proxy/VPN.');
  }
  const portText = process.env.NOCODB_PORT || '8080';
  const port = Number(portText);
  if (!/^\d+$/.test(portText) || !Number.isInteger(port) || port < 1024 || port > 65535) {
    throw new Error('NOCODB_PORT must be an unprivileged TCP port.');
  }
  const data = process.env.NOCODB_DATA_DIR || path.resolve(__dirname, '..', 'data');
  if (!path.isAbsolute(data)) throw new Error('NOCODB_DATA_DIR must be absolute.');
  const resolvedData = canonicalPath(path.resolve(data));
  const build = fs.realpathSync(__dirname);
  if (resolvedData === build || resolvedData.startsWith(build + path.sep)) {
    throw new Error('Keep runtime data outside the build directory.');
  }
  const gui = path.join(__dirname, 'source/packages/nc-gui/.output/public');
  if (!fs.existsSync(path.join(gui, 'index.html'))) throw new Error('Built frontend missing.');
  fs.mkdirSync(resolvedData, { recursive: true, mode: 0o700 });
  process.chdir(resolvedData);
  process.env.NC_GUI_DIST_PATH = gui;
  process.env.NC_DISABLE_TELE = 'true';
  const localRequire = createRequire(path.join(__dirname, 'source/packages/nocodb/package.json'));
  const express = localRequire('express');
  const { Noco } = localRequire('./dist/bundle.js');
  const app = express();
  app.disable('x-powered-by');
  const server = http.createServer(app);
  app.use(await Noco.init({}, server, app));
  server.on('error', () => { console.error('NocoDB listener failed; no credentials printed.'); process.exitCode = 1; });
  server.listen(port, host, () => console.log(`NocoDB listening on loopback port ${port}.`));
}

main().catch(() => {
  console.error('NocoDB start refused/failed. Check prerequisites and protected runtime logs; no credentials printed.');
  process.exitCode = 1;
});
