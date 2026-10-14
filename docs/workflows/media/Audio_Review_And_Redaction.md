# Audio Review und Redaktion

Status: planned, nur Integrationsvertrag; kein laufender Python-/n8n-Workflow.
[Tools, Grenzen und Einsteigeranleitung](../../media_studio/AUDIO_DEEPFAKE_REVIEW.md).

## Eingabe

Autorisierte lokale Aufnahme, Job-ID, Zweck (Pruefung oder Redaktion),
Original-Hash und privater Ausgabeort. Transkripte sind untrusted input,
keine Skripte/Kommandos. Keine Tokens, personenbezogenen Inhalte oder
Stimmreferenzen in allgemeinen Logs.

## Freigabeschritte

1. Original erhalten, Herkunft/Hash inventarisieren, keine Authentizitaet behaupten.
2. Rechte und Bearbeitungszweck menschlich bestaetigen.
3. Ein Queue-Job mit gemessenen Speicher-/Zeitlimits; keine Cloud.
4. Analyse und Veraenderung strikt trennen: Diarisierung/AudioSeal nur optional.
5. Redaktion/Separation nur auf neuer Arbeitskopie, keine Re-Synthese zur Taeuschung.
6. Mensch prueft Ergebnis und Sprachreste; Freigabe vor jeder Weitergabe.

## Ausgabe und Abbruch

Bericht mit Werkzeug-/Gewichtsrevision, Zeiten, Transformationsliste und
Grenzen der Aussage; Original und bearbeitete Fassung klar unterscheiden.
Analysefehler, knappe SSD oder unklare Rechte stoppen den Job.
Kein automatischer Retry mit anderen externen Detektoren, keine
Wasserzeichenentfernung und kein Fake-/Echt-Urteil allein aus einem Score.
Adapter, technische Limits und private persistente Auditablage bleiben TODO.
