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

## VPS ueber SSH bedienen

Fuer den Einstieg in ein vorhandenes Setup siehe
[Setup ohne Desktop ueber SSH](../HEADLESS_SETUP.md). Boardroom ist ein
Profil, kein eigenes Programm mit separatem VPS-Installer. Die Einrichtung
und der verfuegbare Agenten-Client bestimmen, wo du es aufrufst.

Die [vollstaendige Profilbeschreibung](../Profile/Boardroom.md) enthaelt
Rollen, Trigger, Ablauf und Ausgabeformat.
