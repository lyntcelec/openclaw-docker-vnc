FROM dorowu/ubuntu-desktop-lxde-vnc

RUN rm /etc/apt/sources.list.d/google-chrome.list && apt-get update

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

COPY openclaw-gateway.conf /tmp/openclaw-gateway.conf
RUN cat /tmp/openclaw-gateway.conf >> /etc/supervisor/conf.d/supervisord.conf && rm /tmp/openclaw-gateway.conf

RUN printf '#!/bin/bash\nexport DISPLAY=:1\nexec /usr/bin/google-chrome "$@"\n' > /usr/local/bin/chrome-wrapper && \
    chmod +x /usr/local/bin/chrome-wrapper

ENV HOME=/root