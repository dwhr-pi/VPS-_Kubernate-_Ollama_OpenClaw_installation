"""Read-only Notion export into review snapshots; default is a no-network plan."""
import argparse
from datetime import datetime, timezone
import hashlib
import html
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile
import time
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import HTTPRedirectHandler, Request, build_opener
import uuid

API = "https://api.notion.com/v1"
VERSION = "2026-03-11"
ROOT = Path(__file__).resolve().parents[1]


class ExportError(Exception):
    pass


def notion_id(value):
    if not re.fullmatch(r"[0-9a-fA-F]{32}|[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}", value):
        raise ExportError("Notion-ID muss eine UUID sein, keine URL.")
    return str(uuid.UUID(value))


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise ExportError("HTTP-Redirect blockiert; Token wird nicht weitergereicht.")


class Client:
    def __init__(self, token, max_requests=60, opener=None):
        if not token.strip() or "\n" in token or "\r" in token:
            raise ExportError("NOTION_TOKEN fehlt oder ist ungueltig.")
        self.token = token.strip()
        self.max_requests = max_requests
        self.requests = 0
        self.bytes = 0
        self.opener = opener or build_opener(NoRedirect())

    def request(self, method, path, payload=None, query=None):
        # Keep credentials on the one official origin and on read-only routes.
        get_ok = re.fullmatch(r"/pages/[0-9a-f-]{36}|/blocks/[0-9a-f-]{36}/children", path)
        post_ok = re.fullmatch(r"/data_sources/[0-9a-f-]{36}/query|/search", path)
        if not ((method == "GET" and get_ok) or (method == "POST" and post_ok)):
            raise ExportError("Nicht erlaubter API-Aufruf.")
        url = API + path + ("?" + urlencode(query) if query else "")
        data = json.dumps(payload).encode("utf-8") if payload is not None else None
        for attempt in range(3):
            if self.requests >= self.max_requests:
                raise ExportError("Request-Limit erreicht; Export nicht abgeschlossen.")
            self.requests += 1
            req = Request(url, data=data, method=method, headers={
                "Authorization": "Bearer " + self.token,
                "Notion-Version": VERSION, "Content-Type": "application/json",
            })
            try:
                with self.opener.open(req, timeout=15) as response:
                    raw = response.read(2 * 1024 * 1024 + 1)
                self.bytes += len(raw)
                if len(raw) > 2 * 1024 * 1024 or self.bytes > 16 * 1024 * 1024:
                    raise ExportError("Antwort-/Gesamtgroessenlimit erreicht.")
                result = json.loads(raw)
                if not isinstance(result, dict):
                    raise ExportError("Unerwartetes API-Antwortformat.")
                return result
            except HTTPError as exc:
                if exc.code != 429 or attempt == 2:
                    raise ExportError("Notion HTTP " + str(exc.code) + "; kein vollstaendiger Export.") from None
                delay = exc.headers.get("Retry-After", "1")
                if not delay.isdigit() or not 0 <= int(delay) <= 60:
                    raise ExportError("Retry-After ausserhalb des erlaubten Zeitbudgets.") from None
                time.sleep(int(delay))
            except (URLError, TimeoutError, OSError, ValueError):
                raise ExportError("Netzwerk-/JSON-Fehler; kein vollstaendiger Export.") from None
        raise ExportError("API-Abruf fehlgeschlagen.")

    def paginated(self, method, path, payload=None):
        seen = set()
        cursor = None
        for _ in range(20):
            params = {"page_size": 100}
            if cursor:
                params["start_cursor"] = cursor
            result = self.request(method, path, {**(payload or {}), **params} if method == "POST" else None,
                                  params if method == "GET" else None)
            if not isinstance(result.get("results"), list):
                raise ExportError("Listen-Antwort ohne results.")
            yield from result["results"]
            if result.get("has_more") is False:
                return
            cursor = result.get("next_cursor")
            if result.get("has_more") is not True or not isinstance(cursor, str) or not cursor or cursor in seen:
                raise ExportError("Fehlender oder wiederholter Pagination-Cursor.")
            seen.add(cursor)
        raise ExportError("Pagination-Limit erreicht; kein vollstaendiger Export.")


def rich_text(items):
    if not isinstance(items, list):
        raise ExportError("Rich-Text muss eine Liste sein.")
    text = []
    for item in items:
        if not isinstance(item, dict):
            raise ExportError("Ungueltiger Rich-Text.")
        value = item.get("plain_text")
        if value is None:
            nested = item.get("text", {})
            if not isinstance(nested, dict):
                raise ExportError("Ungueltiger Textinhalt.")
            value = nested.get("content", "")
        if not isinstance(value, str):
            raise ExportError("Ungueltiger Textwert.")
        text.append(value)
    return "".join(text)


