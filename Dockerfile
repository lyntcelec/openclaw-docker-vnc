FROM dorowu/ubuntu-desktop-lxde-vnc

RUN rm /etc/apt/sources.list.d/google-chrome.list && apt-get update

RUN curl -fsSL https://tailscale.com/install.sh | sh

RUN mkdir -p /run/tailscale /var/lib/tailscale

COPY tailscaled.conf /tmp/tailscaled.conf
RUN cat /tmp/tailscaled.conf >> /etc/supervisor/conf.d/supervisord.conf && rm /tmp/tailscaled.conf

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

COPY openclaw-gateway.conf /tmp/openclaw-gateway.conf
RUN cat /tmp/openclaw-gateway.conf >> /etc/supervisor/conf.d/supervisord.conf && rm /tmp/openclaw-gateway.conf

RUN printf '#!/bin/bash\nexport DISPLAY=:1\nexec /usr/bin/google-chrome "$@"\n' > /usr/local/bin/chrome-wrapper && \
    chmod +x /usr/local/bin/chrome-wrapper

# Patch VNC health check to tolerate supervisorctl exit code 3
# (exit 3 = some processes not running, which is normal for optional services)
RUN mv /usr/bin/supervisorctl /usr/bin/supervisorctl.real && \
    printf '#!/bin/bash\n/usr/bin/supervisorctl.real "$@"\nexit 0\n' > /usr/bin/supervisorctl && \
    chmod +x /usr/bin/supervisorctl

ENV HOME=/root