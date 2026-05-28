# myNextCloud Server: Ubuntu/WSL2 Dev

## Ziel
Lokaler Entwicklungsaufbau ohne Docker-Pflicht.

## Vorbereitung

```bash
git clone https://github.com/dwhr-pi/myNextCloud-server.git
cd myNextCloud-server
git remote add upstream https://github.com/nextcloud/server.git || true
git fetch upstream --tags
cp .env.example .env
```

## WSL2-Hinweise

- Windows-C:-Speicher pruefen, bevor Datenordner oder Preview-/OCR-Jobs wachsen.
- Datenverzeichnis ausserhalb des Webroots.
- Dev-URL bevorzugt `http://127.0.0.1:<port>`.
- Keine oeffentliche Freigabe ohne Cloudflare Access oder Tailscale.

## Keine Secrets

`.env` niemals committen. Produktive DB-Passwoerter und Tokens nur lokal oder in Secret-Store halten.
