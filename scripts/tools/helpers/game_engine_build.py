"""Optional Godot Linux source build; never starts projects, GUI or XR devices."""
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess


def settings():
    if os.environ.get('INSTALL_HEAVY_TOOLS') != '1':
        raise ValueError('Godot_Build: explizit INSTALL_HEAVY_TOOLS=1 setzen; siehe docs/tools/ai-game-engines-xr-wallpaper.md.')
    if platform.system() != 'Linux' or platform.machine() not in ('x86_64', 'aarch64'):
        raise ValueError('Godot_Build: nur Linux x86_64/aarch64; Windows/macOS-Build separat upstream, kein Cross-Build.')
    jobs = os.environ.get('GODOT_BUILD_JOBS', '1')
    if jobs not in ('1', '2'):
        raise ValueError('GODOT_BUILD_JOBS: nur 1 oder 2 erlaubt.')
    return jobs, 'x86_64' if platform.machine() == 'x86_64' else 'arm64'


def preflight():
    settings()
    memory = dict(line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(memory['MemAvailable'].split()[0]) < 6 * 1024**2:
        raise ValueError('Godot_Build: mindestens 6 GiB verfuegbarer RAM vor Download erforderlich.')
    for command in ('scons', 'g++', 'pkg-config'):
        if not shutil.which(command):
            raise ValueError('Godot_Build: ' + command + ' fehlt; Build-Abhaengigkeiten separat einrichten, kein automatisches apt/pip.')
    result = subprocess.run(['scons', '--version'], check=True, capture_output=True, text=True, timeout=30)
    version = re.search(r'SCons: v(\d+)\.(\d+)', result.stdout)
    if not version or tuple(map(int, version.groups())) < (4, 4):
        raise ValueError('Godot_Build: SCons >=4.4 erforderlich.')


def build(runtime, env, pin):
    from find_skills import checked
    from gap_tools import run
    from native_build_process import run as stream_build
    jobs, arch = settings()
    env.update(GODOT_VERSION_STATUS='stable', GODOT_VERSION_HASH=pin)
    args = [shutil.which('scons'), 'platform=linuxbsd', 'target=editor', 'arch=' + arch,
            'module_mono_enabled=no', 'debug_symbols=no', '-j' + jobs]
    print('Godot: lokaler Editor-Build, keine Export-Templates oder SDK-Downloads; 1-2 Buildjobs.', flush=True)
    stream_build(args, runtime, env, timeout=14400)
    entry = 'bin/godot.linuxbsd.editor.' + arch
    binary = checked(runtime / entry)
    if not binary.is_file() or not os.access(binary, os.X_OK):
        raise ValueError('Godot-Buildartefakt fehlt oder ist nicht ausfuehrbar: ' + entry)
    version = run([binary, '--headless', '--version'], runtime, env)
    if not version.startswith('4.7.2.'):
        raise ValueError('Godot-Versionspruefung passt nicht zum Pin: ' + version)
    print('Editor gebaut; KEIN Projekt-/VR-/AR-/Wallpaper-Test durchgefuehrt.', flush=True)
    return [entry, 'LICENSE.txt', 'SConstruct']
