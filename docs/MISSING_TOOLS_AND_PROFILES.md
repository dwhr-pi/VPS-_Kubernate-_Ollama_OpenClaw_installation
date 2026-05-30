# Missing Tools and Profiles

Dieses Dokument fasst die neuen planned Profile und Tool-Kandidaten zusammen.

## Neue planned Profile

Die neuen Profile wurden in `docs/Profile/`, `config/profiles.yml` und
`docs/PROFILE_TOOL_MAPPING.md` aufgenommen. Sie sind bewusst
documentation-first und starten keine schweren Toolchains automatisch.

## Neue Tool-Kandidaten

Schwerpunkte:

- Queue/Job-Systeme: RQ, Celery, Dramatiq, BullMQ, Temporal, Argo Workflows
- Security: Cosign, SOPS, age, Vaultwarden, Suricata, Wazuh
- Netzwerk: WireGuard, Headscale, Caddy, Traefik, HE-DDNS via ddclient
- Mail: Stalwart, Rspamd, Roundcube/SnappyMail, Mailpit
- Backup/Storage: Kopia, Supabase self-hosted, Duplicati
- Medien: InvokeAI, AUTOMATIC1111, Krita AI Diffusion

Alle Kandidaten sind `planned` oder `manual` und haben keine automatische
schwere Installation.
