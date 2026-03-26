#!/bin/bash

echo "Initializing OpenClaw container..."

# Wait for the OpenClaw binary to be installed
while ! command -v openclaw &>/dev/null; do
  echo "Waiting for OpenClaw binary to be installed..."
  sleep 5
done

echo "OpenClaw binary found."

# Wait for the config to be created (by `openclaw setup`)
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
while [ ! -f "$CONFIG_FILE" ]; do
  echo "Waiting for OpenClaw config ($CONFIG_FILE)..."
  sleep 5
done

echo "OpenClaw config found. Starting gateway..."

# Run the OpenClaw gateway in the foreground so that the container stays alive
exec openclaw gateway run