#!/usr/bin/env python3
"""Opt-in pinned native builds. Default is a side-effect-free JSON plan."""

import argparse
from contextlib import contextmanager, nullcontext
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import uuid


CATALOG = Path(__file__).resolve().parents[2] / "config/agents/native_clis.json"
OWNER = "openclaw-native-coding-v1"
ACTIONS = ("plan", "install", "update", "uninstall", "doctor", "status", "check")
SAFE_PATH = "/usr/local/bin:/usr/bin:/bin"
PROCESS_TIMEOUT_SECONDS = 3600
METADATA_OUTPUT_LIMIT = 4096


class Refused(RuntimeError):
    pass


def digest(path):
    with path.open("rb") as stream:
        value = hashlib.sha256()
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()


def catalog():
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    if data.get("schema") != 1:
        raise Refused("Unknown catalog schema")
    for tool, spec in data["tools"].items():
        if (not re.fullmatch(r"[a-z_]+", tool)
                or not re.fullmatch(r"[0-9a-f]{40}", spec["commit"])
                or not re.fullmatch(r"https://github.com/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+\.git", spec["origin"])
                or spec["kind"] not in ("bun", "python", "cargo", "source-only")
                or spec["disk_gib"] < 10):
            raise Refused("Unknown source/build contract")
        for name, sha in spec["contracts"].items():
            if Path(name).is_absolute() or ".." in Path(name).parts or not re.fullmatch(r"[0-9a-f]{64}", sha):
                raise Refused("Invalid contract hash/path")
    return data["tools"]


def guarded(path, private=False):
    """Reject symlinks at every existing component, including broken links."""
    path = Path(os.path.abspath(path))
    for item in (*reversed(path.parents), path):
        if item.is_symlink():
            raise Refused(f"Symlink path refused: {item}")
        if item.exists() and (item == path or private):
            info = item.stat()
            if private and (info.st_uid != os.getuid() or info.st_mode & 0o022):
                raise Refused(f"Not private/owned: {item}")
    return path


def private_path(path, base):
    path = guarded(path)
    if path != base and base not in path.parents:
        raise Refused("Path escaped native-coding root")
    cursor = path
    while cursor == base or base in cursor.parents:
        if cursor.exists():
            info = cursor.stat()
            if info.st_uid != os.getuid() or info.st_mode & 0o022:
                raise Refused(f"Not private/owned: {cursor}")
            if stat.S_ISREG(info.st_mode) and info.st_nlink != 1:
                raise Refused(f"Hardlinked file refused: {cursor}")
        if cursor == base:
            break
        cursor = cursor.parent
    return path


def roots(tool, data_dir=None):
    value = data_dir or os.environ.get("OPENCLAW_USER_DATA_DIR") or str(Path.home() / ".openclaw_ultimate_user_data")
    if not Path(value).is_absolute() or ".." in Path(value).parts:
        raise Refused("Data directory must be absolute without traversal")
    data = guarded(value)
    repository = CATALOG.parents[2]
    if data == repository or repository in data.parents:
        raise Refused("Data directory must be outside the repository")
    if (str(data) in ("/", "/opt", "/usr", "/etc", "/var", "/home", "/tmp")
            or any(p == Path("/opt") for p in (data, *data.parents))
            or data == Path.home()):
        raise Refused("Unsafe data directory; /opt legacy is never managed")
    base = data / "tools" / tool / "native-coding"
    guarded(base)
    # Existing data components must belong to this user and not be writable by others.
    for item in (data, data / "tools", base.parent, base):
        if item.exists():
            info = item.stat()
            if info.st_uid != os.getuid() or info.st_mode & 0o022:
                raise Refused(f"Unsafe data component: {item}")
    return base


def preflight(spec, base):
    if sys.platform != "linux" or platform.machine() != "x86_64" or platform.libc_ver()[0] != "glibc":
        raise Refused("Build/preparation supports native Linux x86_64 glibc only")
    if os.getuid() == 0:
        raise Refused("Run as a nonroot user; no sudo/apt/system changes")
    release = platform.release().lower()
    if "microsoft" in release or "wsl" in release or os.environ.get("WSL_INTEROP") or os.environ.get("WSL_DISTRO_NAME"):
        raise Refused("WSL host-resource guard not validated; build refused")
    existing = base
    while not existing.exists():
        existing = existing.parent
    if shutil.disk_usage(existing).free < spec["disk_gib"] * 1024**3:
        raise Refused(f"Need at least {spec['disk_gib']} GiB free")


