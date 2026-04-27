# Publishing Pipeline

This document defines the strict hardware procedures for injecting the `alexsmail-dns-fix` metric space into global WAN repositories (Docker Hub and PyPI). 
To prevent `[HOST_POLLUTION]`, all compilation and publishing tasks are executed through ephemeral Docker transpilers, maintaining absolute Zero Trust on the local WSL2/Windows machine.

---

## [VECTOR A]: Docker Hub Transit (Image Deployment)
This pipeline deploys the fully encapsulated runtime (Ubuntu Base + Python + Dependencies + Logic).

### 1. Alias Allocation
Re-assign the local pointer to match the WAN coordinate system (your Docker Hub UID).
```bash
docker tag alexsmail-dns-fix-i alexberkovich/alexsmail-dns-fix:0.0.1
docker tag alexsmail-dns-fix-i alexberkovich/alexsmail-dns-fix:latest
```

### 2. Authorization
Allocate your Personal Access Token (PAT) into the daemon state machine.
```bash
docker login
# Use 'alexberkovich' as username and the PAT generated at app.docker.com as the password.
```

### 3. Macro-Graph Transmission
Push the topological layers through the WAN barrier.
```bash
docker push alexberkovich/alexsmail-dns-fix:0.0.1
docker push alexberkovich/alexsmail-dns-fix:latest
```
*(Note: If you encounter an `EOF` fault during transit due to corporate DPI limits, refer to `NETSKOPE_DPI_BYPASS.md` for Single-Thread configurations).*

---

## [VECTOR B]: Dependency Graph Locking (uv.lock Regeneration)
If you modified `pyproject.toml` and need to regenerate the exact cryptographic dependency graph (`uv.lock`), you must extract it through the isolated `.secrets` volume bridge.

### 1. Enter the Sandbox
```bash
docker run -it -p 8080:8080 --entrypoint /bin/bash -v "$(pwd)/.secrets:/app/.secrets" alexsmail-dns-fix-i
```

### 2. Lock and Extract (Internal Transfer)
Execute the transpiler and manually route the artifact through the DMA bridge:
```bash
# DO IT ONLY TO REGENERATE uv.lock!!!
uv lock
mv uv.lock .secrets/uv.lock
exit
```

### 3. Host OS Finalization
After exiting the container, return to your WSL2 terminal and move the file to the project root to ensure future deterministic builds:
```bash
mv .secrets/uv.lock ./uv.lock

---

## [VECTOR C]: PyPI Transit (Pure Python Package Deployment)

### 1. Ephemeral Sandbox Initiation
Initialize the container in interactive mode. The `--entrypoint /bin/bash` flag overrides automatic execution, granting you UID 0 control.
```bash
# Execute from the root directory of the project
docker run -it -p 8080:8080 --entrypoint /bin/bash -v "$(pwd)/.secrets:/app/.secrets" alexsmail-dns-fix-i
```
*(You are now inside the isolated container terminal).*

### 2. Artifact Compilation
Invoke the transpiler to parse `pyproject.toml` (via `hatchling`) and generate distribution binaries.
```bash
uv build
```
*Expected Result: The `dist/` directory containing `.tar.gz` and `.whl` artifacts will be materialized inside the container's read-write layer.*

### 3. Cryptographic Token Allocation
Inject your PyPI API Token into the ephemeral RAM. This prevents token leakage into bash history or persistent files.
```bash
export UV_PUBLISH_TOKEN="pypi-YOUR_LONG_TOKEN_STRING"
```

### 4. Atomic Publish
Execute the Stateless publish command. The transpiler will attach the token, transmit the `dist/` artifacts, and await a `200 OK` `[ACK]` from PyPI.
```bash
uv publish
```

### 5. Sandbox Destruction
Once the transaction is confirmed, halt the process.
```bash
exit
```
*Note: Since the `--rm` flag is omitted, the container transitions to an `Exited` state on your disk, awaiting your asynchronous manual Garbage Collection cycle.*