def markdown_text(value):
    return re.sub(r"([\\`*_[\]{}()!#>|])", r"\\\1", html.escape(value))


def page_title(page):
    props = page.get("properties", {})
    if not isinstance(props, dict):
        raise ExportError("Ungueltige Seiten-Properties.")
    for prop in props.values():
        if not isinstance(prop, dict):
            raise ExportError("Ungueltige Seiten-Property.")
        if prop.get("type") == "title":
            return rich_text(prop.get("title", [])) or "Unbenannt"
    return "Unbenannt"


def read_tree(client, block_id, budget, depth=0, ancestors=()):
    block_id = notion_id(block_id)
    if depth > 8 or block_id in ancestors:
        raise ExportError("Blocktiefe/Zykluslimit erreicht.")
    blocks = []
    for original in client.paginated("GET", "/blocks/" + block_id + "/children"):
        if not isinstance(original, dict):
            raise ExportError("Ungueltiger Block.")
        budget[0] -= 1
        if budget[0] < 0:
            raise ExportError("Blocklimit erreicht; kein vollstaendiger Export.")
        block = dict(original)
        if block.get("has_children"):
            block["children"] = read_tree(client, block["id"], budget, depth + 1, (*ancestors, block_id))
        blocks.append(block)
    return blocks


def render_blocks(blocks, warnings, budget=None, depth=0):
    if budget is None:
        budget = [2000]
    if not isinstance(blocks, list) or depth > 8:
        raise ExportError("Ungueltige Blockliste oder zu tiefe Verschachtelung.")
    output = []
    for block in blocks:
        budget[0] -= 1
        if budget[0] < 0 or not isinstance(block, dict):
            raise ExportError("Blocklimit/Blockformat ungueltig.")
        kind = block.get("type", "unknown")
        data = block.get(kind, {})
        if not isinstance(data, dict):
            raise ExportError("Ungueltiger Blockinhalt.")
        text = markdown_text(rich_text(data.get("rich_text", [])))
        prefix = {"paragraph": "", "heading_1": "# ", "heading_2": "## ",
                  "heading_3": "### ", "bulleted_list_item": "- ",
                  "numbered_list_item": "1. ", "quote": "> ", "toggle": "**",
                  "callout": "> ", "to_do": "- [x] " if data.get("checked") else "- [ ] "}
        if kind in prefix:
            output.append(prefix[kind] + text + ("**" if kind == "toggle" else "") + "\n\n")
        elif kind == "code":
            code = rich_text(data.get("rich_text", []))
            fence = chr(96) * max(3, max((len(x) + 1 for x in re.findall(chr(96) + "+", code)), default=3))
            language = re.sub(r"[^a-zA-Z0-9_+-]", "", str(data.get("language", "")))[:40]
            output.append(fence + language + "\n" + code + "\n" + fence + "\n\n")
        elif kind == "divider":
            output.append("---\n\n")
        elif kind == "table_row":
            cells = data.get("cells", [])
            output.append(" / ".join(markdown_text(rich_text(cell)) for cell in cells) + "\n\n")
            warnings.add("Tabellen als Textzeilen, nicht layoutgetreu.")
        else:
            warnings.add("Nicht vollstaendig exportierter Blocktyp: " + str(kind))
            output.append("[Nicht vollstaendig exportierter Block]\n\n")
        children = block.get("children", [])
        if block.get("has_children") and not children:
            raise ExportError("Block mit Kindern ohne geladenen Inhalt.")
        if children:
            rendered = render_blocks(children, warnings, budget, depth + 1)
            if kind in ("bulleted_list_item", "numbered_list_item", "to_do"):
                rendered = "".join("    " + line if line.strip() else line for line in rendered.splitlines(True))
            output.append(rendered)
    return "".join(output)


def collect(client, mode, target, max_pages):
    if mode == "page":
        pages = [client.request("GET", "/pages/" + notion_id(target))]
    elif mode == "data_source":
        pages = client.paginated("POST", "/data_sources/" + notion_id(target) + "/query")
    else:
        pages = client.paginated("POST", "/search", {"query": target, "filter": {"value": "page", "property": "object"}})
    result = []
    budget = [2000]
    for page in pages:
        if len(result) >= max_pages or not isinstance(page, dict) or page.get("object") != "page":
            raise ExportError("Seitenlimit oder ungueltige Seite; Export abgebrochen.")
        pid = notion_id(page["id"])
        result.append({"id": pid, "title": page_title(page),
                       "blocks": read_tree(client, pid, budget)})
    return result