def environment(home, toolbin=None):
    path = SAFE_PATH
    if toolbin:
        if not Path(toolbin).is_absolute():
            raise Refused("Toolchain directory must be absolute")
        directory = guarded(toolbin)
        if (not directory.is_dir() or directory.stat().st_mode & 0o022
                or directory.stat().st_uid not in (0, os.getuid())):
            raise Refused("Toolchain directory missing or writable by others")
        path = str(directory) + ":" + path
    return {
        "PATH": path, "HOME": str(home), "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
        "XDG_CONFIG_HOME": str(home / "config"), "XDG_CACHE_HOME": str(home / "cache"),
        "TMPDIR": str(home / "tmp"), "GIT_CONFIG_NOSYSTEM": "1",
        "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_TERMINAL_PROMPT": "0",
        "GIT_ALLOW_PROTOCOL": "https", "GIT_LFS_SKIP_SMUDGE": "1", "HUSKY": "0",
        "BUN_INSTALL_CACHE_DIR": str(home / "bun-cache"),
        "CARGO_HOME": str(home / "cargo"), "RUSTUP_AUTO_INSTALL": "0",
        "PIP_CONFIG_FILE": "/dev/null", "PIP_DISABLE_PIP_VERSION_CHECK": "1",
        "PIP_NO_INPUT": "1", "PYTHONNOUSERSITE": "1",
    }


def run(args, cwd, env, capture=False):
    with (tempfile.TemporaryFile(dir=env["TMPDIR"]) if capture else nullcontext()) as output:
        subprocess.run([str(a) for a in args], cwd=cwd, env=env, check=True,
                       stdin=subprocess.DEVNULL,
                       stdout=output if capture else subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL, timeout=PROCESS_TIMEOUT_SECONDS)
        if not capture:
            return ""
        output.seek(0)
        data = output.read(METADATA_OUTPUT_LIMIT + 1)
        if len(data) > METADATA_OUTPUT_LIMIT:
            raise Refused("Subprocess metadata output exceeds limit")
        return data.decode("utf-8").strip()


def executable(name, env):
    result = shutil.which(name, path=env["PATH"])
    if not result:
        raise Refused(f"Prerequisite missing: {name}; install it separately")
    resolved = Path(result).resolve(strict=True)
    if (resolved.name == "rustup" or resolved.stat().st_mode & 0o022
            or resolved.stat().st_uid not in (0, os.getuid())):
        raise Refused(f"Use existing real toolchain binaries, not writable tools/rustup shims: {name}")
    for parent in resolved.parents:
        info = parent.stat()
        if info.st_uid not in (0, os.getuid()) or (info.st_mode & 0o022 and not info.st_mode & stat.S_ISVTX):
            raise Refused(f"Unsafe toolchain ancestor: {parent}")
    return str(resolved)


def git(args, cwd, env):
    return run([executable("git", env), "-c", "core.hooksPath=/dev/null",
                "-c", "credential.helper=", "-c", "core.fsmonitor=false",
                "-c", "protocol.file.allow=never", *args], cwd, env,
               capture=args[0] in ("config", "rev-parse"))


def verify_source(source, spec, env):
    if git(["config", "--local", "--get", "remote.origin.url"], source, env) != spec["origin"]:
        raise Refused("Origin mismatch")
    if git(["rev-parse", "HEAD"], source, env) != spec["commit"]:
        raise Refused("Commit mismatch")
    for name, sha in spec["contracts"].items():
        file = private_path(source / name, source.parent)
        if not file.is_file() or digest(file) != sha:
            raise Refused(f"Unknown contract: {name}")


