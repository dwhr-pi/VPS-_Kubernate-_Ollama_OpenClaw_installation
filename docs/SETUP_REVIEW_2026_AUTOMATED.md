# Setup Review 2026 Automated

## Gesamtbewertung

Das Ultimate KI Setup entwickelt sich zu einer modularen LLMOps-/Homelab-
Plattform. Die wichtigsten Staerken sind lokale KI, viele Profile, sichere
Dokumentation, GitHub-Quellenorientierung und zunehmend bessere Doctor-/Check-
Skripte.

## Bewertung nach Thema

| Thema | Nutzen | Risiko | Ressourcen | Reife | Zielgeraet |
|---|---|---|---|---|---|
| Minimal Local AI | hoch | niedrig | medium | stable | WSL2, Home Server |
| Oracle VPS Master | hoch | mittel | medium | beta | Oracle VPS |
| Hurricane Electric DNS/DDNS | hoch | mittel | light | planned | Oracle VPS |
| Raspberry Pi Wake-Waechter | hoch | mittel | light | planned | Raspberry Pi |
| Queue Manager | hoch | niedrig | light | planned | WSL2, VPS, GPU |
| Mailserver/Stalwart | hoch | hoch | medium | planned | Oracle VPS |
| GPU/Render Pipelines | hoch | hoch | gpu-heavy | planned | GPU Workstation |
| Supply Chain Security | hoch | niedrig | medium | beta | WSL2, VPS |

## Wichtigste Risiken

- Schwere Tools koennen WSL2/Docker-Speicher ueberlasten.
- Mailserver brauchen PTR/rDNS, DNS, DKIM, SPF, DMARC und Hardening.
- Cloudflare darf nicht implizit Pflichtpfad bleiben.
- Secrets duerfen nie in Git landen.
- Agenten duerfen nicht ohne Human Approval schreiben/senden.

## Prioritaeten

1. Startpfade fuer Einsteiger kurz halten.
2. Queue Manager als Schutz vor parallelen schweren Jobs nutzen.
3. HE/Oracle/WireGuard als Standardpfad weiter haerten.
4. Profile als planned sichtbar machen, nicht automatisch installieren.
5. Security-Checks in CI und lokal vereinheitlichen.
