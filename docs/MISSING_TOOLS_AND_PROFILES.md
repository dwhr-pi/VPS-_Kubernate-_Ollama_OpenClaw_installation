# Missing Tools and Profiles

Dieses Dokument fasst die neuen planned Profile und Tool-Kandidaten zusammen.

**Abgleich 23.10.2026:** Die historische Kandidatenliste unten ist keine aktuelle
Liste fehlender Installer. Im [Grok-Review](tutorials/grok-repo-review-2026-10-23.md#d-aktualisierte-kandidatenliste)
sind die Kandidaten als `already present`, `planned`, `recommend add` oder
einsatzbezogen `reject` eingeordnet, mit Registry-IDs und konkreten Belegen.
Nachweisstand: [Current Status](CURRENT_STATUS.md).

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

Mehrere dieser Kandidaten besitzen inzwischen konkrete Installer oder andere
Integrationspfade. Ein Registry-/Dateinachweis belegt weder einen erfolgreichen
Build noch eine laufende Anwendung. Neue schwere Installationen bleiben opt-in;
bestehende Planned-Stubs duerfen nicht als Runtime-Nachweis gelten.
