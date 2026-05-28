# Installation Decision Tree

## 1. System bestimmen

```text
WSL2/MiniPC?
  ja -> Low Resource Mode pruefen, keine schweren Kubernetes/GPU/Monorepo-Builds
  nein -> Ubuntu/VPS/Raspberry Pi/GPU pruefen
```

## 2. Ressourcen pruefen

- Unter 20 GB frei: nur Basis, Doctor, Cleanup, keine grossen Tools.
- Unter 8 GB RAM: keine Airbyte/Nextcloud/n8n/ComfyUI/Blender/GPU-Stacks.
- Kein Swap: vor grossen Builds Swap empfehlen.
- Windows C: unter 50 GB frei bei WSL2: warnen, grosse Installationen blockieren.

## 3. Profilklasse waehlen

- `stable`: darf im normalen Setup angeboten werden.
- `beta`: mit Hinweis und Logs.
- `planned`: nur Doku/Preview.
- `experimental`: explizite Bestaetigung.
- `gpu-only`, `vps-only`, `cluster`: nur bei passendem Systemprofil.

## 4. Remotezugriff

- Admin: Tailscale bevorzugt.
- Oeffentlich: Cloudflare Access/WAF/Rate-Limits.
- Keine offenen Admin-Ports als Default.

## 5. Nach Fehlern

- Batch stoppen.
- Log anzeigen anbieten.
- Diagnosebericht erzeugen.
- Wiederholen, ueberspringen oder zurueck ins Menue anbieten.
