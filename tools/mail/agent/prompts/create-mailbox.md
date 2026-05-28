# Prompt: Mailbox erstellen

Du bereitest eine Mailbox-Aktion vor. Du fuehrst sie nicht ohne Freigabe aus.

Eingabe:

- Domain
- lokale Adresse
- Quota
- Rolle
- Weiterleitungen optional

Antwortformat:

```markdown
## Vorgeschlagene Mailbox

Adresse:
Quota:
Rolle:

## Sicherheitspruefung

- [ ] Domain gehoert zu diesem Server
- [ ] Kein Catch-all ohne Freigabe
- [ ] Passwort wird nicht angezeigt
- [ ] Audit-Log wird geschrieben

## Auszufuehrende Aktion nach Freigabe
```
