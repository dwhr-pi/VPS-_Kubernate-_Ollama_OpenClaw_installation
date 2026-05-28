# Forks, Support und sichere Rueckfuehrung

Dieses Dokument beschreibt, wie Forks, eigene Branches und externe
Unterstuetzungsanfragen behandelt werden sollen, ohne das Original-Setup zu
gefaehrden.

## Grundsatz

Ein Fork ist technisch und bei Open-Source-Projekten grundsaetzlich moeglich.
Der Schutz dieses Setups ist deshalb kein klassischer Kopierschutz. Er ist ein
Support- und Integritaetsmodell:

- Das Original kann pruefen, ob es noch aus der erwarteten Quelle stammt.
- Automatische Selbstheilung via Update gilt nur fuer verifizierte Originale.
- Forks koennen weiterentwickelt werden, erhalten aber nicht automatisch den
  gleichen Supportstatus.
- Genehmigte Forks oder Sonderbranches koennen bewusst zugelassen werden, wenn
  sie signiert, dokumentiert und begrenzt unterstuetzt werden.

## Supportstatus

| Status | Bedeutung | Automatische Selbstheilung |
|---|---|---|
| `original` | `origin` zeigt auf das offizielle Repository und Commit/Manifest sind gueltig. | Ja |
| `approved_support_branch` | Branch liegt im Original-Repository und ist als Support-/Kundenbranch freigegeben. | Ja, begrenzt auf diesen Branch |
| `approved_fork` | Fork ist bekannt, hat `upstream` auf das Original und besitzt eine signierte Support-Freigabe. | Eingeschraenkt |
| `fork_with_original_upstream` | Fork kennt das Original, ist aber nicht freigegeben. | Nein, nur Diagnose |
| `unknown_or_modified` | Quelle, Branch oder Manifest sind nicht pruefbar. | Nein |

## Kann ein Fork mit eigener Branch als Original gelten?

Ja, aber nur kontrolliert. Ein Fork sollte nicht einfach durch seinen Namen als
Original behandelt werden. Sinnvoll ist ein dreistufiges Verfahren:

1. Der Fork muss `upstream` auf das Original-Repository setzen.
2. Der Fork oder Branch bekommt eine signierte Support-Freigabe.
3. Das Setup prueft diese Freigabe gegen den oeffentlichen Support-Schluessel.

Eine solche Freigabe kann z. B. diese Daten enthalten:

```yaml
support_profile:
  status: approved_fork
  fork: dwhr-pi/beispiel-fork
  upstream: dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation
  branch: support/kunde-oder-labor
  support_level: limited
  allowed_paths:
    - docs/
    - profiles/
    - config/
    - scripts/tools/
  denied_paths:
    - scripts/lib/repo_origin_check.sh
    - scripts/lib/mail_crypto.sh
    - security/
  expires: 2026-12-31
```

Diese Datei darf nicht fuer sich allein vertrauenswuerdig sein. Sie muss mit
GPG, minisign oder cosign signiert werden. Nur wenn Signatur, Ursprung, Branch
und Ablaufdatum stimmen, kann das Setup den Fork als genehmigte Variante
behandeln.

## Support fuer genehmigte Forks

Ein genehmigter Fork bekommt nicht automatisch denselben Support wie `main`.
Empfohlen sind drei Stufen:

- `diagnose-only`: Support liest Reports und gibt Hinweise, schreibt aber keine Patches.
- `limited-repair`: Support darf klar begrenzte Pfade reparieren, z. B. Doku, Profile, einzelne Installer.
- `managed-branch`: Support pflegt einen eigenen Branch im Original oder im Fork und stellt Updates per PR bereit.

Automatische Reparaturen sollten bei Forks standardmaessig deaktiviert bleiben,
bis der Nutzer die konkrete Aenderung bestaetigt.

## Wie bekommt ein Fork neue Dateien vom Support?

Es gibt mehrere sichere Wege. Die Reihenfolge ist bewusst konservativ:

