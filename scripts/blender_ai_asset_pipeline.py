#!/usr/bin/env python3
"""
Minimal Blender headless helper for the AI 3D Studio.

Usage:
  blender --background --python scripts/blender_ai_asset_pipeline.py -- \
    --input asset.glb --output exports/asset.glb --format GLB
"""

import argparse
import pathlib
import sys

try:
    import bpy
except ImportError as exc:  # pragma: no cover - only available inside Blender
    raise SystemExit("Dieses Skript muss mit Blender Python gestartet werden.") from exc


def parse_args() -> argparse.Namespace:
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1 :]
    else:
        argv = []

    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--format", default="GLB", choices=["GLB", "OBJ", "FBX", "STL", "BLEND"])
    parser.add_argument("--decimate", type=float, default=0.0, help="Optional decimate ratio, e.g. 0.5")
    return parser.parse_args(argv)


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def import_asset(path: pathlib.Path) -> None:
    suffix = path.suffix.lower()
    if suffix in {".glb", ".gltf"}:
        bpy.ops.import_scene.gltf(filepath=str(path))
    elif suffix == ".obj":
        bpy.ops.wm.obj_import(filepath=str(path))
    elif suffix == ".fbx":
        bpy.ops.import_scene.fbx(filepath=str(path))
    elif suffix == ".stl":
        bpy.ops.wm.stl_import(filepath=str(path))
    elif suffix == ".blend":
        bpy.ops.wm.open_mainfile(filepath=str(path))
    else:
        raise SystemExit(f"Nicht unterstuetztes Eingabeformat: {suffix}")


def cleanup_meshes(decimate_ratio: float) -> None:
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        bpy.ops.object.shade_smooth_by_angle(angle=0.523599)
        if decimate_ratio > 0:
            modifier = obj.modifiers.new("AI3D_Decimate", "DECIMATE")
            modifier.ratio = decimate_ratio
            bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.select_set(False)


def export_asset(path: pathlib.Path, fmt: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if fmt == "GLB":
        bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB")
    elif fmt == "OBJ":
        bpy.ops.wm.obj_export(filepath=str(path))
    elif fmt == "FBX":
        bpy.ops.export_scene.fbx(filepath=str(path))
    elif fmt == "STL":
        bpy.ops.wm.stl_export(filepath=str(path))
    elif fmt == "BLEND":
        bpy.ops.wm.save_as_mainfile(filepath=str(path))


def main() -> None:
    args = parse_args()
    src = pathlib.Path(args.input).expanduser().resolve()
    dst = pathlib.Path(args.output).expanduser().resolve()
    clear_scene()
    import_asset(src)
    cleanup_meshes(args.decimate)
    export_asset(dst, args.format)
    print(f"Export abgeschlossen: {dst}")


if __name__ == "__main__":
    main()