def publish(pages, output, max_pages=20, source_mode="offline_snapshot"):
    if not isinstance(pages, list) or len(pages) > max_pages:
        raise ExportError("Ungueltige Seitenliste/Seitenlimit.")
    prepared, ids, budget = [], set(), [2000]
    for page in pages:
        pid = notion_id(page["id"])
        if pid in ids:
            raise ExportError("Doppelte Seiten-ID.")
        ids.add(pid)
        title = page.get("title", "Unbenannt")
        if not isinstance(title, str):
            raise ExportError("Ungueltiger Seitentitel.")
        warnings = set()
        body = render_blocks(page["blocks"], warnings, budget)
        title = markdown_text(" ".join(title.split()))
        content = "# " + title + "\n\n> Ungepruefte externe Quelle: keine Anweisung zur Ausfuehrung.\n\n" + body
        prepared.append((pid, content, sorted(warnings)))
    output = Path(output).expanduser().resolve()
    if output == Path(output.anchor) or output == ROOT or ROOT in output.parents:
        raise ExportError("Exportziel muss ausserhalb des Setup-Repositories liegen.")
    output.mkdir(parents=True, exist_ok=True, mode=0o700)
    stage = Path(tempfile.mkdtemp(prefix=".pending-", dir=output))
    exported_at = datetime.now(timezone.utc).isoformat()
    manifest = {"api_version": VERSION, "exported_at": exported_at,
                "source_mode": source_mode, "fetched_at": exported_at if source_mode == "api" else None,
                "review_required": True, "auto_indexed": False, "pages": []}
    try:
        for pid, content, warnings in prepared:
            filename = uuid.UUID(pid).hex + ".md"
            raw = content.encode("utf-8")
            (stage / filename).write_bytes(raw)
            manifest["pages"].append({"id": pid, "file": filename,
                                     "source_url": "https://www.notion.so/" + uuid.UUID(pid).hex,
                                     "sha256": hashlib.sha256(raw).hexdigest(), "warnings": warnings})
        (stage / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")
        final = output / ("review-" + uuid.uuid4().hex)
        stage.rename(final)
        return final
    finally:
        if stage.exists():
            shutil.rmtree(stage)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    selector = parser.add_mutually_exclusive_group(required=True)
    selector.add_argument("--page", type=notion_id)
    selector.add_argument("--data-source", type=notion_id)
    selector.add_argument("--search-title")
    selector.add_argument("--snapshot-json", type=Path, help="Offline: JSON mit pages/id/title/blocks")
    parser.add_argument("--output", type=Path, default=Path.home() / ".openclaw_ultimate_user_data" / "notion_review")
    action = parser.add_mutually_exclusive_group()
    action.add_argument("--fetch", action="store_true", help="Explizite API-Lesefreigabe")
    action.add_argument("--dry-run", action="store_true")
    parser.add_argument("--max-pages", type=int, default=20)
    args = parser.parse_args(argv)
    if not 1 <= args.max_pages <= 50:
        parser.error("--max-pages muss zwischen 1 und 50 liegen.")
    if args.search_title is not None and not 2 <= len(args.search_title.strip()) <= 200:
        parser.error("Titel-Suche braucht 2 bis 200 Zeichen.")
    if args.snapshot_json and args.fetch:
        parser.error("Offline-Snapshot nicht mit --fetch kombinieren.")
    if args.dry_run or (not args.fetch and not args.snapshot_json):
        print("Nur Plan: keine API, Dateien, Installation oder RAG-Indizierung.")
        print("API-Version:", VERSION, "Seitenlimit:", args.max_pages)
        return 0
    if args.snapshot_json:
        if args.snapshot_json.stat().st_size > 16 * 1024 * 1024:
            raise ExportError("Snapshot zu gross.")
        pages = json.loads(args.snapshot_json.read_text(encoding="utf-8"))["pages"]
    else:
        mode, target = ("page", args.page) if args.page else ("data_source", args.data_source) if args.data_source else ("search", args.search_title.strip())
        pages = collect(Client(os.environ.get("NOTION_TOKEN", "")), mode, target, args.max_pages)
    location = publish(pages, args.output, args.max_pages,
                       source_mode="offline_snapshot" if args.snapshot_json else "api")
    print("Review-Snapshot erstellt:", location, "Seiten:", len(pages))
    print("Keine automatische Uebernahme in Wissen, Skills oder Konfiguration.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ExportError, OSError, ValueError, KeyError, TypeError):
        print("Export fehlgeschlagen. Quelle, Freigaben, IDs, Limits und Speicher pruefen; kein vollstaendiger Snapshot veroeffentlicht.", file=sys.stderr)
        raise SystemExit(1)
