#!/bin/bash
# Wait for X server on display :1 to be ready before starting x11vnc
while ! xdpyinfo -display :1 >/dev/null 2>&1; do
    sleep 0.5
done
exec x11vnc -display :1 -xkb -forever -shared -repeat -capslock
