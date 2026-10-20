"""Local opt-in Ollama measurements and offline timing analysis; no model pulls."""
import argparse
from datetime import datetime, timezone
import json
import math
import os
import re
import shutil
from pathlib import Path
import statistics
import sys
import tempfile
import time
from urllib import error, parse, request

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools/helpers"))
from find_skills import checked  # noqa: E402

MAX_BYTES = 2 * 1024**2
PROMPT = "Explain in plain German how a queue processes tasks one at a time. Do not use tools."


def number(data, key, integer=False):
    value = data.get(key)
    if (isinstance(value, bool) or not isinstance(value, (int, float)) or
            value > 1e18 or not math.isfinite(value) or value < 0 or (integer and not isinstance(value, int))):
        raise ValueError("Fehlendes/ungueltiges Timing-Feld: " + key)
    return value


def analyze(data):
    if not isinstance(data, dict) or data.get("done") is not True or data.get("error"):
        raise ValueError("Keine erfolgreiche abgeschlossene Ollama-Antwort.")
    result = {}
    for prefix, name in (("prompt_eval", "prefill"), ("eval", "decode")):
        count = number(data, prefix + "_count", integer=True)
        duration = number(data, prefix + "_duration")
        if count and not duration:
            raise ValueError("Tokenzahl ohne positive Dauer: " + prefix)
        result[name + "_tokens"] = count
        result[name + "_seconds"] = duration / 1e9
        rate = count * 1e9 / duration if duration else None
        if rate is not None and not math.isfinite(rate):
            raise ValueError("Timing ausserhalb des auswertbaren Bereichs.")
        result[name + "_tokens_per_second"] = rate
    result["server_total_seconds"] = number(data, "total_duration") / 1e9
    result["load_seconds"] = number(data, "load_duration") / 1e9
    result["ttft_seconds"] = None
    result["prompt_cache_may_apply"] = True
    return result


def base_url(value):
    url = parse.urlsplit(value)
    if (url.scheme != "http" or url.hostname not in ("127.0.0.1", "::1") or
            url.username or url.password or url.path not in ("", "/") or url.query or url.fragment):
        raise ValueError("Nur direkte HTTP-Loopback-URL ohne Credentials/Pfad/Query erlaubt.")
    _ = url.port  # Validate port syntax without any network access.
    return value.rstrip("/")


