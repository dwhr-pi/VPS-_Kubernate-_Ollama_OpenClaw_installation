# Die ersten 60 Minuten nach dem Clone

Ziel: Repository und Risiken verstehen, **nicht** innerhalb einer Stunde einen
produktionsreifen Cluster versprechen. Zeitfenster sind Orientierung.
Keine Installer, Modelle, Wallets, Cloud-Keys oder persoenlichen Hosts fuer Tests.

## Minute 0-10: Herkunft und Nachweisstand

Bereits lokal geklontes Repository verwenden. Vorhandenes Git und Python >=3.10
genuegen fuer die folgenden Metadatenpruefungen; nichts automatisch nachinstallieren.

```bash
git status --short
git log -1 --format=%H
git remote
```

`git remote` zeigt nur Remote-Namen. Ausgaben von `git remote -v` nicht
ungeprueft weitergeben: aeltere private Clone-URLs koennen
Zugangsdaten enthalten. Keine Tokens in diesen Guide, in Issues oder Screenshots kopieren.
Bei fremdem Checkout/veraendertem Testcode zuerst reviewen; Tests sind ausfuehrbarer Code.

Lies [Current Status](CURRENT_STATUS.md), [Audit](AUDIT_2026-10-23.md) und
[Security Baseline](SECURITY_BASELINE.md). Kein `curl | bash` oder Hard-Sync.

## Minute 10-25: Rein statisch pruefen

```bash
python3 -B scripts/quality/repository_audit.py
python3 -B scripts/quality/lifecycle_inventory.py --dry-run
```

Windows ohne WSL: vorhandenes `py -3 -B` statt `python3 -B`.
Die Programme lesen Repository-Dateien, starten keine installierten Tools und
schreiben nichts. Warnungen ernst nehmen; Exit 0 ist kein Sicherheitszertifikat.

## Minute 25-40: Vertrauenswuerdige Offline-Fixtures

Nach Review der Tests und nur in einer lokalen Wegwerf-/Entwicklungsumgebung:

```bash
python3 -B -m unittest discover -s tests -p 'test_repository_audit.py'
python3 -B -m unittest discover -s tests -p 'test_lifecycle_inventory.py'
```

Die Fixtures verwenden temporaere Verzeichnisse. Das Wort offline ist keine
Betriebssystem-Sandbox. Den kompletten Testlauf erst in einer geeigneten
Linux-Testumgebung ausfuehren; der letzte lokale Gesamtlauf war nicht gruen.
Nicht auf private Produktions-Workspaces umleiten.

## Minute 40-50: Genau einen Zielpfad waehlen

| Pfad | Reihenfolge fuer spaetere bewusste Installation |
|---|---|
| Minimal / Programmierung | Basiswerkzeuge, ein Coding-Agent, Ollama, OpenClaw; RAG und leichtes Monitoring bei Bedarf; Remotezugriff nur ueber geprueftes WireGuard |
| Low Resource | Eine kleine lokale Runtime, ein Modell, Queue-Parallelitaet 1; kein gleichzeitiger Medien-/Cluster-Rollout |
| Security First | P0-Risiken zuerst schliessen, Secrets extern, Cloud-Fallback aus, Rechte und Grenzen pruefen; kein zusaetzlicher ungepruefter Installer nur fuer ein Sicherheitslabel |
| Advanced | Optional K3s-GPU-Worker und Media-Studio erst nach Ressourcen-, Netzwerk- und Wiederherstellungstest |

Der Minimalpfad ist ein Zielbild, kein bereits vollstaendig gehaertetes Gesamtpaket.
Ollama, OpenClaw, Kubernetes-API, Home Assistant, ComfyUI und Datenbanken niemals
allein durch Portfreigabe oder einen SSH-Tunnel als sicher betrachten.

## Minute 50-60: Naechsten Test vorbereiten

Fuer Ubuntu 24.04 eine neue VM/Snapshot verwenden; fuer WSL2 eine separate
Testdistro mit begrenztem Windows-Speicherbudget, nicht die persoenliche Distro.
Vorbereiten: nichtprivilegierter Benutzer, freie Platte/RAM, Testdaten ohne Secrets,
keine eingebundenen Wallets, kein Docker-Socket und keine produktive Kubeconfig.

Manuelle spaetere Smoke-Abnahme: Installer einmal, Doctor, unveraenderter zweiter
Installationslauf, Testdaten anlegen, datenerhaltender Uninstall, Restore in ein
frisches Ziel. Ausfuehrung und Resultate protokollieren. Solange ein Legacy-Installer
diese Sicherheit nicht erfuellt, **nicht** auf dem echten Host ausprobieren.

Am Ende sollte klar sein: welcher Pfad, welche offenen Risiken, welcher naechste
kleine Test. Nicht: alle Tools installiert, CI gruen oder Produktionsfreigabe.
