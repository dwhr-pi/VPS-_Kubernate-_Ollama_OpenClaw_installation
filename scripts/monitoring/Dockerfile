# Optionales OCI-Artefakt aus Repo-Code; Basis als geprueften Multi-Arch-Digest angeben.
ARG PYTHON_IMAGE
FROM ${PYTHON_IMAGE}
COPY scripts/monitoring/ollama_readonly_exporter.py /app/exporter.py
USER 10001:10001
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
ENTRYPOINT ["python3", "-I", "-B", "/app/exporter.py"]