def hashed_lock(path, expected):
    if not path or not expected or not re.fullmatch(r"[0-9a-f]{64}", expected):
        raise Refused("Aider needs --hashed-lock and --lock-sha256 (reviewed dependencies AND build backends)")
    if not Path(path).is_absolute():
        raise Refused("Hashed lock path must be absolute")
    path = guarded(path)
    if not path.is_file() or digest(path) != expected:
        raise Refused("Hashed lock digest mismatch")
    text = path.read_text(encoding="utf-8").replace("\\\n", " ")
    count = 0
    for line in text.splitlines():
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        if not re.fullmatch(r"[A-Za-z0-9_.-]+(?:\[[A-Za-z0-9_,.-]+\])?==[A-Za-z0-9_.+!-]+(?:\s+--hash=sha256:[0-9a-f]{64})+", line):
            raise Refused("Lock must contain only exact package pins with SHA256 hashes; no includes/options/URLs/markers")
        count += 1
    if not count:
        raise Refused("Empty lock")
    return path


def build(tool, spec, version, env, lock=None):
    source = version / "source"
    kind = spec["kind"]
    if kind == "source-only":
        return source / spec["artifact"]
    if kind == "bun":
        bun = executable("bun", env)
        if run([bun, "--version"], version, env, capture=True) != spec["toolchain"]:
            raise Refused("Bun version must match pinned packageManager")
        run([bun, "install", "--frozen-lockfile", "--ignore-scripts"], source, env)
        for name, expected in (("@opentui/core", "0.7.0"), ("@opencode-ai/pty", "0.3.1")):
            # Bun workspace dependency symlinks are allowed only within this fresh source tree.
            package = None
            for parent in (source / "packages/cli", source / "packages", source):
                candidate = (parent / "node_modules" / name / "package.json").resolve()
                if source not in candidate.parents:
                    raise Refused("Prepared dependency escaped source tree")
                if candidate.is_file():
                    package = candidate
                    break
            if package is None:
                raise Refused("Frozen install did not prepare native build dependencies")
            if json.loads(package.read_text())["version"] != expected:
                raise Refused("Native dependency version mismatch")
        env = dict(env, OPENCODE_CHANNEL="local", OPENCODE_VERSION="0.0.0-pin." + spec["commit"][:12])
        run([bun, "run", "--cwd", "packages/cli", "build", "--single", "--skip-install"], source, env)
    elif kind == "cargo":
        cargo, rustc = executable("cargo", env), executable("rustc", env)
        for binary, name in ((cargo, "cargo"), (rustc, "rustc")):
            if not run([binary, "--version"], version, env, capture=True).startswith(name + " " + spec["toolchain"] + " "):
                raise Refused("Existing Rust/Cargo must match pinned rust-toolchain.toml")
        run([cargo, "build", "--locked", "--release", "--bin", "codex"], source / "codex-rs", dict(env, RUSTC=rustc))
    elif kind == "python":
        python = executable("python3", env)
        run([python, "-I", "-m", "venv", version / "venv"], version, env)
        py = version / "venv/bin/python"
        run([py, "-I", "-m", "pip", "install", "--isolated", "--require-hashes", "--only-binary=:all:",
             "--no-deps", "-r", lock], version, env)
        run([py, "-I", "-m", "build", "--wheel", "--no-isolation", "--outdir", version / "wheels"], source, env)
        wheels = list((version / "wheels").glob("aider_chat-*.whl"))
        if len(wheels) != 1:
            raise Refused("Expected exactly one Aider wheel")
        run([py, "-I", "-m", "pip", "install", "--isolated", "--no-index", "--no-deps", wheels[0]], version, env)
        run([py, "-I", "-m", "pip", "check"], version, env)
    else:
        raise Refused("Unknown build contract")
    return source / spec["artifact"]


