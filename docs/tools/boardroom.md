# Boardroom: Entscheidungsprofil

`Boardroom` ist ein eigenstaendiges Review-Profil fuer Architektur, Tool-Auswahl,
Kosten, Sicherheit und groessere Automatisierungen. Es ist kein zusaetzlicher
Dienst und keine automatische Deployment- oder Installationsfreigabe.

CFO, Operator, Vertriebler, Mentor und Skeptiker bewerten dieselbe Frage aus
verschiedenen Blickwinkeln. Der Chairman fasst die Argumente zusammen und
empfiehlt einen konkreten naechsten Schritt. Diese Rollen simulieren eine
Expertenrunde; sie sind kein Nachweis unabhaengiger Laufzeit-Agenten.

## Aufrufen

Im eingerichteten Agenten-Client mit verfuegbarem Boardroom-Profil beispielsweise:

> Boardroom rufen: Soll ich X oder Y fuer unser Setup nutzen?

Gib Optionen, Budget, technische Grenzen und das Entscheidungskriterium mit.
Die Empfehlung ist eine Entscheidungshilfe; Aenderungen bleiben separat
freizugeben. Keine Zugangsdaten oder privaten Schluessel in die Anfrage geben.

Fuer den Einstieg in ein vorhandenes Setup siehe
[Setup ohne Desktop ueber SSH](../HEADLESS_SETUP.md). Boardroom ist ein
Profil, kein eigenes Programm mit separatem VPS-Installer. Die Einrichtung
und der verfuegbare Agenten-Client bestimmen, wo du es aufrufst.

Die [vollstaendige Profilbeschreibung](../Profile/Boardroom.md) enthaelt
Rollen, Trigger, Ablauf und Ausgabeformat.

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py list
```

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
