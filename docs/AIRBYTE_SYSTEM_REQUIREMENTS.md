# Airbyte Systemvoraussetzungen

Airbyte ist in diesem Setup ein schwergewichtiges Tool. `abctl local install`
startet lokal einen kind/Kubernetes-Cluster, installiert Airbyte per Helm und
zieht viele Container-Images. Es ist deshalb nicht mit leichten CLI-Tools wie
`ffmpeg`, `gh` oder `aider` vergleichbar.

## Mindestwerte

- RAM verfuegbar: mindestens 8192 MB, besser 12288 MB oder mehr.
- Linux-/WSL-Dateisystem: mindestens 32768 MB frei, besser 65536 MB oder mehr.
- Windows-Host-Laufwerk C: unter WSL2 mindestens 20480 MB frei, besser 51200 MB oder mehr.
- Docker muss nutzbar sein, weil `abctl` lokal kind/Kubernetes und Helm verwendet.

## Bewertung des Beispiel-Logs

Im Log wurden etwa 3332 MB verfuegbarer RAM erkannt. Damit ist eine lokale
Airbyte-Installation per `abctl` nicht realistisch stabil. Der Installer bricht
deshalb bewusst vor dem Helm-Deployment ab.

Die Speicherwerte im Beispiel sind dagegen grundsaetzlich ausreichend:

- Linux-/WSL-Speicher: 976329 MB frei.
- Windows C: 40293 MB frei.

Windows C: liegt damit ueber dem Mindestwert, aber unter der Komfort-Empfehlung
von 51200 MB. Der eigentliche Blocker ist der verfuegbare RAM.

## Typische Fehler bei zu wenig RAM

- `Readiness probe failed`
- `Liveness probe failed`
- `context deadline exceeded`
- TLS-/Helm-Timeouts
- sehr lange Wartezeiten bei `Starting Helm Chart installation`
- Pods starten, werden aber nicht dauerhaft healthy

## WSL2-Empfehlung

Fuer Airbyte unter WSL2 sollte Windows der Distribution mehr Speicher erlauben.
Beispiel fuer `%UserProfile%\.wslconfig`:

```ini
[wsl2]
memory=12GB
processors=4
swap=16GB
```

Danach Windows-seitig ausfuehren:

```powershell
wsl --shutdown
```

Anschliessend WSL neu starten und die Airbyte-Installation erneut versuchen.

## Vorpruefung im Setup

Der Airbyte-Installer prueft die Voraussetzungen direkt am Anfang:

- freien Linux-/WSL-Speicher
- freien Windows-C:-Speicher, wenn WSL2 erkannt wird
- verfuegbaren RAM
- Docker-Verfuegbarkeit

Wenn Mindestwerte unterschritten werden, wird vor Build-Abhaengigkeiten, `abctl`,
kind, Helm und Container-Image-Pulls abgebrochen. So sollen stundenlange
Fehllauefe und schwer verstaendliche Kubernetes-Probe-Fehler vermieden werden.
