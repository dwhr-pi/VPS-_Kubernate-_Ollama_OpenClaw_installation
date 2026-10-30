# Kubeseal: nativer GitHub-CLI-Build

Stand: 2026-10-27. Kubeseal verschluesselt Kubernetes-Secrets fuer den separat betriebenen
Sealed-Secrets-Controller. Der Installer baut ausschliesslich die CLI aus GitHub, ohne Docker,
Controller-Installation, Clusterzugriff, Schluesselimport oder Secret-Apply.

## Quelle und Buildvertrag

- Repository: [bitnami/sealed-secrets](https://github.com/bitnami/sealed-secrets).
- Gepinnter Commit: `c58a60f0bd5283d28c25ad068e7c9760634be470`.
- Paket: `./cmd/kubeseal`; Versionsprobe: `--version`.
- Go mindestens **1.27.3**, bestaetigt in der
  [go.mod am Pin](https://github.com/bitnami/sealed-secrets/blob/c58a60f0bd5283d28c25ad068e7c9760634be470/go.mod).
- Linux-/WSL- und Windows-Host-Speicherwachen bleiben aktiv; die Toolreserve betraegt derzeit 4096
  MiB. Ein Build kann trotzdem mehr Ressourcen benoetigen.

## Fehler: Nicht freigegebener privater Go-Buildvertrag

Das Installationslog vom 27.10.2026 zeigte einen internen Konsistenzfehler:
`config/docker_to_github.json` enthielt das Rezept, aber die separate Freigabeliste in
`scripts/tools/helpers/native_go.py` noch keinen Kubeseal- Eintrag. Deshalb wurde bereits vor der
Auswahl einer vorhandenen Go-Toolchain abgebrochen. Die Meldung bedeutete **nicht**, dass der Nutzer
eine Nachfrage abgelehnt hatte, und war kein Speicherplatzfehler.

Die Freigabeliste ist ergaenzt. Der gleiche Abgleich wurde fuer Traefik und OpenTelemetry
korrigiert. Ein Offline-Regressionstest verlangt fuer jedes versionierte Go-Rezept einen passenden
Vertrag; unbekannte oder abweichende Mindestversionen werden weiterhin vor Download und Build
abgelehnt.

## Erneut versuchen

Nach Uebernahme der korrigierten Dateien im Ubuntu-/WSL-Setup erneut `Kubeseal` auswaehlen. Eine
passende vorhandene Go-Version wird bevorzugt. Wenn sie fehlt, ist eine ausdrueckliche Zustimmung
fuer die private, SHA256-gepruefte offizielle Go-Basis erforderlich. Nicht-interaktiv gezielt:

```bash
# Bewusste Freigabe ausschliesslich fuer fehlende Build-Abhaengigkeiten.
# Aus dem Setup-Repository ohne sudo ausfuehren.
bash scripts/tools/kubeseal_install.sh --install-build-deps

# Installationsnachweis und lokale Artefakte pruefen, kein Clusterzugriff.
bash scripts/tools/kubeseal_status.sh
```

Die CLI selbst wird weiterhin aus dem gepinnten GitHub-Quellstand gebaut. Die optionale Go-Basis
kommt aus dem bereits hinterlegten offiziellen Go-Archiv; kein apt-Go und kein globaler
PATH-/System-Go-Wechsel. Beim Build gelten `GOTOOLCHAIN=local` und die gepruefte private Umgebung.
Ein Buildfehler erzeugt keinen Erfolgsnachweis. Private Basiswerkzeuge werden nicht pauschal
entfernt.

Hier wurden nur Offline-Tests mit gemockten Toolchains ausgefuehrt, kein echter Linux-Quellbuild.
Controller, Zertifikatsvertrauen, Recovery und tatsaechliche Secret-Verschluesselung brauchen eine
separate Abnahme. Siehe [Sealed Secrets und GitOps](../GITOPS_SMALL_VPS.md).
