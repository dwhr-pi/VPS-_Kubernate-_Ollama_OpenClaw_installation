# Docker / containerd Konflikt

## Fehlerbild

```text
The following packages have unmet dependencies:
 containerd.io : Conflicts: containerd
E: Error, pkgProblemResolver::Resolve generated breaks
```

## Ursache

Dieser Fehler entsteht, wenn Ubuntu-Pakete (`docker.io`, `containerd`) und Docker.com-Pakete (`docker-ce`, `containerd.io`) gemischt werden. `docker.io` erwartet Ubuntus `containerd`, waehrend Docker.com `containerd.io` bereitstellt. Beide Varianten koennen kollidieren.

## Setup-Verhalten

Das Setup installiert Docker nicht mehr stumpf via `docker.io`, wenn das Docker.com-Repository vorhanden ist.

Neue Reihenfolge:

1. vorhandenes Docker verwenden
2. wenn Docker.com-Pakete verfuegbar sind: `docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
3. nur ohne Docker.com-Repo: Ubuntu-Fallback `docker.io`
4. wenn `containerd.io` vorhanden ist, aber `docker-ce` nicht installierbar ist: abbrechen und manuelle Reparatur verlangen

## Warum nicht automatisch reparieren?

Das Entfernen von `containerd`, `containerd.io`, `docker.io` oder `docker-ce` kann laufende Container und Daten betreffen. Deshalb soll das Setup solche Paketkonflikte nicht blind bereinigen.

## Diagnose

```bash
apt-cache policy docker-ce docker.io containerd containerd.io
dpkg -l | grep -E 'docker|containerd'
docker version
docker compose version
```

## Empfehlung

Auf Systemen mit Docker.com-Repository bevorzugt:

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Auf Minimal-/WSL-Systemen ohne Dockerbedarf sollte Docker nicht automatisch installiert werden.

