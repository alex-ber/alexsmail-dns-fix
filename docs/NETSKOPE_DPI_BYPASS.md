# Corporate DPI (Netskope) Bypass Protocol

This document defines the strict hardware patches required to pierce the corporate `[MACRO_LATENCY_LIMIT]` and restore absolute I/O connectivity between the local WSL2 Docker daemon and global WAN nodes (Docker Hub).

The corporate Deep Packet Inspection (DPI) architecture (Netskope) acts as a Byzantine node, generating two distinct topological faults:
1. **Cryptographic `[KLIPOT]`:** Deep Packet Inspection intercepts TLS handshakes, replacing the original `registry-1.docker.io` certificate with a surrogate corporate Root CA, triggering a fatal `x509: certificate signed by unknown authority`.
2. **Transport Layer `[DROP_PACKET]`:** Concurrent uploads of massive binary blobs trigger firewall timeouts, severing the TCP connection (`EOF`) during `docker push`.

---

## [VECTOR A]: Root CA Injection (TLS Trust Chain Restoration)
To restore cryptographic integrity, the daemon must physically recognize the corporate surrogate key (e.g., Netskope or equivalent DPI firewall). We must probe the exact outbound network route to extract the correct Root CA.

If your network architecture utilizes a local proxy to route outbound traffic, export its coordinates to your environment:
```bash
# Replace with your actual proxy IP and port
export CORPORATE_PROXY_HOST="PROXY_IP:PORT"
```

Execute the following automated pipeline in your WSL2 terminal:

### 1. Automated Extraction and Injection
This command forces an `openssl` probe through the defined proxy, extracts the terminating Root CA block, and securely allocates it into the Ubuntu certificate store.
```bash
echo -n | openssl s_client -showcerts -proxy $CORPORATE_PROXY_HOST -connect registry-1.docker.io:443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sudo tee /usr/local/share/ca-certificates/corporate_root.crt > /dev/null
```
*(If no proxy is used, simply remove the `-proxy $CORPORATE_PROXY_HOST` flag from the command).*

### 2. Trust Base Recompilation
Commit the new metric space to the OS `[UNITARY_NVRAM]`.
```bash
sudo update-ca-certificates
# Expected output: "1 added, 0 removed; done."
```

### 3. Daemon Synchronization
Force the Docker transpiler to parse the updated trust graph.
```bash
sudo service docker restart
```
*Validation:* Execute `docker login`. The daemon will now authenticate securely through the DPI interception layer.


---

## [VECTOR B]: Hardware Tzimtzum (Single-Thread I/O Serialization)
Pushing image layers to Docker Hub concurrently overwhelms the Netskope DPI memory buffer, resulting in terminal `EOF` connection resets. We must apply a strict Hardware Tzimtzum (compressing parallel chaos into a deterministic sequential line) via the Docker daemon configuration.


### 1. Daemon Topology Modification
We must inject `"max-concurrent-uploads": 1` into the Docker daemon settings. 
*(Note: If you already have existing configurations in `/etc/docker/daemon.json`, such as custom DNS, manually append this key to the existing JSON object rather than overwriting the entire file).*

If the file is empty or missing, execute this block to allocate the invariant safely:
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "max-concurrent-uploads": 1
}
EOF
```

### 2. State Reset and Retransmission
Restart the transpiler to enforce the new thermodynamic constraints.
```bash
sudo service docker restart
```

### 3. Brute-Force Retransmission
Initiate the WAN transit. The daemon will now push layers sequentially. 
```bash
docker push alexberkovich/alexsmail-dns-fix:latest
```
*Note: Docker transit is idempotent. If a layer was partially uploaded before the configuration change, the daemon will register `Layer already exists` and resume deterministic transmission without duplicating data.*
