# OpenMontage-Projekt: Qwen-Einstiegsvorschlag

Eigene Vorlage fuer ein bewusst ausgewaehltes Medienprojekt, keine globale
Qwen-Konfiguration. Bestehende Projektregeln und Rechte nicht ersetzen.

- Lies vor Produktionsarbeit AGENT_GUIDE.md und PROJECT_CONTEXT.md sowie die
  passende Pipeline in pipeline_defs/. Nutze deren Stage-Anleitungen gezielt,
  nicht den gesamten Dateibaum als staendigen Prompt.
- Verwende fuer Python-Werkzeuge die vom Nutzer ausgewaehlte private
  OpenMontage-venv. Windows-/WSL-Pfade nicht stillschweigend austauschen.
- Beginne mit Konzept, Skript und Szenenplan. Kennzeichne fehlende Fakten,
  Quellen, Rechte, Assets, Modelle und Abhaengigkeiten; nichts erfinden.
- Keine Keys aus anderen Projekten lesen. Keine .env in Chat/Git uebernehmen.
- Vor Recherche, Downloads, Provideranfragen, Assets, Backlot-/Browserstart
  und Rendering den konkreten Datenfluss, Zielordner und Kosten offenlegen
  und die dafuer erforderliche Freigabe einholen. Keine automatischen Fallbacks.
- Die Freigabe eines Konzepts ist keine Freigabe einer kostenpflichtigen
  Assetgenerierung oder Publikation. Bei Aenderungen erneut abstimmen.
- Kein make setup, npx latest, globales Paketupgrade, Modelldownload oder
  Treiberumbau als spontane Fehlerkorrektur. Bei fehlenden Komponenten stoppen.
- Einen GPU-Job gleichzeitig planen; keine Endlosschleifen. Nach spaetestens
  drei erfolglosen Korrekturversuchen Fehlerbericht und offene Punkte liefern.
- Abschliessend manuelle Sicht-/Ton-/Rechtepruefung; kein automatischer Upload.

Diese Textregeln sind keine technische Sandbox oder garantierte Kostenbremse.
Client-Berechtigungen und Netz-/Dateizugriff muessen separat begrenzt werden.
