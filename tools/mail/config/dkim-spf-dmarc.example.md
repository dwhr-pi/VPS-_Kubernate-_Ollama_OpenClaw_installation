# DKIM, SPF, DMARC und ARC

## SPF

SPF sagt, welche Server fuer deine Domain senden duerfen.

```text
example.tld. IN TXT "v=spf1 mx -all"
```

## DKIM

DKIM signiert ausgehende Mails. Der private Key bleibt auf dem Server oder in
einem Secret Store. Nur der Public Key kommt in DNS.

```text
default._domainkey.example.tld. IN TXT "v=DKIM1; k=rsa; p=DKIM_PUBLIC_KEY_PLACEHOLDER"
```

## DMARC

DMARC sagt empfangenden Servern, wie sie mit SPF/DKIM-Fehlern umgehen sollen.

Start:

```text
_dmarc.example.tld. IN TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.tld"
```

Strenger:

```text
_dmarc.example.tld. IN TXT "v=DMARC1; p=reject; rua=mailto:dmarc@example.tld; adkim=s; aspf=s"
```

## ARC

ARC ist relevant, wenn Mails ueber Weiterleitungen oder Mailinglisten laufen.
Stalwart kann ARC unterstuetzen; die konkrete Aktivierung muss anhand der
eingesetzten Version und Konfiguration geprueft werden.

## Pruefen

```bash
dig TXT example.tld
dig TXT _dmarc.example.tld
dig TXT default._domainkey.example.tld
```
