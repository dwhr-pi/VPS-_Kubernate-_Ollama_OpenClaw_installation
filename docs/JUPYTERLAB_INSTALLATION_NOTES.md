# JupyterLab Installation Notes

## Warum der GitHub-Source-Build scheitern kann

Der direkte Build aus `https://github.com/jupyterlab/jupyterlab` ist ein
Entwicklerpfad. Dabei wird das komplette Frontend mit Yarn/JLPM, Lerna/Nx und
Rspack gebaut.

Im Log war der entscheidende Fehler:

```text
Unsupported Node.js version "18.19.1". Rspack requires Node.js 20.19+ or 22.12+.
```

Das ist kein normaler Anwender-Installationspfad. Fuer WSL2, MiniPC und VPS soll
JupyterLab stabil aus dem Python-Paket installiert werden.

## Neuer Standardpfad

Der Installer nutzt standardmaessig:

```bash
bash scripts/tools/jupyterlab_install.sh
```

Das installiert JupyterLab in ein isoliertes venv unter:

```text
/opt/jupyterlab/.venv
```

und legt den CLI-Link an:

```text
/usr/local/bin/jupyter-lab-openclaw
```

## Check und feste Version

```bash
bash scripts/tools/jupyterlab_install.sh --check
JUPYTERLAB_VERSION=4.3.5 bash scripts/tools/jupyterlab_install.sh
```

## Source-Build nur bewusst

Nur fuer Entwickler:

```bash
JUPYTERLAB_INSTALL_MODE=source bash scripts/tools/jupyterlab_install.sh
```

Vorbedingung:

```text
Node.js >= 20.19 oder >= 22.12
```

Wenn Node 18 erkannt wird, bricht der Source-Modus vor dem langen Build ab.

## Sicherheit

- JupyterLab nicht oeffentlich ohne Auth freigeben.
- Standardbindung lokal halten, z. B. `127.0.0.1`.
- Tokens und Notebook-Daten nicht ins Repo schreiben.
- Remote-Zugriff bevorzugt ueber WireGuard, Tailscale oder Reverse Proxy mit Auth.