1. Pull Request gegen den Fork

   Der Support erstellt einen Branch mit den Reparaturen und oeffnet einen PR
   in den Fork. Der Fork-Betreiber prueft und merged selbst.

2. Support-Branch im Original

   Der Support erstellt z. B. `support/ticket-1234-airbyte-fix` im Original.
   Der Fork-Betreiber zieht die Aenderungen gezielt:

   ```bash
   git remote add upstream https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git
   git fetch upstream
   git checkout eigene-branch
   git merge upstream/support/ticket-1234-airbyte-fix
   ```

3. Patch-Datei

   Der Support liefert eine signierte Patch-Datei:

   ```bash
   git apply support-ticket-1234.patch
   ```

   oder mit Commit-Metadaten:

   ```bash
   git am support-ticket-1234.patch
   ```

4. Pull Request vom Fork zurueck ins Original

   Wenn die Aenderung allgemein nuetzlich ist, soll der Fork einen PR gegen
   `main` des Originals oeffnen. Erst nach Review und Tests wird daraus ein
   offizieller Bestandteil.

## Wie schuetzen wir `main` vor ungewollter Richtungsveraenderung?

Fork-Aenderungen duerfen nicht ungeprueft in `main` uebernommen werden. Schutz
entsteht durch Prozess und technische Regeln:

- Branch Protection fuer `main`: keine direkten Pushes.
- Pull Requests statt Direkt-Merges.
- CODEOWNERS fuer kritische Bereiche wie `scripts/lib/`, `security/`, Installer
  und Update-Logik.
- CI-Pruefungen: ShellCheck, Secret-Scan, Registry-Sync, Dry-Run, Markdown.
- Signierte Commits oder signierte Releases fuer offizielle Updates.
- Kleine, nachvollziehbare PRs statt kompletter Fork-Dumps.
- Keine Uebernahme von echten Secrets, lokalen Pfaden, privaten Tokens oder
  unklaren Binaries.
- Feature Flags oder `planned`/`experimental` statt riskanter Default-Aktivierung.
- Klare Ablehnung, wenn Aenderungen das Projektziel verschieben.

## Wie koennen gute Fork-Aenderungen trotzdem einfliessen?

Der sichere Weg ist nicht, den Fork komplett zu akzeptieren, sondern die
Aenderungen in sinnvolle Einheiten zu zerlegen:

1. Fork mit Original vergleichen:

   ```bash
   git fetch origin
   git fetch upstream
   git diff upstream/main...HEAD --stat
   git diff upstream/main...HEAD
   ```

2. Aenderungen klassifizieren:

   - Doku
   - Profile
   - Tool-Registry
   - Installer
   - Security/Support-Logik
   - experimentelle Features

3. Pro Thema einen eigenen PR erstellen.
4. Tests und Diagnose laufen lassen.
5. Nur saubere, projektkonforme Teile mergen.
6. Nicht uebernommene Teile als `experimental`, `external fork` oder TODO
   dokumentieren.

## Was sollte nie automatisch passieren?

- Ein unbekannter Fork darf sich nicht selbst als Original deklarieren.
- Ein Fork darf keine neue Support-Signatur erzeugen und damit Originalstatus
  vortaeuschen.
- Vollstaendige Fork-Aenderungen duerfen nicht ohne Review in `main` gemerged
  werden.
- Selbstheilung darf bei unbekannten Quellen keine Dateien ueberschreiben.
- Supportberichte duerfen keine Secrets enthalten.

## Praktische Empfehlung

Fuer das Setup ist dieses Modell am robustesten:

- `main` bleibt die offizielle stabile Linie.
- `support/<name>` im Original ist fuer freigegebene Sonderfaelle erlaubt.
- Forks koennen Support anfragen, erhalten aber standardmaessig nur Diagnose.
- Reparaturen fuer Forks werden per PR, Support-Branch oder signiertem Patch
  geliefert.
- Allgemein nuetzliche Fork-Aenderungen kommen kontrolliert ueber PRs zurueck.
