# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Jupydoc is a Docker-based JupyterLab server environment designed for local development. It provides a containerized Jupyter environment with scientific computing packages, VNC support, and a management script (`jl.sh`) for handling multiple container instances.

## Architecture

### Core Components

1. **Dockerfile**: Debian-based image with JupyterLab, scientific Python packages, and VNC server
2. **jl.sh**: Bash script (requires Bash 4+) that manages Docker container lifecycle - starts new containers, allows logging in, opening in browser, and removing containers
3. **start_jl_in_docker.sh**: Container entrypoint that launches JupyterLab as the `fherwig` user
4. **Configuration files**:
   - `apt-packages.txt`: System packages installed via apt-get
   - `pip-packages.txt`: Python packages installed via pip
   - `dot.bash_aliases`: Custom bash aliases and VNC launcher function
   - `shortcuts.jupyterlab-settings`: JupyterLab keyboard shortcuts

### Container Design

- Base image: `debian:bullseye-slim`
- User: `fherwig` (non-root)
- Exposed ports: 8888 (JupyterLab), 5901 (VNC)
- Volume mounts:
  - Current directory → `/home/fherwig/work`
  - Host `$HOME` → `/home/fherwig/home`
- Container naming: `jd_<directory_name>.<tag>`
- VNC password: `csa2024` (hardcoded in Dockerfile:52-54)

### jl.sh Script Logic

The script uses associative arrays (requires Bash 4+) and implements:
- Port auto-discovery starting from 8888
- Multi-container management with numeric action codes:
  - Single digit (e.g., `0`): Log in to container
  - Double digit (e.g., `00`): Open in Chrome
  - Triple digit (e.g., `000`): Remove container
- Token extraction from container logs for automatic browser launch
- Tag selection via `--tag` option

## Development Commands

### Building the Image

```bash
# Standard release build
make release

# Local development build (tagged as 'local')
make build

# Force rebuild without cache
make no-cache
```

### Running JupyterLab

```bash
# Start with default 'latest' tag
./jl.sh

# Start with specific tag
./jl.sh --tag <tag>

# See available tags
./jl.sh --help
```

### Managing Containers

When `jl.sh` runs and containers exist:
- Enter `<n>` to log in to container n
- Enter `<nn>` to open container n in Chrome
- Enter `<nnn>` to remove container n
- Enter `new` to start new container
- Enter `killall` to remove all jd_* containers

### VNC Access

Inside container:
```bash
jl_vncserver  # Launches VNC server on :1 (port 5901) with PulseAudio
```
Connect from host: `vnc://localhost:5901` (password: `csa2024`)

### Audio Support in VNC

The container includes PulseAudio for audio support in Firefox (e.g., YouTube videos).

**Setup (macOS):**
```bash
brew install pulseaudio
```

That's it! The `jl.sh` script automatically:
1. Starts PulseAudio on the host when creating a container (if not already running)
2. Configures network audio forwarding via port 4713 with IP-based ACL
3. The container connects to host PulseAudio automatically

**Audio Quality:**
- Configured for 48kHz sample rate with 24-bit depth
- Fragment size: 25ms for low latency
- Network audio may have slight quality degradation compared to native

**Troubleshooting:**
- If audio quality is poor, check network latency
- Audio might stutter if host CPU is busy
- For better quality on Linux: use `--device /dev/snd` for direct audio device access

## Package Management

### Adding System Packages
Edit `apt-packages.txt` and rebuild image.

### Adding Python Packages
Edit `pip-packages.txt` and rebuild image. Note that JupyterLab 3.x is pinned.

## Key Implementation Details

- jl.sh requires Homebrew Bash on macOS (uses `/opt/homebrew/bin/bash` shebang) for associative array support
- Container hostname is set to match container name for easier identification
- JupyterLab announcements/telemetry extension is disabled (Dockerfile:25)
- The script auto-opens Chrome on macOS using `open -a "Google Chrome"`
- Token extraction relies on parsing `docker logs` output
- jl.sh automatically starts PulseAudio on the host when creating containers (if not already running)
- PulseAudio port 4713 is exposed for network audio forwarding from container to host
- `--add-host=host.docker.internal:host-gateway` enables container to reach host's PulseAudio server
- VNC password is hardcoded as `csa2024` in Dockerfile:48
