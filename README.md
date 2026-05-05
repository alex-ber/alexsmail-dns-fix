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

## [RUNTIME EXECUTION (THE BIRUR PIPELINE)]

### 1. Stateless birur daemon

To regenerate uv.lock WITHOUT installing uv on the Host OS, run this ephemeral hypervisor.

```bash
docker run --rm -v "$(pwd):/app" -w /app python:3.13-slim sh -c "pip install uv --no-cache-dir --disable-pip-version-check --root-user-action=ignore && uv lock"
```

### 2. Absolute State Zero Build
Compile the target invariant. The `Dockerfile` separates dependency caching from the source code.

```bash
docker build --no-cache --progress=plain -t alexsmail-dns-fix-i .
```

### 3. Thermodynamic Start (Execution Bridge)
Execute the container with explicit Direct Memory Access (DMA) bridges for network and storage. 

```bash
docker run -it -p 8080:8080 -v "$(pwd)/.secrets:/app/.secrets" alexsmail-dns-fix
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
