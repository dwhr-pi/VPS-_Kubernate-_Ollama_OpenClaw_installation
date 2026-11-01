# P1 bis P3: Umsetzung und Abnahmegrenzen

Stand: 01.11.2026. Lokale Fortsetzung nach P0-A, keine Produktionsfreigabe.
Keine Installation, kein WSL-Zugriff, keine Cloud-/Cluster-Aenderung und kein Lesen
privater Arbeitsdaten. Die bestehenden Architekturgrenzen bleiben verbindlich:
HE/Oracle -> WireGuard -> Pi/WoL -> Heim-GPU/K3s. APIs bleiben privat.

## Nachweisbare Aenderungen

| Phase | Baustein | Implementiert | Noch nicht nachgewiesen |
| --- | --- | --- | --- |
| P1 | Registry-Bereitschaft | Separater `readiness`-Vertrag, beleggebundene Hochstufung | Echte Tool-/Plattform-Abnahmen |
| P1 | Generierte Inventare | Deterministische Tool-, Profil- und Port-Matrizen; CI-Driftcheck | Komplett registry-generiertes interaktives Menue |
| P1 | Offline-Einstieg | `setup_ultimate.sh --dry-run` vor Workspace-Initialisierung | Frische Ubuntu-/Debian-/ARM-Hosts |
| P1 | Fehlerweitergabe | Registry-/Profil-Wrapper verschlucken fehlgeschlagene Pruefungen nicht mehr | Vollstaendige Lifecycle-Abdeckung aller Tools |
| P2 | Restore | Begrenztes TAR-Datei-Integritaetsverfahren mit synthetischer Wiederherstellung | Restic/Velero/PVC und anwendungskonsistente Datenbank-Restores |
| P2 | Pi/GPU-Pruefkette | Plan, bewusster Wake, SSH, NodeReady/GPU, Ollama-Version mit Zeitbudget | Echte Hardware, freier VRAM, Modell-/Inferenzbereitschaft |
| P2 | Gateway-Policy | Optionaler lokaler Text-/Token-/Ratenvertrag, Offline-SDK-Ersatztests | Gepinnte LiteLLM-Laufzeit, verteilte Budgets, echte Inferenz |
| P3 | Risikoabfrage | Einmalige interaktive Freigabe fuer ausgewaehlte Installerpfade | Vollstaendige Sandbox und Abdeckung aller direkten Legacy-Aufrufe |
| P3 | Einstieg | Kurze README, Alttext erhalten, Navigation verlinkt | Online-Pruefung aller historischen Fragment-Links |

## P1: Registry und Bereitschaft

Kanonische neue Metadatenansichten:
[Tools](generated/TOOL_MATRIX.md), [Profile](generated/PROFILE_MATRIX.md),
[Ports](generated/PORT_MATRIX.md). Bestehende redaktionelle Kataloge bleiben erhalten;
ihre Aussagen ersetzen keine Laufzeitbelege. Die 802 bisher gemeldeten
Metadatenhinweise werden nicht durch fingierte Doctors oder Updates beseitigt.

```bash
python3 -B scripts/quality/registry_catalog.py --check
python3 -B scripts/quality/registry_catalog.py --write
bash setup_ultimate.sh --dry-run
```

`--check` schreibt nichts; `--write` aktualisiert ausschliesslich die drei festen
Dateien unter `docs/generated`. Der Dry-Run fuehrt keine Tool-/Dienstabfragen aus.

`status` bleibt der bisherige Reifegrad, kein Laufzeittest. Neues Feld `readiness`:
`unknown` (auch bei fehlendem Feld), `planned`, `source-ready`, `runtime-verified`,
`deprecated`. Fuer die beiden belegpflichtigen Zustaende sind ein voller
`source_commit` und `readiness_evidence` unter `docs/evidence/` erforderlich.
Der JSON-Beleg muss `id`, `source_commit`, `scope` (`source` oder `runtime`),
`result: passed`, `platform`, `tested_at` mit Zeitzone, `log` und `log_sha256`
enthalten. Der Log-Inhalt wird gegen den Hash geprueft; Links/Junctions und
Pfadausbrueche werden abgewiesen. **Dies ist ein reviewbarer manueller Beleg,
keine kryptographisch authentisierte Attestation.** Kein bestehendes Tool wurde
automatisch hochgestuft. Fixture-Erfolge sind keine Runtime-Belege.

