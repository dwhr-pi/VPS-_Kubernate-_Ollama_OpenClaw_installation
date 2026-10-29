# Digest stammt aus dem offiziellen LiteLLM-Registry-Manifest (2026-10-29).
FROM ghcr.io/berriai/litellm@sha256:37e2dafb088a7723beb998590682957386dfc83ffea1848486f8e0e5cfac0b06
COPY --chmod=0444 config.yaml /etc/llmops/config.yaml
ENV HOME=/tmp XDG_CACHE_HOME=/tmp/cache PYTHONDONTWRITEBYTECODE=1
USER 10001:10001
EXPOSE 4000
# Kein automatisches Modell-Laden oder Cloud-Fallback.
ENTRYPOINT ["litellm"]
CMD ["--config", "/etc/llmops/config.yaml", "--port", "4000", "--num_workers", "1"]
