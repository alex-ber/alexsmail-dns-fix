#[DECOHERENCE_BOUNDARY]: Ubuntu Base (Size Limit: IGNORED)
FROM ubuntu:24.04

#[HARDWARE_CONFIG]: Deterministic execution and compilation flags
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

WORKDIR /app

#[HARDWARE_BRIDGE]: Injecting UV compiler directly from authorized registry
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

#[RUNTIME_ENVIRONMENT]: Fetching TLS certificates and nano and Target Python Architecture
RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates nano && \
    echo 'set syntax "none"' >> /etc/nanorc && \
    rm -rf /var/lib/apt/lists/*
	
#[AOT_PYTHON_ALLOCATION]: Hardcoded request for target Python runtime
RUN set -ex && \
    uv python install 3.13.3

#[DEPENDENCY_INJECTION]: Lock and sync macro-graph dependencies ONLY
# Strict mapping of uv.lock ensures absolute determinism. Omission triggers kernel panic.
COPY pyproject.toml uv.lock ./

#[POINTER_ALLOCATION]: Synthetic Mock-node to satisfy hatchling dynamic version parser
# Flag --no-install-project prevents hatchling from looking for src/ prematurely
RUN set -ex && \
    mkdir -p src/alexsmail_dns_fix && \
    echo '__version__ = "0.2.1"' > src/alexsmail_dns_fix/__init__.py && \
    uv sync --no-install-project

#[AST_COPY]: Transferring local execution logic to target runtime
# Strict src-layout allocation to prevent macro-entropy leakage
COPY src/ src/

#[PROJECT_INJECTION]: Finalize venv by linking the local project
# This DOES NOT upgrade external dependencies. It only registers src/.
RUN set -ex && \
    uv sync

#[ENTRYPOINT]: Hardware transition function (Execution via UV proxy)
#CMD ["tail", "-f", "/dev/null"]
CMD ["uv", "run", "python", "-m", "src.alexsmail_dns_fix.dns_fix"]

# ---[STATELESS BIRUR DAEMON] ---
# To regenerate uv.lock WITHOUT installing uv on the Host OS, run this ephemeral hypervisor:
# docker run --rm -v "$(pwd):/app" -w /app python:3.13-slim sh -c "pip install uv --no-cache-dir --disable-pip-version-check --root-user-action=ignore && uv lock"

#docker build --no-cache --progress=plain -t alexsmail-dns-fix-i .
#docker run -it -p 8080:8080 -v "$(pwd)/.secrets:/app/.secrets" alexsmail-dns-fix-i
# The --entrypoint /bin/bash flag overrides the default script execution.
# You get a Linux command line INSIDE the container.
#docker run -it -p 8080:8080 --entrypoint /bin/bash -v "$(pwd)/.secrets:/app/.secrets" alexsmail-dns-fix-i

# ---[PyPI PUBLISHING PIPELINE] ---
# uv build
# Allocate token in RAM (Replace YOUR_TOKEN):
# export UV_PUBLISH_TOKEN="pypi-YOUR_TOKEN"
# Transmit artifacts to WAN (PyPI):
# uv publish 


#docker tag alexsmail-dns-fix-i alexberkovich/alexsmail-dns-fix:0.2.1
#docker tag alexsmail-dns-fix-i alexberkovich/alexsmail-dns-fix:latest
#docker push alexberkovich/alexsmail-dns-fix:0.2.1
#docker push alexberkovich/alexsmail-dns-fix:latest


# Delete all containers
# docker rm -f $(docker ps -a -q)

# This command will only show the dangling images 
# (images that are not tagged or referenced by any container)
# docker images -f "dangling=true"

# Delete all dangling images
# docker image prune -f

# Delete all unused images
# docker image prune -a -f

# Delete all images
# docker rmi -f $(docker images -q)

# Delete all build cache
# docker builder prune --all
# Verify builder cache deleted
# docker builder du

# https://gallery.ecr.aws/lambda/python/
# docker system prune --all
# docker rm -f alexsmail-dns-fix
# docker rmi -f alexsmail-dns-fix-i

# docker build --no-cache . -t alexsmail-dns-fix-i
# docker build --no-cache --progress=plain . -t alexsmail-dns-fix-i

# docker run --rm -it alexsmail-dns-fix-i bash
# docker exec -it $(docker ps -q -n=1) bash

# sudo docker stats | sudo tee -a docker_stats.log
# sudo watch -n 15 "docker stats --no-stream | sudo tee -a docker_stats.log"
# RAM+SWAP memory
# watch -n 1 free -h