## P2: Wiederherstellung und GPU-Bereitschaft

```bash
bash scripts/operations/restore_test.sh --plan
bash scripts/operations/restore_test.sh --fixture --apply
```

Plan endet absichtlich mit Code 3 (nicht ausgefuehrt). Die Fixture erzeugt nur
synthetische Dateien im temporaeren Verzeichnis, archiviert und restauriert sie
mit Groessen-/SHA256-Pruefung. Ausgabe `runtime_verified: false` bleibt korrekt.
Ein blosses Verzeichnislisting gilt nicht mehr als erfolgreicher Restore.

Fuer einen bewusst ausgefuehrten Datei-Restore auf nativem Linux, nicht als root:

```bash
python3 -I -B scripts/operations/restore_drill.py \
  --archive /srv/recovery-input/state.tar \
  --manifest /srv/recovery-input/manifest.json \
  --destination /srv/recovery-private/new-attempt \
  --allow-sensitive-data --apply
```

Dies ist **kein direktes Importformat fuer bestehende `.tar.age`-Backups**.
Archive muessen vorher separat autorisiert entschluesselt werden; private Dateien
werden hier weder gesucht noch automatisch konvertiert. Ein vertrauenswuerdiges
Manifest mit `schema: 1` und `files` als Abbildung Dateiname -> `size`, `sha256`
ist erforderlich. Nur unkomprimierte TAR-Dateien, regulaere Dateien, keine Links,
maximal 10.000 Dateien/2 GiB. Neues Ziel, privater elterlicher Ordner mit 0700,
kein Ueberschreiben. Ein Teilbestand bleibt nach Fehlern zur privaten Pruefung
erhalten. Datei-Integritaet beweist keine DB-Konsistenz und keinen PVC-Restore.

Plan ohne Netzwerkverkehr:

```bash
bash scripts/home-watcher/wake-gpu-server.sh --health-gate \
  --pi-ip 10.7.0.2 --worker-ip 10.7.0.3 --control-ip 10.7.0.1 \
  --mac 02:00:00:00:00:03 --node home-gpu --ssh-user llmops
```

Die Adressen sind nur Beispiele; vor Apply eigene VPN-/Heimnetzadressen und
Ueberschneidungen mit Pod-/Service-CIDRs pruefen.
Apply verlangt zusaetzlich `--apply --confirm-wake --identity-file ABS
--known-hosts ABS`. Beide Dateien muessen privat, benutzereigen, unverlinkt und
ausserhalb des Repos sein. Kein automatisches Hostkey-Vertrauen, kein SSH-Agent,
kein Root-Login. Wake wird auf dem Pi ausgefuehrt. Erforderlich sind auf dem Pi
bereits `wakeonlan` und auf dem Control-Host `kubectl`
mit explizitem Leserecht fuer den Ziel-Node; diese Rechte werden nicht eingerichtet.
Die private Worker-Adresse muss ueber das eigene VPN erreichbar sein. NodeReady plus eine
advertisierte/allocatable NVIDIA-GPU und `/api/version` sind notwendig, aber
beweisen weder freien VRAM noch ein geladenes Modell. Kein Modell wird angefragt.

**Breaking Change:** `shutdown-idle-gpu-server.sh --apply` ist gesperrt. Der alte
Pfad konnte ohne implementierte Idle-Pruefung herunterfahren. Erst nach einem
nachgewiesenen Job-/Lease-/Idle-Vertrag darf er wieder freigegeben werden.

