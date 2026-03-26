#!/bin/bash
# Remove stale X lock files left over from previous container runs
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
exec /usr/bin/Xvfb :1 -screen 0 1024x768x24
