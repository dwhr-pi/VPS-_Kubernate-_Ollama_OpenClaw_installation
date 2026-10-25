"""Stream compiler diagnostics with bounded memory and explicit process status."""
from collections import deque
import os
import signal
import subprocess
import threading
import time


def run(args, cwd, env, timeout=7200, heartbeat=30):
    print('Befehl:', ' '.join(map(str, args)), flush=True)
    process = subprocess.Popen(list(map(str, args)), cwd=cwd, env=env,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               text=True, errors='replace', start_new_session=os.name == 'posix')
    print('Buildprozess gestartet; PID:', process.pid, flush=True)
    tail = deque(maxlen=256)
    errors = []

    def read():
        try:
            for chunk in iter(lambda: process.stdout.readline(4096), ''):
                tail.append(chunk)
                print(chunk, end='', flush=True)
        except Exception as error:
            errors.append(error)

    reader = threading.Thread(target=read, daemon=True)
    reader.start()
    deadline = time.monotonic() + timeout
    try:
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise subprocess.TimeoutExpired(args, timeout)
            try:
                code = process.wait(timeout=min(heartbeat, remaining))
                break
            except subprocess.TimeoutExpired:
                print('Build laeuft; PID:', process.pid, '(noch kein Abschlussstatus).', flush=True)
        reader.join(timeout=5)
        if reader.is_alive() or errors:
            raise OSError('Build-Ausgabe nicht vollstaendig lesbar; kein Erfolgsnachweis.')
        print('Buildprozess beendet; PID:', process.pid, 'Exit:', code, flush=True)
        if code < 0:
            print('Build durch Signal beendet:', -code,
                  '; SIGKILL kann OOM bedeuten, ist aber kein OOM-Nachweis. Kernel-/WSL-Logs pruefen.', flush=True)
        if code:
            raise subprocess.CalledProcessError(code, args, output=''.join(tail))
        return ''.join(tail).strip()
    except BaseException:
        if process.poll() is None:
            if os.name == 'posix':
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            else:
                process.kill()
            process.wait()
        print('Build abgebrochen; PID:', process.pid, 'Exit:', process.returncode,
              '(Timeout/Signal/Fehler; kein Erfolgsnachweis).', flush=True)
        raise
    finally:
        reader.join(timeout=5)
        if not reader.is_alive():
            process.stdout.close()
