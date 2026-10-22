"""Validate editable video briefs offline; never submit jobs or open assets."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import sys


class RecipeError(ValueError):
    pass


def fields(value, required, optional=()):
    if not isinstance(value, dict) or set(required) - value.keys() or value.keys() - set(required) - set(optional):
        raise RecipeError("Objektfelder fehlen oder sind unbekannt.")


def text(value, limit=2000):
    if not isinstance(value, str) or not value.strip() or len(value) > limit or any(ord(c) < 32 and c not in "\n\t" for c in value):
        raise RecipeError("Text fehlt, ist zu lang oder enthaelt Steuerzeichen.")
    return value


def integer(value, low, high):
    if type(value) is not int or not low <= value <= high:
        raise RecipeError("Ganzzahl ausserhalb des Planungsbudgets.")
    return value


def asset(value):
    text(value, 200)
    path = PurePosixPath(value)
    if ("\\" in value or ":" in value or "?" in value or "#" in value
            or path.is_absolute() or ".." in path.parts
            or not value.startswith("assets/") or len(path.parts) < 2
            or not re.fullmatch(r"assets/[a-zA-Z0-9_./-]+", value)):
        raise RecipeError("Asset muss eine relative assets/-Referenz ohne URL sein.")
    return value


def build_plan(recipe):
    fields(recipe, ("version", "project", "workflow", "script", "seed", "canvas", "audio", "scenes", "rights"))
    integer(recipe["version"], 1, 1)
    if not re.fullmatch(r"[a-z0-9][a-z0-9-]{0,63}", text(recipe["project"], 64)):
        raise RecipeError("Projektname muss ein kurzer Slug sein.")
    if recipe["workflow"] not in ("ugc_ad", "photo_trend"):
        raise RecipeError("Unbekannter Workflow.")
    text(recipe["script"], 8000)
    integer(recipe["seed"], 0, 4294967295)
    canvas = recipe["canvas"]
    fields(canvas, ("width", "height", "fps"))
    for key in ("width", "height"):
        if integer(canvas[key], 256, 1280) % 16:
            raise RecipeError("Planungsaufloesung muss durch 16 teilbar sein.")
    integer(canvas["fps"], 8, 30)
    audio = recipe["audio"]
    fields(audio, ("mode",), ("source", "voice_ref"))
    if audio["mode"] == "existing":
        if set(audio) != {"mode", "source"}:
            raise RecipeError("Vorhandenes Audio braucht nur source.")
        asset(audio["source"])
    elif audio["mode"] == "tts":
        if set(audio) != {"mode", "voice_ref"}:
            raise RecipeError("TTS braucht nur eine freigegebene voice_ref.")
        text(audio["voice_ref"], 100)
    elif audio != {"mode": "none"}:
        raise RecipeError("Ungueltiger Audiomodus.")
    fields(recipe["rights"], ("assets_confirmed", "voice_confirmed", "commercial_use"))
    if any(type(value) is not bool for value in recipe["rights"].values()):
        raise RecipeError("Rechteangaben muessen boolesche Werte sein.")
    scenes = recipe["scenes"]
    if not isinstance(scenes, list) or not 1 <= len(scenes) <= 6:
        raise RecipeError("Ein Plan braucht 1 bis 6 Szenen.")
    ids, steps, total = set(), [], 0
    for scene in scenes:
        fields(scene, ("id", "kind", "source", "prompt", "seconds"))
        sid = text(scene["id"], 32)
        if not re.fullmatch(r"[a-z0-9-]+", sid) or sid in ids:
            raise RecipeError("Szenen-IDs muessen eindeutige Slugs sein.")
        ids.add(sid)
        if scene["kind"] not in ("static", "image_to_video", "talking_head"):
            raise RecipeError("Unbekannter Szenentyp.")
        asset(scene["source"])
        text(scene["prompt"])
        seconds = integer(scene["seconds"], 1, 8)
        total += seconds
        if scene["kind"] == "talking_head" and audio["mode"] == "none":
            raise RecipeError("Talking Head braucht eine geplante Audiospur.")
        steps.append({"scene": sid, "kind": scene["kind"],
                      "nominal_output_frames": seconds * canvas["fps"],
                      "adapter_implemented": False})
    if total > 30:
        raise RecipeError("Planungsbudget von 30 Sekunden ueberschritten.")
    canonical = json.dumps(recipe, sort_keys=True, ensure_ascii=True, separators=(",", ":"))
    blockers = ["Renderadapter, Asset-Dateien und Modelllizenzen noch nicht geprueft.",
                "RAM/VRAM, freier Zielspeicher und Windows-VHDX-Reserve vor Renderstart live pruefen.",
                "Storyboard/Audio-Vorschau und Freigabe fuer genau diese Revision fehlen."]
    if not recipe["rights"]["assets_confirmed"]:
        blockers.append("Bild-/Produkt-/Personenrechte nicht bestaetigt.")
    if audio["mode"] != "none" and not recipe["rights"]["voice_confirmed"]:
        blockers.append("Audio-/Stimmrechte nicht bestaetigt.")
    if recipe["rights"]["commercial_use"]:
        blockers.append("Kommerzielle Rechte fuer alle Modelle, Stimmen und Assets separat belegen.")
    return {"schema_version": 1, "status": "review_required", "render_ready": False,
            "recipe_sha256": hashlib.sha256(canonical.encode("ascii")).hexdigest(),
            "project": recipe["project"], "workflow": recipe["workflow"],
            "seconds": total, "scenes": steps, "blockers": blockers,
            "execution_policy": {"max_parallel_gpu_jobs": 1, "cloud_fallback": False},
            "note": "Nur Plan. Keine Queue, Assets, Modelle, Netzwerke oder Programme aufgerufen."}


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise RecipeError("Doppeltes JSON-Feld.")
        result[key] = value
    return result


def invalid_constant(value):
    raise RecipeError("Nicht endlicher JSON-Wert.")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("recipe", type=Path)
    args = parser.parse_args(argv)
    try:
        with args.recipe.open("rb") as source:
            raw = source.read(128 * 1024 + 1)
        if len(raw) > 128 * 1024:
            raise RecipeError("Rezept groesser als 128 KiB.")
        recipe = json.loads(raw, object_pairs_hook=unique_object, parse_constant=invalid_constant)
        plan = build_plan(recipe)
    except (OSError, ValueError, TypeError, RecursionError):
        print("Rezept ungueltig oder nicht lesbar; kein Job gestartet. Schema und Grenzen pruefen.", file=sys.stderr)
        return 2
    print(json.dumps(plan, ensure_ascii=True, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
