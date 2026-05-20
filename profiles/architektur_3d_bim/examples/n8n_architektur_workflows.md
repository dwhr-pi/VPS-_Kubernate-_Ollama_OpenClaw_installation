# Beispiel: n8n Architektur Workflows

Sinnvolle Automationen:

- Webhook nimmt Renderauftrag entgegen
- IFC-Upload startet Analysebericht
- Materialliste wird als CSV/PDF abgelegt
- Backup-Workflow archiviert Projektordner
- Telegram/Email meldet abgeschlossene Renderjobs

Sicherheitsregel: n8n darf produktive IFC/CAD-Dateien standardmaessig nur kopieren und analysieren, nicht ueberschreiben.

