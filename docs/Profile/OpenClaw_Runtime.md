# OpenClaw

Status: **planned**, Rollen-/Policy-Vorlage, keine fertige Runtime.

## Aufgabe

Separat freizugebende Agent Runtime, keine automatische Ausfuehrung.

## Installieren

```bash
bash scripts/profiles/OpenClaw_Runtime_install.sh --dry-run
bash scripts/profiles/OpenClaw_Runtime_install.sh
bash scripts/profiles/OpenClaw_Runtime_check.sh
bash scripts/profiles/OpenClaw_Runtime_uninstall.sh
```

Installieren kopiert nur diese eigene Profilvorlage aus dem GitHub-Setup- Checkout nach
`$OPENCLAW_USER_DATA_DIR/agent_profiles/OpenClaw_Runtime/` (Standard:
`~/.openclaw_ultimate_user_data`). Keine CLI, Modelle, Container, Cloud-Anmeldung, Dienste oder
produktiven Schreibaktionen. Deinstallation deaktiviert nur die Registrierung, Vorlagen und
Nutzdaten bleiben erhalten.

## Tools und Ressourcen

`openclaw` Ressourcenklasse: **medium**. Vorlagen brauchen nur 16 MiB freie Disk;
Runtime-/RAM-/VRAM-Anforderungen folgen dem separat gewaehlten Tool/Modell. WSL2/MiniPC/VPS/RPi fuer
Vorlagen geeignet; lokale Inferenz/GPU-Builds gesondert pruefen. Kubernetes ist ein optionaler
Ausbau, kein Standard fuer jeden Agenten.

## Grenzen

Lokaler Default; kein automatischer Cloud-Fallback. Read-only-first, ein Job, drei Korrekturrunden
und 900 Sekunden als **deklarative Zielpolicy**, nicht als implementierter Executor oder Sandbox.
Schreiben, Shell, Netzwerk, Git-Push und Deployments brauchen eigene Freigaben. Keine Secrets,
Wallets, privaten Personalakten oder produktiven Credentials teilen. Ein Prompt ersetzt keine
Betriebssystem-Zugriffskontrolle.

[Architektur und GitHub-Quellpfade](../agents/coding-agent-profiles.md).
