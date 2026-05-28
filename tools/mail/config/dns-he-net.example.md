# Hurricane Electric DNS fuer Stalwart Mail

Dieses Beispiel nutzt Platzhalter. Ersetze sie nur lokal:

- `example.tld`
- `mail.example.tld`
- `VPS_PUBLIC_IP`
- `VPS_PUBLIC_IPV6`

## A / AAAA

```text
mail.example.tld.  IN  A     VPS_PUBLIC_IP
mail.example.tld.  IN  AAAA  VPS_PUBLIC_IPV6
```

## MX

```text
example.tld.  IN  MX  10 mail.example.tld.
```

## SPF

```text
example.tld.  IN  TXT  "v=spf1 mx -all"
```

## DKIM

Der DKIM Public Key wird von Stalwart bzw. dem DKIM-Generator geliefert.
Der private Key darf nicht in Git gespeichert werden.

```text
default._domainkey.example.tld. IN TXT "v=DKIM1; k=rsa; p=DKIM_PUBLIC_KEY_PLACEHOLDER"
```

## DMARC

Start konservativ:

```text
_dmarc.example.tld. IN TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.tld; ruf=mailto:dmarc@example.tld; adkim=s; aspf=s"
```

Spaeter, wenn Zustellung stabil ist:

```text
_dmarc.example.tld. IN TXT "v=DMARC1; p=reject; rua=mailto:dmarc@example.tld; adkim=s; aspf=s"
```

## MTA-STS Hinweis

Optional:

```text
_mta-sts.example.tld. IN TXT "v=STSv1; id=20260528"
```

MTA-STS benoetigt zusaetzlich eine HTTPS-Datei unter:

```text
https://mta-sts.example.tld/.well-known/mta-sts.txt
```

## TLS-RPT Hinweis

```text
_smtp._tls.example.tld. IN TXT "v=TLSRPTv1; rua=mailto:tlsrpt@example.tld"
```

## PTR / rDNS

Wichtig: Der PTR/rDNS fuer `VPS_PUBLIC_IP` sollte auf `mail.example.tld`
zeigen. Das wird normalerweise beim VPS-/IP-Provider gesetzt, nicht bei HE DNS.
Ohne passenden PTR kann Mailzustellung deutlich schlechter werden.

## Test-Kommandos

```bash
dig MX example.tld
dig TXT example.tld
dig TXT _dmarc.example.tld
dig TXT default._domainkey.example.tld
dig A mail.example.tld
dig AAAA mail.example.tld
dig -x VPS_PUBLIC_IP
```
