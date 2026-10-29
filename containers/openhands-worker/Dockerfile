# BASE_IMAGE must be independently reviewed and pinned by digest using image-plan.
# It must already contain Python 3.13, uv and git; no curl|bash/toolchain bootstrap.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
USER root
RUN mkdir -p /opt/openhands-sdk /tmp/build-home && chown -R 10001:10001 /opt/openhands-sdk /tmp/build-home
USER 10001:10001
ENV HOME=/tmp/build-home PYTHONDONTWRITEBYTECODE=1 UV_NO_CACHE=1 UV_PYTHON_DOWNLOADS=never
WORKDIR /opt/openhands-sdk
RUN git -c core.hooksPath=/dev/null init . \
    && git remote add origin https://github.com/OpenHands/software-agent-sdk.git \
    && git -c credential.helper= -c http.followRedirects=false fetch --depth=1 origin 47bbc5e8392c4c75b7f77a1da38bed4a9f53d6a5 \
    && git -c core.hooksPath=/dev/null checkout --detach FETCH_HEAD \
    && test "$(git rev-parse HEAD)" = 47bbc5e8392c4c75b7f77a1da38bed4a9f53d6a5 \
    && uv sync --frozen --no-dev --no-default-groups --no-python-downloads --package openhands-tools
ENV PATH=/opt/openhands-sdk/.venv/bin:${PATH}
LABEL org.opencontainers.image.source="https://github.com/OpenHands/software-agent-sdk" \
      org.opencontainers.image.revision="47bbc5e8392c4c75b7f77a1da38bed4a9f53d6a5"
WORKDIR /workspace
# Controller supplies the read-only runner. No daemon, server port or login.
CMD ["python3", "--version"]
