"""Bounded, credential-free GET probe; HTTP challenges are failures, not content."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import re
import time
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[2]
AUTH_URLS = frozenset({
    "https://www.zotero.org/settings/keys",
    "https://console.mistral.ai/",
    "https://dash.cloudflare.com/",
    "https://platform.deepseek.com/",
})


def probe(url, *, opener=urlopen, sleep=time.sleep, attempts=2, timeout=10):
    """Return (classification, detail); only exact auth endpoints bypass the probe."""
    if url in AUTH_URLS:
        return "AUTH", "Login erforderlich; Inhalt nicht verifiziert"
    if not url.startswith(("https://", "http://")):
        return "FAIL", "Kein HTTP(S)-Link"
    for attempt in range(attempts):
        try:
            request = Request(url, headers={"User-Agent": "PR6-external-link-probe/1.0"})
            with opener(request, timeout=timeout) as response:
                status = response.status
        except HTTPError as error:
            status = error.code
        except (URLError, TimeoutError, OSError) as error:
            status = 0
            detail = type(error).__name__
        else:
            detail = ""
        if status in (200, 206):
            return "OK", str(status)
        if status not in (0, 202, 429, 500, 502, 503, 504) or attempt + 1 == attempts:
            return "FAIL", str(status) + (" " + detail if status == 0 else "")
        sleep(1)
    return "FAIL", "Keine Versuche konfiguriert"


def markdown_urls(text):
    """Probe explicit Markdown targets, not historical URLs inside inline code."""
    text = re.sub(r"^(`{3,}|~{3,}).*?^\1[^\n]*$", "", text, flags=re.M | re.S)
    text = re.sub(r"`+[^`\n]*`+", "", text)
    return sorted(set(re.findall(r"\]\((https?://[^\s)]+)\)", text)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("urls", nargs="*")
    parser.add_argument("--markdown", type=Path, help="Nur explizite Markdown-Links pruefen")
    args = parser.parse_args()
    urls = set(args.urls)
    if args.markdown:
        urls.update(markdown_urls(args.markdown.read_text(encoding="utf-8")))
    if not urls:
        parser.error("Mindestens eine URL oder --markdown erforderlich")
    with ThreadPoolExecutor(max_workers=4) as executor:
        results = list(executor.map(probe, sorted(urls)))
    for url, (state, detail) in zip(sorted(urls), results):
        print(json.dumps({"url": url, "state": state, "detail": detail}, ensure_ascii=True))
    return int(any(state == "FAIL" for state, _ in results))


if __name__ == "__main__":
    raise SystemExit(main())