## P2: Optionaler Gateway-Vertrag

`services/inference-gateway/config.local-policy.yaml` ist eine ausdrueckliche
Alternative, nicht die Standardkonfiguration. Das Dockerfile legt sie und
`local_policy.py` unter `/etc/llmops` ab. Beim gesondert freigegebenen Start den
Konfigurationspfad bewusst waehlen und `/etc/llmops` zum bestehenden `PYTHONPATH`
hinzufuegen; es gibt hier keinen automatischen Start. Der Standard-Imagepfad
ueberschreibt den bisherigen Python-Suchpfad nicht.
Bestehende Compose-Routen bleiben unveraendert und sind damit **nicht** durch
diese neue Policy abgesichert.

Erforderlich: `LITELLM_OLLAMA_MODEL=ollama/<bereits-vorhandenes-modell>`,
`OLLAMA_API_BASE` auf einen erlaubten privaten/Loopback-Ollama-Endpunkt mit Port
11434 und ein externer `LITELLM_MASTER_KEY`. Kein Modellname oder Key wird erzeugt.
Die Policy akzeptiert nur `local-default`/`ollama-default`, Textnachrichten,
hoechstens 64 Nachrichten/64 KiB serialisierte Nachrichtendaten, maximal 1024
Ausgabetokens (Standard 256), keine clientseitigen Provider-Ueberschreibungen.
Bekannte Schluesselmuster werden abgewiesen, aber dies ist **kein allgemeiner
PII-/Prompt-Injection-Filter**. Keine Prompts/Keys werden protokolliert.

