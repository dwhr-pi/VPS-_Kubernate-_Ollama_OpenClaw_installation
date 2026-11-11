# LTX API von Lightricks

## Sinn und Zweck

Externe Videoerzeugung, getrennt von den [lokalen LTX-Quellen](../../tools/ltx-video.md).
Die [offizielle Dokumentation](https://docs.ltx.io/welcome) beschreibt
asynchrone Jobs: anlegen, Status abfragen, Ergebnis herunterladen.
Keine automatische Aktivierung durch das Setup.

## Pruefstand und Zugang

Gezielte Quellenpruefung: **11.11.2026**, kein Login oder API-/Inferenztest.
Laut [Authentifizierungsanleitung](https://docs.ltx.io/authentication) einen
eigenen Key in der Developer Console erzeugen. Upstream-Variable:
`LTXV_API_KEY`, Bearer-Authentifizierung. API-Host: `https://api.ltx.io`;
Version und Endpunkt vor Nutzung aus der aktuellen Dokumentation uebernehmen.
Dies ist kein nachgewiesener fertiger Setup-Connector.

## Kosten und Datenfreigabe

[Video-API-Preise](https://docs.ltx.io/pricing) richten sich nach Dauer,
Modell und Aufloesung. Nicht als Free Tier einstufen: Ein kostenlos erzeugter
Key bedeutet keine kostenlose Videoerzeugung. Trial, Promo, Credit-Ablauf,
Zahlungsmittel und konkrete Kontolimits sind hier nicht abschliessend geprueft.
Keine automatische Aufladung oder Cloud-Ausweichroute aktivieren.

Prompts und eingesandte Medien verlassen das eigene System. Datenschutz,
Aufbewahrung, Trainingsnutzung, Region und Medienrechte vor Freigabe pruefen;
keine ZDR-Zusage. Secrets nur im externen [ENV-Tresor](../../ENV_VAULT.md),
nicht in Git, Prompts, Logs oder Shell-Argumenten speichern.

Zurueck zu [API-Zugaengen](../README.md).