class NoRedirect(request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise ValueError("API-Redirect abgelehnt; nur der lokale Endpunkt ist erlaubt.")


def api(base, endpoint, payload=None, timeout=120):
    opener = request.build_opener(request.ProxyHandler({}), NoRedirect())
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    req = request.Request(base_url(base) + endpoint, data=body,
                          headers={"Content-Type": "application/json"})
    try:
        with opener.open(req, timeout=timeout) as response:
            raw = response.read(MAX_BYTES + 1)
    except error.HTTPError as exc:
        raise ValueError("Lokale API meldet HTTP " + str(exc.code) + "; kein Retry.") from None
    except (error.URLError, TimeoutError, OSError):
        raise ValueError("Lokale API nicht erreichbar/Timeout; kein Retry, Serverzustand manuell pruefen.") from None
    if len(raw) > MAX_BYTES:
        raise ValueError("API-Antwort zu gross; Inhalt wird nicht gespeichert.")
    return json.loads(raw)


def model_record(base, model, timeout):
    if not model or len(model) > 200 or "cloud" in model.lower() or any(c.isspace() for c in model):
        raise ValueError("Explizites lokales Modell inkl. Tag waehlen, keine Cloud-Modelle.")
    data = api(base, "/api/tags", timeout=timeout)
    if not isinstance(data, dict) or not isinstance(data.get("models"), list):
        raise ValueError("Unerwartete lokale Modellliste.")
    found = [item for item in data["models"] if isinstance(item, dict)
             and model in (item.get("name"), item.get("model"))]
    if len(found) != 1 or found[0].get("remote_host") or found[0].get("remote_model"):
        raise ValueError("Modell nicht eindeutig lokal vorhanden; kein Pull/Cloud-Fallback.")
    digest = found[0].get("digest")
    if not isinstance(digest, str) or not re.fullmatch(r"(?:sha256:)?[0-9a-fA-F]{64}", digest):
        raise ValueError("Modelldigest fehlt; Vergleich waere nicht eindeutig dokumentiert.")
    return {"name": model, "digest": digest}


def summarize(rows):
    result = {}
    for key in ("prefill_tokens_per_second", "decode_tokens_per_second", "wall_seconds", "load_seconds"):
        values = [row[key] for row in rows if row.get(key) is not None]
        if values:
            result[key] = {"median": statistics.median(values), "min": min(values), "max": max(values)}
    return result


def run(opts):
    base = base_url(opts.base_url)
    if not opts.execute:
        print(json.dumps({"action": "plan", "url": base, "model": opts.model,
                          "warmups": opts.warmups, "runs": opts.runs, "network_used": False}))
        return
    if not opts.confirm_local_model:
        raise ValueError("--confirm-local-model erforderlich: eigenes lokales Backend ohne Cloud-Routing bestaetigen.")
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Externen absoluten User-Workspace angeben.")
    output_dir = checked(raw / "benchmarks/ollama")
    output_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    lock = checked(output_dir / "operation.lock")
    try:
        lock.mkdir(mode=0o700)
    except FileExistsError:
        raise ValueError("Benchmark aktiv oder alter Lock vorhanden; zuerst pruefen.") from None
    fd = None
    path = None
    report = {"status": "running", "started_utc": datetime.now(timezone.utc).isoformat(),
              "endpoint": base, "model": opts.model, "samples": [], "hardware_not_probed": True,
              "settings": {"num_ctx": 2048, "num_predict": opts.num_predict, "temperature": 0,
                           "seed": 42, "keep_alive": "1m", "warmups": opts.warmups, "runs": opts.runs},
              "raw_prompts_or_responses_saved": False, "ttft_measured": False}
    try:
        fd, path = tempfile.mkstemp(prefix="ollama-bench-", suffix=".json", dir=output_dir)
        report["failure_stage"] = "report-disk-check"
        if shutil.disk_usage(output_dir).free < 16 * 1024**2:
            raise ValueError("Speicherplatzmangel: mindestens 16 MiB fuer Messberichte freimachen.")
        report["failure_stage"] = "local-model-lookup"
        report["model_identity"] = model_record(base, opts.model, opts.timeout)
        for index in range(opts.warmups + opts.runs):
            report["failure_stage"] = "generate-or-timing-validation"
            start = time.perf_counter()
            response = api(base, "/api/generate", {
                "model": opts.model, "prompt": PROMPT, "stream": False, "keep_alive": "1m",
                "options": {"num_ctx": 2048, "num_predict": opts.num_predict, "temperature": 0, "seed": 42},
            }, timeout=opts.timeout)
            row = analyze(response)
            row["wall_seconds"] = time.perf_counter() - start
            if index >= opts.warmups:
                report["samples"].append(row)
        report["summary"] = summarize(report["samples"])
        report["status"] = "success"
        del report["failure_stage"]
    except Exception:
        # No arbitrary server text, output tokens or secret-bearing errors in reports.
        report["status"] = "failed"
        report["error"] = "Messung fehlgeschlagen; keine Wiederholung. Lokalen Serverzustand pruefen."
        raise
    finally:
        try:
            if fd is not None:
                with os.fdopen(fd, "w", encoding="utf-8") as stream:
                    json.dump(report, stream, indent=2, allow_nan=False)
                print("Privater Benchmarkbericht:", path)
        finally:
            lock.rmdir()


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    offline = sub.add_parser("analyze", help="Gespeicherte Ollama-JSON-Antwort offline auswerten")
    offline.add_argument("file", type=Path)
    bench = sub.add_parser("ollama", help="Standard: nur Plan; Lasttest explizit freigeben")
    bench.add_argument("--base-url", default="http://127.0.0.1:11434")
    bench.add_argument("--model", required=True)
    bench.add_argument("--execute", action="store_true")
    bench.add_argument("--confirm-local-model", action="store_true")
    bench.add_argument("--runs", type=int, choices=range(1, 11), default=3)
    bench.add_argument("--warmups", type=int, choices=(0, 1), default=1)
    bench.add_argument("--num-predict", type=int, choices=range(1, 513), default=128)
    bench.add_argument("--timeout", type=int, choices=range(1, 301), default=120)
    opts = parser.parse_args(argv)
    if opts.command == "analyze":
        with opts.file.open("rb") as stream:
            raw = stream.read(MAX_BYTES + 1)
        if len(raw) > MAX_BYTES:
            raise ValueError("Eingabedatei zu gross.")
        print(json.dumps(analyze(json.loads(raw)), indent=2, allow_nan=False))
    else:
        run(opts)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError) as exc:
        print("Benchmark-Fehler:", str(exc), file=sys.stderr)
        sys.exit(1)
