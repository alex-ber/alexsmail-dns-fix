# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-04-27

### Added
- Initial metric space allocation for the DNS fix module (`alexsmail-dns-fix`).
- Integration of Google Blogger API (`google-api-python-client`, `google-auth-oauthlib`).
- `[DECOHERENCE_BOUNDARY]` implementation via `Dockerfile` targeting Ubuntu 24.04 bare-metal execution.
- Strict Maven-like `src/` directory topology to isolate execution logic (`[OR]`) from metadata (`[KELIM]`).
- Absolute deterministic dependency resolution using `uv`, `hatchling` (PEP 621), and exact `uv.lock` caching.
- Cross-session Volume Mount architecture (`.secrets/`) for persistent OAuth token storage (`[UNITARY_NVRAM]`).
- Headless OAuth2 authentication bridge (`bind_addr='0.0.0.0'`, `host='localhost'`) to bypass container ephemerality and satisfy strict Google Security Policies.
- Exponential backoff algorithm (`_execute_with_backoff`) to prevent API quota exhaustion (Thermal Trips). More explanations will be provided.
- Hardware patch for `nano` editor inside the container (forced monochromatic mode to eliminate ANSI syntax highlighting entropy).
- Ephemeral sandbox pipeline for native PyPI publishing (`uv build`, `uv publish`).

### Fixed
- Transport layer `EOF` connection resets during Docker Hub pushes by forcing single-threaded I/O daemon configurations (documented externally).