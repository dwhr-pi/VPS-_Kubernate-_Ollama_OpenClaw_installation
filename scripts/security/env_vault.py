#!/usr/bin/env python3
"""Local age-encrypted credentials and explicitly approved dotenv rendering (Linux)."""
import argparse
from contextlib import contextmanager
import getpass
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

REPO = Path(__file__).resolve().parents[2]
NAME = re.compile(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,79}\Z")
KEY = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")
ASSIGN = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=(.*)$")


class VaultError(Exception):
    pass


def identifier(value):
    if not NAME.fullmatch(value):
        raise VaultError("Ungueltiger Name; nur Buchstaben, Zahlen, Punkt, Strich, Unterstrich.")
    return value


def no_symlinks(path):
    for part in (path, *path.parents):
        if part.is_symlink():
            raise VaultError("Symlinks sind fuer Tresor-/Ausgabepfade nicht erlaubt.")


class Workspace:
    def __init__(self, root=None):
        self.root = Path(root or os.environ.get("OPENCLAW_USER_DATA_DIR", "~/.openclaw_ultimate_user_data")).expanduser().absolute()
        no_symlinks(self.root)
        if self.root.resolve().is_relative_to(REPO):
            raise VaultError("User-Workspace muss ausserhalb des Repositories liegen.")
        self.directory = self.root / "backups" / "credentials"
        self.vault = self.directory / "env-vault.age"

    def private_dir(self, directory):
        no_symlinks(directory)
        directory.mkdir(parents=True, exist_ok=True, mode=0o700)
        directory.chmod(0o700)

    @contextmanager
    def locked(self):
        self.private_dir(self.directory)
        lock = self.directory / ".vault.lock"
        try:
            fd = os.open(lock, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        except FileExistsError:
            raise VaultError("Tresor gesperrt. Anderen Vorgang beenden; nach Absturz Lock manuell pruefen.") from None
        try:
            os.write(fd, str(os.getpid()).encode("ascii"))
            os.close(fd)
            yield
        finally:
            lock.unlink()

    def load(self):
        no_symlinks(self.vault)
        if not self.vault.is_file():
            raise VaultError("Tresor fehlt. Zuerst init ausfuehren.")
        data = json.loads(age_run(["--decrypt", str(self.vault)]).decode("utf-8"))
        if not isinstance(data, dict) or data.get("version") != 1 or not isinstance(data.get("values"), dict) or not isinstance(data.get("bindings"), dict):
            raise VaultError("Unbekanntes Tresorformat.")
        if any(not isinstance(value, str) for value in data["values"].values()):
            raise VaultError("Unbekanntes Werteformat im Tresor.")
        for bindings in data["bindings"].values():
            if not isinstance(bindings, dict) or any(not KEY.fullmatch(key) or not isinstance(value, str) for key, value in bindings.items()):
                raise VaultError("Unbekanntes Zuordnungsformat im Tresor.")
        return data

    def save(self, data):
        ciphertext = age_run(["--passphrase"], json.dumps(data).encode("utf-8"))
        atomic_write(self.vault, ciphertext, replace=True)


def age_run(args, payload=None):
    if os.name != "posix" or not sys.stdin.isatty():
        raise VaultError("Tresorzugriff braucht ein interaktives Linux-/WSL-Terminal.")
    executable = shutil.which("age")
    if not executable:
        raise VaultError("age fehlt. Siehe docs/ENV_VAULT.md; keine automatische Installation.")
    # age may print a generated passphrase: keep all its prompts out of install logs.
    with open("/dev/tty", "wb") as terminal:
        result = subprocess.run([executable, *args], input=payload, stdout=subprocess.PIPE, stderr=terminal, check=False)
    if result.returncode:
        raise VaultError("age-Vorgang fehlgeschlagen oder abgebrochen; Tresor unveraendert.")
    return result.stdout


def atomic_write(target, content, replace=False):
    no_symlinks(target)
    if target.exists() and not replace:
        raise VaultError("Zieldatei existiert. Nur mit --replace bewusst ersetzen.")
    fd, temporary = tempfile.mkstemp(prefix=".vault-write-", dir=target.parent)
    temporary = Path(temporary)
    try:
        with os.fdopen(fd, "wb") as output:
            os.chmod(temporary, 0o600)
            output.write(content)
            output.flush()
            os.fsync(output.fileno())
        if not replace:
            # Hard-link creation is exclusive: an existing target is never overwritten.
            os.link(temporary, target)
        else:
            no_symlinks(target)
            os.replace(temporary, target)
    finally:
        temporary.unlink(missing_ok=True)


def catalog():
    data = json.loads((REPO / "config" / "tools.yml").read_text(encoding="utf-8"))
    return {item["id"]: item["name"] for item in data["tools"]}


def template_for(tool, explicit=None):
    alias = {"cloudflared": "cloudflare"}.get(tool, tool)
    candidates = [Path(explicit).expanduser()] if explicit else [
        REPO / "config" / f"{alias}.env.example",
        REPO / "tools" / tool / ".env.example",
        REPO / "stacks" / tool / ".env.example",
    ]
    for path in candidates:
        if path.is_file() and (path.name.endswith(".env.example") or path.name == ".env.example"):
            return path
    raise VaultError("Keine .env.example gefunden. Mit --template eine gepruefte Vorlage angeben.")


def render_env(template, data, tool):
    bindings = data["bindings"].get(tool, {})
    if not bindings:
        raise VaultError("Keine ENV-Zuordnungen fuer dieses Tool. Zuerst bind verwenden.")
    seen, changed, output = set(), [], []
    for line in template.splitlines():
        if any(ord(char) < 32 and char != "\t" for char in line):
            raise VaultError("Steuerzeichen in ENV-Vorlage nicht erlaubt.")
        if not line.strip() or line.lstrip().startswith("#"):
            output.append(line)
            continue
        match = ASSIGN.fullmatch(line)
        if not match:
            raise VaultError("Vorlage enthaelt eine nicht unterstuetzte ENV-Zeile. Keine Shell-Ausfuehrung erlaubt.")
        key = match[1]
        if key in seen:
            raise VaultError("Vorlage enthaelt doppelte ENV-Felder.")
        seen.add(key)
        if key in bindings:
            value = data["values"].get(bindings[key])
            if not isinstance(value, str) or not value:
                raise VaultError("Ein zugeordneter Tresorwert fehlt oder ist leer.")
            if any(ord(char) < 32 or char in "'\\" for char in value):
                raise VaultError("Wert nicht sicher im unterstuetzten dotenv-Format darstellbar (Steuerzeichen, Apostroph, Backslash).")
            line = f"{key}='{value}'"
            changed.append(key)
        output.append(line)
    if set(bindings) - seen:
        raise VaultError("Zugeordnete ENV-Felder fehlen in dieser Vorlage; Ausgabe abgebrochen.")
    return "\n".join(output) + "\n", changed


def read_secret():
    if not sys.stdin.isatty():
        raise VaultError("Geheime Werte nur interaktiv eingeben, nicht als CLI-Argument oder Pipe.")
    value = getpass.getpass("Geheimer Wert (unsichtbar): ")
    if not value or value != getpass.getpass("Wert bestaetigen: "):
        raise VaultError("Werte leer oder nicht identisch.")
    return value


def parser():
    result = argparse.ArgumentParser(description="Verschluesselter lokaler ENV-Tresor; nie Secret-Werte als Argumente eingeben.")
    commands = result.add_subparsers(dest="command", required=True)
    for name in ("init", "status", "catalog", "menu"):
        commands.add_parser(name)
    setting = commands.add_parser("set")
    setting.add_argument("name")
    setting.add_argument("--replace", action="store_true")
    binding = commands.add_parser("bind")
    binding.add_argument("tool")
    binding.add_argument("key")
    binding.add_argument("name")
    rendering = commands.add_parser("render")
    rendering.add_argument("tool")
    rendering.add_argument("--template")
    rendering.add_argument("--apply", action="store_true")
    rendering.add_argument("--replace", action="store_true")
    return result


def execute(args):
    workspace = Workspace()
    tools = catalog()
    if args.command == "catalog":
        for tool, name in sorted(tools.items()):
            try:
                template_for(tool)
                state = "Vorlage vorhanden"
            except VaultError:
                state = "eigene .env.example erforderlich"
            print(f"{tool}: {name} | {state}")
        return
    if args.command == "status":
        print("Tresor vorhanden." if workspace.vault.is_file() else "Tresor noch nicht angelegt.")
        print("Speicherort: User-Workspace/backups/credentials/env-vault.age")
        return
    if args.command == "menu":
        menu()
        return
    if hasattr(args, "tool") and args.tool not in tools:
        raise VaultError("Unbekannte Tool-ID. catalog zeigt alle registrierten Programme.")
    if args.command == "render":
        template = template_for(args.tool, args.template).read_text(encoding="utf-8-sig")
        with workspace.locked():
            content, fields = render_env(template, workspace.load(), args.tool)
            print("Auszufuellende Felder: " + ", ".join(fields))
            if not args.apply:
                print("Nur Vorschau; keine Werte angezeigt und keine ENV-Datei geschrieben. --apply zum Schreiben.")
                return
            directory = workspace.root / "env" / identifier(args.tool)
            workspace.private_dir(directory)
            atomic_write(directory / ".env", content.encode("utf-8"), replace=args.replace)
            print("ENV im User-Workspace unter env/" + args.tool + "/.env geschrieben (0600). Kein Dienst gestartet.")
        return
    with workspace.locked():
        if args.command == "init":
            if workspace.vault.exists():
                raise VaultError("Tresor existiert bereits; kein Ueberschreiben.")
            data = {"version": 1, "values": {}, "bindings": {}}
        else:
            data = workspace.load()
            identifier(args.name)
            if args.command == "set":
                if args.name in data["values"] and not args.replace:
                    raise VaultError("Eintrag existiert. --replace fuer bewusste Rotation verwenden.")
                data["values"][args.name] = read_secret()
            else:
                if not KEY.fullmatch(args.key) or args.name not in data["values"]:
                    raise VaultError("ENV-Feld ungueltig oder Tresoreintrag fehlt.")
                data["bindings"].setdefault(args.tool, {})[args.key] = args.name
        print("age fragt jetzt die Passphrase zum Speichern ab. Bestehende Masterpassphrase erneut verwenden oder bewusst aendern.")
        workspace.save(data)
        print("Verschluesselter Tresor gespeichert. Keine Werte ausgegeben.")


def menu():
    if not sys.stdin.isatty():
        raise VaultError("Menue braucht ein interaktives Terminal.")
    while True:
        print("\nENV-Tresor: 1 Status | 2 Anlegen | 3 Wert speichern | 4 Zuordnen | 5 ENV-Vorschau | 6 ENV schreiben | 7 Tool-Katalog | 0 Zurueck")
        choice = input("Auswahl: ").strip()
        if choice == "0":
            return
        options = {"1": ["status"], "2": ["init"], "7": ["catalog"]}
        if choice == "3":
            options[choice] = ["set", input("Eintragsname (kein geheimer Wert): ").strip()]
        elif choice == "4":
            options[choice] = ["bind", input("Tool-ID: ").strip(), input("ENV-Feld: ").strip(), input("Eintragsname: ").strip()]
        elif choice in ("5", "6"):
            options[choice] = ["render", input("Tool-ID: ").strip()]
            template = input("Vorlage .env.example (leer = automatisch): ").strip()
            if template:
                options[choice] += ["--template", template]
            if choice == "6" and input("Klartext-ENV schreiben? [(j)a/(N)ein]: ").lower() in ("j", "ja"):
                options[choice] += ["--apply"]
        if choice in options:
            try:
                execute(parser().parse_args(options[choice]))
            except (VaultError, OSError, ValueError):
                print("Vorgang abgebrochen/fehlgeschlagen. CLI und docs/ENV_VAULT.md fuer Diagnose verwenden; keine Werte angezeigt.")


def main():
    os.umask(0o077)
    try:
        execute(parser().parse_args())
        return 0
    except VaultError as error:
        print("Fehler: " + str(error), file=sys.stderr)
    except (OSError, ValueError):
        print("Fehler: Datei-/Formatzugriff fehlgeschlagen; keine Werte ausgegeben.", file=sys.stderr)
    except (KeyboardInterrupt, EOFError):
        print("Abgebrochen; keine Werte ausgegeben.", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
