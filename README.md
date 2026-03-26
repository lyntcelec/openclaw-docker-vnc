# openclaw-docker-vnc

A Docker image that packages [OpenClaw](https://github.com/lyntcelec/openclaw-docker-vnc) with a full Ubuntu LXDE desktop environment accessible via VNC and web browser. OpenClaw agents can run in an isolated, remotely-accessible container with GUI and browser capabilities.

## Features

- Ubuntu desktop (LXDE) with VNC access
- Web-based VNC client (noVNC) on port 6080
- OpenClaw Gateway auto-starts via Supervisor
- Google Chrome available on the virtual display
- GPU passthrough support
- Built-in [Tailscale](https://tailscale.com/) for secure remote access without exposing ports

## Quick Start

### Build the image

```bash
docker build -t openclaw-vnc .
```

### Run the container

#### With Tailscale (recommended)

If you use Tailscale, you don't need to expose any ports — access the container via its Tailscale IP instead.

```bash
docker run --name openclaw \
  --restart=unless-stopped \
  --add-host host.docker.internal:host-gateway \
  -e VNC_PASSWORD=1234567890 \
  -e RESOLUTION=1280x720 \
  -w /root/.openclaw \
  -it \
  -v /root/openclaw/docker_data:/root/.openclaw \
  --gpus all \
  openclaw-vnc
```

After the container starts, authenticate Tailscale:

```bash
docker exec openclaw tailscale up
```

Then access the services via the container's Tailscale IP (e.g. `http://<tailscale-ip>/` for noVNC).

#### Without Tailscale

```bash
docker run --name openclaw \
  --restart=unless-stopped \
  --add-host host.docker.internal:host-gateway \
  -p 18789:18789 \
  -p 6080:80 \
  -p 5900:5900 \
  -e VNC_PASSWORD=1234567890 \
  -e RESOLUTION=1280x720 \
  -w /root/.openclaw \
  -it \
  -v /root/openclaw/docker_data:/root/.openclaw \
  --gpus all \
  openclaw-vnc
```

## Ports

| Port | Description |
|------|-------------|
| `18789` | OpenClaw Gateway |
| `6080` | noVNC web client (mapped from container port 80) |
| `5900` | VNC server |

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VNC_PASSWORD` | Password for VNC access | `1234567890` |
| `RESOLUTION` | Desktop resolution | `1280x720` |

## Volumes

| Host Path | Container Path | Description |
|-----------|---------------|-------------|
| `/root/openclaw/docker_data` | `/root/.openclaw` | OpenClaw config and workspace data |

The volume mount persists OpenClaw configuration (`openclaw.json`) and workspace data across container restarts.

## How It Works

1. The container starts an Ubuntu LXDE desktop with a VNC server (from the base image [dorowu/ubuntu-desktop-lxde-vnc](https://github.com/fcwu/docker-ubuntu-vnc-desktop))
2. Tailscale daemon (`tailscaled`) starts automatically via Supervisor in userspace-networking mode
3. Supervisor manages the OpenClaw Gateway process via `start.sh`
4. `start.sh` waits for the `openclaw` binary and config file (`~/.openclaw/openclaw.json`) to be available, then starts the gateway
5. A Chrome wrapper script is included that routes Chrome to the virtual display (`:1`)

### Setup

On first run, you need to install the OpenClaw binary and run `openclaw setup` inside the container to generate the configuration file. The gateway will start automatically once both are available.

## Logs

Supervisor logs can be found at:

**OpenClaw Gateway:**
- stdout: `/var/log/openclaw-gateway-0.log`
- stderr: `/var/log/openclaw-gateway-0.err`

**Tailscale:**
- stdout: `/var/log/tailscaled.log`
- stderr: `/var/log/tailscaled.err`

## License

[MIT](LICENSE) - Copyright (c) 2026 Ly Nguyen
