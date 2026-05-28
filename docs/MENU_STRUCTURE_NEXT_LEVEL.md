# Menu Structure Next Level

Die Menues sollen weniger nach historischer Entstehung und mehr nach Betriebszweck gegliedert werden.

## Hauptkategorien

1. Basis-System
2. Lokales KI-System
3. Agenten & OpenClaw
4. RAG & Wissensdatenbanken
5. Automation & Workflows
6. Smart Home
7. Security & Netzwerk
8. DevOps & Kubernetes
9. Medien / Bild / Video / Musik
10. Android / Mobile
11. Wissenschaft / Forschung
12. Backup / Storage / Nextcloud
13. Monitoring / Diagnose
14. Entwickler-Tools

## Anzeige pro Eintrag

Jeder Menueeintrag soll kompakt zeigen:

```text
Name | Status | Bedarf | Zeit | Speicher | Ports | Risiko
```

Beispiel:

```text
Airbyte | experimental/vps | schwer | 04:00:00 | 32000 MB | 127.0.0.1:8003 | hoch
```

Fehlende Messwerte:

- Zeit: `--:--:--`
- Speicher: `--.- MB`

## Sortierung

- Standardansicht: `stable` und `beta` zuerst.
- `planned` und `documentation-first` nur in Preview/Backlog.
- `experimental`, `gpu-only`, `cluster` nur nach explizitem Filter.

## Sicherheitsanzeige

Bei Profilen mit Human-Approval-Gates sichtbar markieren:

- Security
- Smart Home
- Robotik
- Trading/Web3
- Browser-Agenten
- externe APIs
