# Social Avatar Content: Workflowvertrag

Status: planned/documentation-first, keine ausfuehrbare n8n-/OpenClaw-Datei.
[Einsteigeranleitung, Tools und Lizenzen](../../media_studio/SOCIAL_AVATAR_AUTOMATION.md).

## Eingabe

Job-ID, Business-Briefing, Sprache, fiktive/autorisiert freigegebene Persona,
Rechtebelege, Modell-/Workflowrevisionen und private lokale Medienreferenzen.
Keine Secrets, fremden URLs oder beliebigen Shellbefehle als Jobinhalt akzeptieren.

## Schritte und Freigaben

1. Ollama liefert nur Text-/Storyboardvorschlag; untrusted output validieren.
2. Mensch bestaetigt Fakten, Rechte, Stimme und Kennzeichnung.
3. Queue bestaetigt CPU/RAM/SSD/VRAM und Runtime-/Retry-/Cloudbudget.
4. Ein erlaubter TTS-/Avatar-/ComfyUI-Adapter erzeugt eine private Vorschau.
5. Mensch prueft Ton, Bild, Fakten, Untertitel und Plattformformat.
6. Separates Publikationsrecht erforderlich; diese Vorlage hat keinen Publisher.

OpenClaw: planen/pruefen statt beliebige Prozesse starten.
n8n: spaeter allowlist-basierte lokale Adapter, keine offenen Webhooks;
idempotente Job-ID und Provider-ID, maximal ein GPU-Auftrag.
Automaton braucht fuer diesen Workflow keine Wallet oder Runtime-Freigabe.

## Ausgabe

Privater Entwurf plus Metadatenbericht (Versionen, Status, Laufzeit, Kosten,
Pruefergebnis), keine Stimmreferenzen/Tokens/Transkripte in allgemeinen Logs.
Fehlerstatus blockiert weitere Ausfuehrung; kein automatischer Cloud-Fallback
oder unendliche Retry-Schleife. Freigaben/Budgetwerte sind hier nur spezifiziert,
noch nicht technisch implementiert.
