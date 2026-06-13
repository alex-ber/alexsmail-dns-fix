#[DECOHERENCE_BOUNDARY]: Ubuntu Base (Size Limit: IGNORED)
# Absolute Phase Lock. Pointer tags (e.g., :24.04) are PROHIBITED.
# docker pull ubuntu:24.04
# docker inspect --format='{{index .RepoDigests 0}}' ubuntu:24.04
# docker run --rm ubuntu:24.04 sh -c "apt-get update -qq && apt-cache policy ca-certificates nano"
# Retrieve the current pointer for UV:
# docker pull ghcr.io/astral-sh/uv:latest
# docker inspect --format='{{index .RepoDigests 0}}' ghcr.io/astral-sh/uv:latest

FROM ubuntu@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b

#[HARDWARE_CONFIG]: Deterministic execution and compilation flags
# Consolidated environment variables to reduce layer allocation overhead.
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

#[HARDWARE_BRIDGE]: Injecting UV Compiler (AOT Dependency Graph Resolver)
COPY --from=ghcr.io/astral-sh/uv@sha256:3a59a3cdd5f7c217faa36e32dbc7fddbb0412889c2a0a5229f6d790e5a019dd7 /uv /uvx /bin/


#[RUNTIME_ENVIRONMENT]: Deterministic APT Projection & Root Python Allocation
# Hard package pinning for maximum reproducibility.
# ca-certificates pinned to exact version + hold + preferences to prevent ANY upgrade.
RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates=20240203 \
        nano=7.2-2ubuntu0.1 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-mark hold ca-certificates nano \
    # Extra strict pinning: prevent newer versions even if they appear in repositories
    && echo 'Package: ca-certificates' > /etc/apt/preferences.d/ca-certificates-pin \
    && echo 'Pin: version 20240203' >> /etc/apt/preferences.d/ca-certificates-pin \
    && echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/ca-certificates-pin \
    && update-ca-certificates --fresh \
    && echo 'set syntax "none"' >> /etc/nanorc && \
    uv python install 3.13.3

#[DEPENDENCY_INJECTION]: Top-Down Directed Acyclic Graph Mount
COPY pyproject.toml uv.lock ./

#[POINTER_ALLOCATION]: Synthetic Mock-Node Cache Strategy
# Bypasses hatchling early parse exception, isolating dependency layer from source layer jitter.
RUN set -ex && \
    mkdir -p src/alexsmail_dns_fix && \
    echo '__version__ = "0.2.2"' > src/alexsmail_dns_fix/__init__.py && \
    uv sync --no-install-project

#[AST_COPY]: Mount Root Logic
COPY src/ src/

#[PROJECT_INJECTION]: Finalize Symbol Table Linkage
RUN set -ex && \
    uv sync

#[ENTRYPOINT]: Hardware Transition (Main Thread Execution)
CMD ["uv", "run", "python", "-m", "src.alexsmail_dns_fix.dns_fix"]



# ---[STATELESS BIRUR DAEMON] ---
# To regenerate uv.lock WITHOUT installing uv on the Host OS, run this ephemeral hypervisor:
# docker run --rm -v "$(pwd):/app" -w /app ghcr.io/astral-sh/uv:python3.13-bookworm-slim uv lock

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

#mise use uv@0.11.17
#sudo -E env PATH="$PATH" uv
#uv cache dir #~/.cache/uv
#uv cache clean #completely wipe out cache
#uv cache prune #outdated
#uv cache clean numpy #If you suspect a specific package is corrupted or you wa>
#uv sync
#uv run python -m src.alexsmail_dns_fix.dns_fix




#docker tag alexsmail-dns-fix-i alexberkovich/alexsmail-dns-fix:0.2.2
#docker tag alexsmail-dns-fix-i alexberkovich/alexsmail-dns-fix:latest
#docker push alexberkovich/alexsmail-dns-fix:0.2.2
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




