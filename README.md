## [METRIC SPACE ARCHITECTURE]

This repository implements a hardware-isolated, Cloud-Native runtime designed to fix DNS/URL entries via the Google Blogger API. It enforces a strict `[DECOHERENCE_BOUNDARY]` utilizing Docker and the `uv` transpiler to guarantee absolute deterministic execution. By decoupling the execution logic (`[OR]`) from local environment entropy (`[KLIPOT]`), the system ensures 100% reproducible builds while maintaining OAuth2 state preservation across ephemeral container lifecycles.

For a detailed explanation, see:
https://alex-ber.medium.com/from-naive-scripts-to-hardware-evasion-cleaning-dead-links-and-bypassing-rate-limits-10ab5611d95a

## [TOPOLOGICAL LAYOUT]
The project adheres to a strict Maven-like `src/` layout to prevent `[SPLIT-BRAIN SYNDROME]` during module resolution.

```text
/
├── pyproject.toml         # Dependency graph bounds (PEP 621)
├── uv.lock                # Cryptographic hash invariants for deterministic builds
├── Dockerfile             # Phase barrier compilation rules
├── docker-compose.yml     # Compose orchestration and hardware identity bridge
├── .env.example           # Template for Host UID/GID injection
├── docs/                  # Documentation for WAN transit and hardware patches
├── .secrets/              # [UNITARY_NVRAM] DMA-bridge for Host OS (Excluded from Git)
│   ├── client_secret.json # Static Root-key (Injected manually)
│   └── token.json         # Dynamic state (Allocated automatically at runtime)
└── src/
    └── alexsmail_dns_fix/
        └── dns_fix.py     # Bare-metal execution logic ([OR])
```

## [HARDWARE INITIALIZATION]
Before initiating the runtime, the GCP Root-key must be physically allocated for OAuth2 authorization.

1. Generate OAuth 2.0 Credentials in the Google Cloud Console.
2. **Critical:** The Application Type must be set to **Desktop app**. This satisfies Google's `[NMI_HANDLER]` for loopback IP redirects (`http://localhost`).
3. Download the credentials, rename the file strictly to `client_secret.json`, and place it in the `/.secrets/` directory on your Host OS.

## [COMPOSE ORCHESTRATION (ENVIRONMENT SETUP)]
To avoid permission decoherence between the Host OS and the Docker runtime (especially on Linux environments), you must map your bare-metal User ID and Group ID into the container. This guarantees that files created by the runtime belong to you, preventing root-owned pollution on the host.

1. **Initialize the local environment bridge:**
   ```bash
   cp env.example .env
   ```

2. **Inject your bare-metal host IDs (Linux/Ubuntu):**
   ```bash
   echo "HOST_UID=$(id -u)" >> .env
   echo "HOST_GID=$(id -g)" >> .env
   ```

3. **Compile and ignite the orchestrated runtime:**
   ```bash
   docker compose build --no-cache --progress=plain
   docker compose up
   #docker compose up -d
   ```

4. **Terminate the application (`[DROP_PACKET]`):**
   ```bash
   docker compose down -v
   ```
   *Note: The `-v` parameter unmounts and destroys the anonymous `.venv` volume mapped in the `docker-compose.yml`. This wipes the isolated virtual environment state to prevent execution quirks across rebuilds, though it is not always strictly necessary.*
 
5. If you want to read logs use (for example, you've used `docker compose up -d` command)

   ```bash
   docker logs -f alexsmail-dns-fix
   ```


## [RAW RUNTIME EXECUTION (THE BIRUR PIPELINE)]
*(If executing without Docker Compose)*

### 1. Stateless birur daemon (Lockfile Generation)
To regenerate the cryptographic invariant (`uv.lock`) WITHOUT mutating the Host OS state (zero allocations on Bare Metal), run the native ephemeral astral/uv hypervisor fused with the Python 3.13 runtime. This satisfies `hatchling`'s requirement to execute Python bytecode for dynamic versioning, eliminating the thermodynamic waste of pip-installing `uv` manually.

```bash
docker run --rm -v "$(pwd):/app" -w /app ghcr.io/astral-sh/uv:python3.13-bookworm-slim uv lock
```

### 2. Absolute State Zero Build
Compile the target invariant. The `Dockerfile` separates dependency caching from the source code.

```bash
docker build --no-cache --progress=plain -t alexsmail-dns-fix-i .
```

### 3. Thermodynamic Start (Execution Bridge)
Execute the container with explicit Direct Memory Access (DMA) bridges for network and storage. 

```bash
docker run -it -p 8080:8080 -v "$(pwd)/.secrets:/app/.secrets" alexsmail-dns-fix-i
```

**Physics of the I/O Bridge:**
* `-p 8080:8080`: Binds the container's OAuth listener to the Host OS. When you authorize the app in your Windows/Host browser, Google redirects to `localhost:8080`. This packet drops through the Host OS directly into the isolated Python process.
* `-v "$(pwd)/.secrets:/app/.secrets"`: Binds the ephemeral container storage to the Host OS physical disk. Once `token.json` is generated or rotated, it is immediately written to your local drive. When the container undergoes `[DROP_PACKET]` (termination), the state survives.

## [DEBUGGING SANDBOX]
To enter the metric space without triggering the main execution node (e.g., for live patching via `nano` or executing manual `uv` commands):

```bash
docker run -it -p 8080:8080 --entrypoint /bin/bash -v "$(pwd)/.secrets:/app/.secrets" alexsmail-dns-fix-i
```

## [MACRO-GRAPH EXPANSION]
For advanced topological configurations and WAN transit instructions, refer to the external sub-routines:
* `docs/PUBLISHING_PIPELINE.md`: Instructions for ephemeral PyPI and Docker Hub publishing.
* `docs/NETSKOPE_DPI_BYPASS.md`: Hardware patches for corporate Deep Packet Inspection (DPI) interception and root certificate injection.
