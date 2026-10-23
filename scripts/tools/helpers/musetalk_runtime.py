"""MuseTalk's pinned upstream CUDA environment, without weights or inference."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile

import gap_tools as source

SPEC = source.SPECS["musetalk"]
REVISION = "2026-10-23-upstream-cu118-python310"
RESERVE_MB = 20480
MMCV_INDEX = "https://download.openmmlab.com/mmcv/dist/cu118/torch2.0/index.html"
PROBE = """
import torch, torchvision, torchaudio, diffusers, transformers, cv2, soundfile
import accelerate, tensorflow, librosa, gradio, mmdet, mmpose, mmengine
from mmcv.ops import nms
assert torch.__version__.split('+')[0] == '2.0.1'
assert torch.cuda.is_available(), 'CUDA nicht verfuegbar'
assert torch.cuda.get_device_capability()[0] < 10, 'Blackwell braucht anderen Torch/MMCV-Stack'
x = torch.ones(1, device='cuda')
assert x.add(1).item() == 2
boxes = torch.tensor([[0., 0., 1., 1.]], device='cuda')
nms(boxes, torch.ones(1, device='cuda'), 0.5)
print('Paketimporte und Torch/MMCV-CUDA-Operation bestanden; keine Modelle/Inferenz.')
"""


def locations():
    base, checkout, marker = source.paths("musetalk")
    return base, checkout, marker, source.checked(base / "python-runtime"), source.checked(base / "runtime-ready.json")


def preflight(base):
    if platform.system() != "Linux" or platform.machine().lower() not in ("x86_64", "amd64"):
        raise ValueError("MuseTalk-Runtime: derzeit Ubuntu/WSL x86_64; Windows nativ nicht abgenommen. --source-only bleibt verfuegbar.")
    source.reserve(base, dict(reserve_mb=RESERVE_MB))
    for name in ("uv", "ffmpeg", "ffprobe", "nvidia-smi"):
        source.executable(name)
    result = subprocess.run([source.executable("nvidia-smi"), "--query-gpu=compute_cap", "--format=csv,noheader"],
                            capture_output=True, text=True, check=True, timeout=30)
    capabilities = [float(line.strip()) for line in result.stdout.splitlines() if line.strip()]
    if not capabilities or any(value >= 10 for value in capabilities):
        raise ValueError("MuseTalk-Upstream-Pin: PyTorch 2.0.1/cu118 ist nicht fuer RTX 50/Blackwell freigegeben. Kein Download; separaten Torch>=2.7/CUDA12.8/MMCV-Kompatibilitaetspfad pruefen. Kein automatischer CPU-Fallback.")


def environment(dependencies):
    env = source.build_env(dependencies)
    env.update(HF_HUB_OFFLINE="1", TRANSFORMERS_OFFLINE="1", HF_HUB_DISABLE_TELEMETRY="1",
               IMAGEIO_NO_INTERNET="1", UV_NO_CACHE="1", UV_NO_CONFIG="1", UV_PYTHON_DOWNLOADS="never",
               PIP_DISABLE_PIP_VERSION_CHECK="1", PYTHONNOUSERSITE="1", GRADIO_ANALYTICS_ENABLED="False")
    return env


def python310(dependencies, env):
    candidate = os.environ.get("MUSETALK_PYTHON_BIN") or shutil.which("python3.10")
    if not candidate:
        policy = os.environ.get("MUSETALK_INSTALL_PYTHON", "ask")
        if policy not in ("0", "1", "ask"):
            raise ValueError("MUSETALK_INSTALL_PYTHON: nur ask, 0 oder 1.")
        accepted = policy == "1"
        print("Python 3.10 fehlt. Optional: private GitHub-python-build-standalone-Laufzeit via vorhandenem uv; kein System-Python-Umbau.")
        if policy == "ask" and sys.stdin.isatty():
            print("Privates Python 3.10 herunterladen? [(j)a/(N)ein]", flush=True)
            try:
                accepted = input().strip().lower() in ("j", "ja", "y", "yes")
            except EOFError:
                accepted = False
        if not accepted:
            raise ValueError("Python-Download nicht freigegeben; MUSETALK_PYTHON_BIN oder MUSETALK_INSTALL_PYTHON=1 bewusst setzen.")
        env["UV_PYTHON_INSTALL_DIR"] = str(dependencies / ".python")
        download_env = dict(env, UV_PYTHON_DOWNLOADS="manual")
        source.run([source.executable("uv"), "python", "install", "3.10", "--no-bin", "--no-config"], dependencies, download_env)
        candidate = source.run([source.executable("uv"), "python", "find", "3.10", "--managed-python",
                                "--no-python-downloads", "--no-config"], dependencies, env)
        if not Path(candidate).resolve().is_relative_to((dependencies / ".python").resolve()):
            raise ValueError("Privater Python-Pfad verlaesst den Tool-Workspace.")
    source.run([candidate, "-I", "-c", "import sys,ssl; assert sys.version_info[:2] == (3,10), 'Python 3.10 erforderlich'"], dependencies, env)
    return candidate


def build(checkout, dependencies):
    env = environment(dependencies)
    uv = source.executable("uv")
    python = python310(dependencies, env)
    venv = dependencies / ".venv"
    source.run([uv, "venv", "--python", python, "--no-python-downloads", str(venv)], dependencies, env)
    vpython = venv / "bin/python"
    install = [uv, "pip", "install", "--python", str(vpython), "--no-cache", "--index-url", "https://pypi.org/simple"]
    constraints = dependencies / "constraints.txt"
    constraints.write_text("torch==2.0.1\ntorchvision==0.15.2\ntorchaudio==2.0.2\nnumpy==1.23.5\nmmcv==2.0.1\nmmengine==0.10.7\nmmdet==3.1.0\nmmpose==1.1.0\nsetuptools==69.5.1\n", encoding="ascii")
    source.run(install + ["setuptools==69.5.1", "wheel==0.45.1"], dependencies, env)
    source.run([uv, "pip", "install", "--python", str(vpython), "--no-cache", "--index-url",
                "https://download.pytorch.org/whl/cu118", "torch==2.0.1", "torchvision==0.15.2", "torchaudio==2.0.2"], dependencies, env)
    # Refuse an unplanned multi-hour MMCV source build if the matching wheel is absent.
    source.run(install + ["--constraint", str(constraints), "--only-binary", "mmcv", "--find-links", MMCV_INDEX,
                          "-r", str(checkout / "requirements.txt"), "mmcv==2.0.1", "mmengine==0.10.7",
                          "mmdet==3.1.0", "mmpose==1.1.0"], dependencies, env)
    source.run([uv, "pip", "check", "--python", str(vpython)], dependencies, env)
    source.run([vpython, "-I", "-c", PROBE], dependencies, env)
    lock = source.run([uv, "pip", "freeze", "--python", str(vpython)], dependencies, env)
    (dependencies / "resolved-requirements.txt").write_text(lock + "\n", encoding="utf-8")
    for name in (".build-home", ".build-temp"):
        shutil.rmtree(source.checked(dependencies / name))


def validate(checkout, source_marker, dependencies, marker, full=False):
    source.validate(checkout, source_marker, SPEC)
    record = json.loads(marker.read_text(encoding="utf-8"))
    if record.get("revision") != REVISION or record.get("pin") != SPEC["pin"] or record.get("scope") != "dependencies":
        raise ValueError("MuseTalk-Runtime-Nachweis passt nicht; nichts ueberschreiben/loeschen.")
    files = record.get("files")
    if not isinstance(files, dict) or not files or not (dependencies / ".venv/bin/python").is_file():
        raise ValueError("MuseTalk-Python-Umgebung unvollstaendig.")
    for name in (".venv/pyvenv.cfg", "resolved-requirements.txt", "constraints.txt"):
        path = source.checked(dependencies / name)
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != files.get(name):
            raise ValueError("MuseTalk-Runtime-Datei fehlt/veraendert.")
    if full and source.inventory(dependencies) != files:
        raise ValueError("Python-Umgebung veraendert; vor Entfernung sichern. Keine Dateien geloescht.")
    return record


def install(base, checkout, source_marker, dependencies, marker):
    if marker.exists():
        validate(checkout, source_marker, dependencies, marker)
        print("MuseTalk-Abhaengigkeiten bereits vorhanden; kein Download/Upgrade. Inferenz nicht getestet.")
        return
    if dependencies.exists():
        raise ValueError("Python-Ordner ohne Runtime-Nachweis; manuell sichern/pruefen. Kein Ueberschreiben.")
    if checkout.exists() or source_marker.exists():
        source.validate(checkout, source_marker, SPEC, full=True)
    preflight(base)
    had_source = source_marker.exists()
    dependencies.mkdir(mode=0o700)
    pending = None
    try:
        source.install(checkout, source_marker, base, SPEC)
        source.reserve(base, dict(reserve_mb=RESERVE_MB))
        build(checkout, dependencies)
        record = dict(revision=REVISION, pin=SPEC["pin"], scope="dependencies", runtime_tested=False,
                      models_downloaded=False, files=source.inventory(dependencies))
        descriptor, pending = tempfile.mkstemp(prefix="runtime-ready-pending-", dir=base)
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(record, stream)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(pending, marker)
        print("MuseTalk: Python-Pakete und CUDA-Smoke-Test geprueft; keine Modelle, GUI, Dienste, Docker oder Inferenz gestartet.")
    except BaseException:
        marker.unlink(missing_ok=True)
        shutil.rmtree(source.checked(dependencies))
        if not had_source and source_marker.exists():
            source.validate(checkout, source_marker, SPEC, full=True)
            shutil.rmtree(source.checked(checkout))
            source_marker.unlink()
        print("Rollback: nur neue Runtime-Dateien entfernt; vorhandene Quellen, Modelle, Medien und Logs bleiben.")
        raise
    finally:
        if pending:
            Path(pending).unlink(missing_ok=True)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("install", "update", "repair", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)
    base, checkout, source_marker, dependencies, marker = locations()
    if args.dry_run or args.action == "plan":
        print(json.dumps(dict(scope="dependencies", source=SPEC, reserve_mb=RESERVE_MB, target=str(dependencies),
                              python="3.10", torch="2.0.1+cu118", blackwell_supported=False,
                              models_downloaded=False, runtime_tested=False), indent=2))
        print("Nur Plan; keine Hardwareabfrage, Downloads, Modelle oder Starts. Quellen-only: --source-only.")
        return 0
    if args.action in ("status", "check", "doctor"):
        sources, ready = False, False
        try:
            source.validate(checkout, source_marker, SPEC)
            sources = True
            validate(checkout, source_marker, dependencies, marker, full=args.action == "doctor")
            ready = True
        except (ValueError, OSError, subprocess.SubprocessError, KeyError, TypeError):
            pass
        print(json.dumps(dict(installed=ready, sources_present=sources, dependencies_ready=ready,
                              scope="dependencies" if ready else "source" if sources else "absent", runtime_tested=False)))
        return 0 if ready or args.action == "status" else 1
    with source.operation(base, args.action, tool="MuseTalk"):
        print("MuseTalk-Runtime-Installer:", REVISION, "GitHub:", SPEC["repo"], "Pin:", SPEC["pin"])
        if args.action == "uninstall":
            # Validate all owned trees before deleting either; preserve additional user data.
            if checkout.exists() or source_marker.exists():
                source.validate(checkout, source_marker, SPEC, full=True)
            if dependencies.exists() or marker.exists():
                validate(checkout, source_marker, dependencies, marker, full=True)
            if dependencies.exists():
                shutil.rmtree(source.checked(dependencies))
                marker.unlink()
            if checkout.exists():
                shutil.rmtree(source.checked(checkout))
                source_marker.unlink()
            print("Unveraenderte eigene Quellen/Python-Umgebung entfernt; Zusatzdateien verhindern Loeschung. Logs/Basiswerkzeuge bleiben.")
        else:
            install(base, checkout, source_marker, dependencies, marker)
    return 0