Pro 60-Sekunden-Fenster: acht Anfragen je authentisierter Schluesselidentitaet,
32 insgesamt. Nur Hashes der Identitaeten werden im Prozess gehalten. Grenzen
gelten **nur fuer einen Prozess**, resetten beim Neustart und ersetzen keine
verteilten Quoten, Eurobudgets oder Netzwerkisolation. Keine Cloudroute vorhanden.
Die Hook-Schnittstelle ist in der [offiziellen LiteLLM-Dokumentation](https://docs.litellm.ai/docs/proxy/call_hooks)
beschrieben; echte Kompatibilitaet des gepinnten Images bleibt separat abzunehmen.

## P3: Risiken und Navigation

Ausgewaehlte Voice-/Avatar-/Personaldatenpfade verlangen eine einmalige exakte
`ACK:`-Eingabe; Enter und nichtinteraktive Aufrufe verweigern die Aktion.
Die Erkennung ist eine begrenzte Namens-/Installer-Zuordnung, keine vollstaendige
transitive Abhaengigkeitsanalyse. Finanz-/Trading-/Web3-Pfade sind im Menue
gesperrt, weil noch kein technisch nachgewiesener Paper-Modus existiert.
Direkte Legacy-Skripte und externe Programme sind dadurch nicht sandboxed.
Kein dauerhaftes Zustimmungsflag und kein ENV-Bypass wurden eingefuehrt.

Die [Kurz-README](../readme.md) verweist auf den
[vollstaendigen Alttext](legacy/README_FULL_2026_11_01.md). Bisherige
Ueberschriftentexte bleiben in gleicher Reihenfolge sichtbar. Historische
Installationskommandos sind nicht zur erneuten ungeprueften Ausfuehrung bestimmt.
Verzeichnisnamen werden nicht blind vereinheitlicht: `Profil`, `Profile` und
`profiles` haben bestehende Verbraucher; eine Migration benoetigt Alias-/Pfadtests.

## Abnahme, Breaking Changes und Rollback

Neue Tests: `test_registry_catalog.py`, `test_platform_operations.py`,
`test_local_gateway_policy.py`, `test_platform_navigation.py`. Sie verwenden
synthetische Daten, SSH-/SDK-Ersatzobjekte und keine Provider-Inferenz.
Registry-Driftcheck wird in `offline-regression.yml` verbindlich ausgefuehrt.
Geaenderte Shell-Dateien benoetigen weiterhin Syntax-, ShellCheck- und shfmt-Pruefung.

Lokaler Nachweis auf Windows am 01.11.2026 (ueberlappende Testauswahlen,
die Zahlen deshalb nicht addieren):

- Alle vier neuen Testmodule zuletzt: 25 Tests, alle bestanden.
- Breitere Auswahl einschliesslich Registry, Dokumentationsnavigation, Governance,
  Toolchain, Lifecycle, RAG und Secure Core: 120 Tests, 119 bestanden, einer
  plattformbedingt uebersprungen.
- Zusaetzliche Auswahl einschliesslich Legacy-Uninstall, Install-Rollback,
  Medienstatus und ComfyUI-Abhaengigkeit: 82 Tests, 80 bestanden, zwei wegen
  fehlender nativer Symlink-Rechte uebersprungen.
- Vollstaendiger statischer Repositorycheck: 400 Tools, 250 Profile, 45 Ports,
  266 Python-Dateien, 176 Python-Testmodule, 1192 Markdown-Dateien;
  0 Fehler, 802 unverdeckte Metadatenhinweise.
- Registry-Driftcheck ohne Abweichung; Bash-Syntax, ShellCheck und shfmt fuer die
  sechs geaenderten Shell-Dateien erfolgreich. Markdownlint fuer neue/geaenderte
  Einstiegs-, Archiv-, Matrix- und Umsetzungsdokumentation erfolgreich.
- Die gesamte Python-Discovery wurde gestartet, unter Windows wegen der langen
  Laufzeit abgebrochen und ist **nicht** als erfolgreich abgenommen. Keine
  GitHub-CI-, Linux-Host-, Hardware-, Container- oder Inferenz-Abnahme behauptet.
- YAML-/Ansible-/Image-Laufzeitvalidierung wurde in diesem Teilsatz nicht ausgefuehrt.

Neben dem gesperrten Idle-Shutdown sind nun fehlgeschlagene Registry-Wrapper
sichtbar und manche Risikopfade zustimmungspflichtig. Keine echten Nutzdaten
werden migriert. Rollback: ausgewaehlte Codeaenderungen nach Review rueckgaengig
machen; keinen privaten Workspace loeschen. Einen ungesicherten Shutdown-Pfad
nicht als vermeintliche Fehlerbehebung reaktivieren.

## Priorisierte Restliste und naechste PR

1. P0-B/C/D: gepinnte/verifizierte Downloads, getrennte Service-Starts,
   atomische Secrets und vollstaendig nachgewiesener Managed-Uninstall-Vertrag.
2. P1: Top-20-Lifecycle vervollstaendigen, Ubuntu 24.04/Debian/ARM in Wegwerf-Hosts
   abnehmen, Ansible-/OpenTofu-/GitOps-Pfade gegen bestehende Implementierung pruefen.
3. P2: echte anwendungskonsistente Restic-/Velero-/PVC-Restore-Abnahme; danach
   externen Notifier testen, NetworkPolicy-Negativtests und DCGM opt-in abnehmen.
4. P2: gepinntes LiteLLM-Image mit realem Hook laden, verteiltes Budgetmodell,
   technische Agentensandbox und vollstaendige Supply-Chain-Artefakte nachweisen.
5. P3: restliche Risikopfade und Directory-Kompatibilitaet vollstaendig abdecken.

Naechster separater PR-Entwurf: **P0-B: verifizierte Artefakte vor Ausfuehrung**.
Abnahmekriterien: falsche Hashes/Signaturen und Branch-Rennen stoppen vor
Ausfuehrung; Offline-Fall schlaegt geschlossen fehl; kein automatischer Dienststart;
bestehende Nutzdaten bleiben erhalten. Keine Ausweichversion oder erfundene Pins.
P1-P3 sind mit diesem Teilsatz nicht insgesamt produktionsabgenommen.