@contextmanager
def locked(base):
    import fcntl
    path = private_path(base / ".lock", base)
    fd = os.open(path, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    try:
        info = os.fstat(fd)
        if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or info.st_nlink != 1 or info.st_mode & 0o077:
            raise Refused("Unsafe lifecycle lock")
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as exc:
            raise Refused("Another lifecycle operation holds the lock") from exc
        yield
    finally:
        os.close(fd)


def tree_hash(root):
    """Integrity evidence for SDK sources / installed Python libraries, not .git."""
    value = hashlib.sha256()
    for directory, dirs, files in os.walk(root, followlinks=False):
        dirs[:] = sorted(d for d in dirs if not (Path(directory) == root and d == ".git"))
        for name in sorted(files + [d for d in dirs if (Path(directory) / d).is_symlink()]):
            path = Path(directory) / name
            relative = path.relative_to(root).as_posix()
            if path.is_symlink():
                target = path.resolve(strict=True)
                # venv Python links point to the separately provisioned interpreter.
                if root.name != "venv" and root not in target.parents:
                    raise Refused("Source symlink escaped tree")
                contents = "link:" + os.readlink(path)
            else:
                if not path.is_file() or path.stat().st_nlink != 1:
                    raise Refused("Unsupported tree entry")
                contents = digest(path)
            value.update(json.dumps([relative, contents], separators=(",", ":")).encode())
    return value.hexdigest()


def evidence(base, tool, spec, target=None):
    active = base / "current"
    if target is None:
        if not active.is_symlink():
            if active.exists():
                raise Refused("Unowned activation path")
            return {"state": "absent", "runtime_ready": False}
        target = Path(os.readlink(active))
    if target.is_absolute() or len(target.parts) != 2 or target.parts[0] != "versions":
        raise Refused("Unsafe activation target")
    version = private_path(base / target, base)
    marker = private_path(version / "OWNED.json", base)
    data = json.loads(marker.read_text())
    if any(data.get(k) != v for k, v in {
        "owner": OWNER, "uid": os.getuid(), "tool": tool, "commit": spec["commit"],
        "origin": spec["origin"], "contracts": spec["contracts"],
        "runtime_ready": spec["kind"] != "source-only",
    }.items()):
        raise Refused("Ownership/pin evidence mismatch")
    expected = Path(os.path.normpath("source/" + spec["artifact"]))
    if data.get("artifact") != expected.as_posix():
        raise Refused("Unexpected evidence artifact")
    artifact = private_path(version / expected, base)
    if not artifact.is_file() or digest(artifact) != data.get("sha256"):
        raise Refused("Artifact hash mismatch")
    for name, sha in spec["contracts"].items():
        if digest(private_path(version / "source" / name, base)) != sha:
            raise Refused("Source evidence changed")
    if spec["kind"] in ("source-only", "python"):
        tree = version / ("source" if spec["kind"] == "source-only" else "venv")
        if tree_hash(tree) != data.get("tree_sha256"):
            raise Refused("Source/venv tree evidence changed")
    if spec["kind"] == "python":
        lock = private_path(version / "requirements.hashed.txt", base)
        if digest(lock) != data.get("lock_sha256"):
            raise Refused("Dependency lock evidence changed")
    return dict(data, state="built" if data["runtime_ready"] else "source-prepared", version=str(version))


def prepare(tool, spec, base, args, rebuild=False):
    if not rebuild and base.exists():
        private_path(base, base)
        with locked(base):
            current = evidence(base, tool, spec)
            if current["state"] != "absent":
                return current
    preflight(spec, base)
    lock = hashed_lock(args.hashed_lock, args.lock_sha256) if spec["kind"] == "python" else None
    # Parent directories are private and never reused through symlinks.
    base.mkdir(parents=True, exist_ok=True, mode=0o700)
    private_path(base, base)
    with locked(base):
        current = evidence(base, tool, spec)
        if not rebuild and current["state"] != "absent":
            return current
        versions = private_path(base / "versions", base)
        versions.mkdir(mode=0o700, exist_ok=True)
        version = versions / (spec["commit"] + "-" + uuid.uuid4().hex)
        version.mkdir(mode=0o700)
        home = version / "build-home"
        home.mkdir(mode=0o700)
        for name in ("tmp", "config", "cache", "cargo"):
            (home / name).mkdir(mode=0o700)
        env = environment(home, args.toolchain_bin)
        if lock:
            (version / "requirements.hashed.txt").write_bytes(lock.read_bytes())
            lock = version / "requirements.hashed.txt"
            if digest(lock) != args.lock_sha256:
                raise Refused("Lock changed during copy")
        source = version / "source"
        git(["init", "--template=", str(source)], version, env)
        git(["remote", "add", "origin", spec["origin"]], source, env)
        git(["fetch", "--depth=1", "--no-tags", "origin", spec["commit"]], source, env)
        git(["checkout", "--detach", spec["commit"]], source, env)
        verify_source(source, spec, env)
        artifact = build(tool, spec, version, env, lock)
        artifact = private_path(Path(os.path.normpath(artifact)), base)
        if not artifact.is_file() or (spec["kind"] != "source-only" and not os.access(artifact, os.X_OK)):
            raise Refused("Expected executable artifact not produced")
        verify_source(source, spec, env)
        data = {
            "owner": OWNER, "uid": os.getuid(), "tool": tool, "commit": spec["commit"],
            "origin": spec["origin"], "license": spec["license"], "contracts": spec["contracts"],
            "artifact": artifact.relative_to(version).as_posix(), "sha256": digest(artifact),
            "runtime_ready": spec["kind"] != "source-only", "lock_sha256": args.lock_sha256 if lock else None,
        }
        if spec["kind"] in ("source-only", "python"):
            data["tree_sha256"] = tree_hash(version / ("source" if spec["kind"] == "source-only" else "venv"))
        (version / "OWNED.json").write_text(json.dumps(data, indent=2) + "\n")
        evidence(base, tool, spec, version.relative_to(base))
        evidence(base, tool, spec)
        pending = base / (".activate-" + uuid.uuid4().hex)
        pending.symlink_to(version.relative_to(base))
        os.replace(pending, base / "current")
        return evidence(base, tool, spec)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=tuple(catalog()))
    parser.add_argument("action", nargs="?", choices=ACTIONS, default="plan")
    parser.add_argument("--plan", "--dry-run", dest="plan", action="store_true", help="Override any action with a read-only plan")
    parser.add_argument("--data-dir")
    parser.add_argument("--toolchain-bin", help="Existing trusted tool binaries; no toolchain installation")
    parser.add_argument("--hashed-lock")
    parser.add_argument("--lock-sha256")
    args = parser.parse_args(argv)
    spec = catalog()[args.tool]
    action = "plan" if args.plan else args.action
    try:
        # Planning is portable, even on Windows; Linux guards apply to lifecycle state.
        if action == "plan":
            data = args.data_dir or os.environ.get("OPENCLAW_USER_DATA_DIR") or str(Path.home() / ".openclaw_ultimate_user_data")
            result = dict(spec, tool=args.tool, action="plan", requested_action=args.action,
                          root=str(Path(data) / "tools" / args.tool / "native-coding"),
                          runtime_ready=False, executes=False,
                          restrictions="nonroot native Linux x86_64 glibc; no WSL; no automatic prerequisites")
        else:
            if sys.platform != "linux" or os.getuid() == 0:
                raise Refused("Lifecycle state requires nonroot Linux; use --plan elsewhere")
            base = roots(args.tool, args.data_dir)
            if action in ("install", "update"):
                result = prepare(args.tool, spec, base, args, rebuild=action == "update")
            elif action == "uninstall" and base.exists():
                with locked(base):
                    result = evidence(base, args.tool, spec)
                    if result["state"] != "absent":
                        (base / "current").unlink()
                    result = {"state": "deactivated", "runtime_ready": False, "retained": str(base)}
            else:
                result = evidence(base, args.tool, spec)
                if action in ("check", "doctor"):
                    result["checks"] = "ownership, fixed pin, contract and artifact hashes; no agent execution"
                    if result["state"] == "absent":
                        print(json.dumps(result, indent=2))
                        return 1
        print(json.dumps(result, indent=2))
        return 0
    except (Refused, OSError, ValueError, KeyError, subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
        # Never print subprocess output: dependency tools may emit credentials or tracing.
        if isinstance(exc, subprocess.TimeoutExpired):
            message = "Subprocess timed out; no activation performed"
        elif isinstance(exc, subprocess.CalledProcessError):
            message = "Subprocess failed; no activation performed"
        else:
            message = str(exc)
        print(json.dumps({"state": "refused", "error": message, "runtime_ready": False}), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
