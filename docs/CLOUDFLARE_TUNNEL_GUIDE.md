# Cloudflare Tunnel Schritt für Schritt

Diese Anleitung hilft dir dabei, den für das Setup benötigten Tunnel und den zugehörigen Token bei [cloudflare.com](https://cloudflare.com) anzulegen.

## Ziel

Am Ende brauchst du den Tunnel-Token, den das Setup in `hybrid_setup.sh` oder `install_local_only.sh` abfragt.

## Voraussetzungen

- Ein Cloudflare-Konto
- Eine Domain, die in Cloudflare verwaltet wird
- Zugriff auf dein Linux-/WSL-System, auf dem `cloudflared` installiert wird

## Schritt 1: Securely access web apps

1. Melde dich im Cloudflare-Dashboard an.
2. Öffne den Bereich `Zero Trust`.
3. Wähle `Access`.
4. Öffne den Punkt `Applications`.
5. Klicke auf `Add an application`.
6. Wähle `Securely access web apps`.

## Schritt 2: Private web application

1. Wähle den Typ `Private web application`.
2. Klicke auf `Next`.

## Schritt 3: Define your application

1. Vergib einen Namen, z. B. `openclaw-homeassistant`.
2. Trage die Zielanwendung ein, z. B. `http://localhost:8123` für Home Assistant.
3. Falls gewünscht, lege weitere interne Ziele fest.
4. Klicke auf `Next`.

## Schritt 4: Select a public domain

1. Wähle deine Cloudflare-Domain aus.
2. Vergib einen öffentlichen Hostnamen, z. B. `ha.deinedomain.de`.
3. Prüfe, dass die Zielanwendung auf den lokalen Dienst zeigt, z. B. `localhost:8123`.
4. Klicke auf `Next`.

## Schritt 5: Add your first policy

1. Lege fest, wer auf die Anwendung zugreifen darf.
2. Für einen schnellen Start kannst du eine einfache Policy auf Basis deiner E-Mail-Adresse anlegen.
3. Speichere die Policy und klicke auf `Next`.

## Schritt 6: Assign a Tunnel

1. Wähle `Create a tunnel`, falls noch keiner existiert.
2. Vergib einen Namen, z. B. `alexa-skill-tunnel` oder `openclaw-tunnel`.
3. Klicke auf `Save tunnel`.

## Schritt 7: Deploy your Tunnel

1. Cloudflare zeigt dir jetzt die Tunnel-Installations- oder Verbindungsoptionen.
2. Für dieses Setup ist wichtig:
   - `cloudflared` muss lokal installiert sein
   - du brauchst den Tunnel-Token
3. Kopiere den angezeigten Token.
4. Diesen Token gibst du später im Setup ein, wenn `Cloudflare Tunnel Token:` abgefragt wird.

## Schritt 8: Review details

1. Prüfe noch einmal:
   - Anwendungstyp
   - öffentliche Domain
   - Ziel-URL
   - Richtlinie
   - zugewiesener Tunnel
2. Speichere die Konfiguration.

## Lokale Befehle auf Linux / WSL

Die Skripte geben am Ende die wichtigsten Schritte auch noch einmal aus. Typische Befehle sind:

```bash
sudo cloudflared tunnel login
sudo cloudflared tunnel create alexa-skill-tunnel
sudo cloudflared tunnel route dns alexa-skill-tunnel <deine-domain>
sudo cloudflared tunnel run --token <dein-token> alexa-skill-tunnel
```

## Was ist der richtige Token?

Verwende den Tunnel-Token aus dem Bereich `Deploy your Tunnel`. Genau diesen Wert erwartet das Setup.

## Typische Fehler

- Falsche Zieladresse:
  Wenn Home Assistant lokal auf `8123` läuft, muss das Ziel auch auf `http://localhost:8123` zeigen.
- Falsche Domain:
  Die Domain muss in deinem Cloudflare-Konto aktiv verwaltet werden.
- Kein Token:
  Ohne Tunnel-Token kann das Setup den Tunnel nicht sinnvoll vorbereiten.
