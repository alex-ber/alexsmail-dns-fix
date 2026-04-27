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

#[RUNTIME_ENVIRONMENT]: Fetching TLS certificates and Target Python Architecture
RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

#[AOT_PYTHON_ALLOCATION]: Hardcoded request for target Python runtime
RUN set -ex && \
    uv python install 3.13.3

#[DEPENDENCY_INJECTION]: Lock and sync macro-graph
COPY pyproject.toml .
# Resolving and allocating dependencies via UV (creates isolated .venv automatically)
RUN set -ex && \
    uv sync

#[AST_COPY]: Transferring local execution logic to target runtime
# The .dockerignore boundary protects this step from macro-entropy
COPY . .

#[ENTRYPOINT]: Hardware transition function (Execution via UV proxy)
# Adjust "dns_fix.py" to match the actual entry node of your script
CMD["uv", "run", "python", "dns_fix.py"]


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