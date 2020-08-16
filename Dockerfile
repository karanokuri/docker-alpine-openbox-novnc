FROM alpine:3.12

ARG NOVNC_VERSION=v1.1.0
ARG WEBSOCKIFY_VERSION=v0.9.0

RUN addgroup alpine \
 && adduser -G alpine -s /bin/sh -D alpine \
 && echo "alpine:alpine" | /usr/sbin/chpasswd \
 && echo "alpine    ALL=(ALL) ALL" >> /etc/sudoers \
 && chown -R alpine:alpine /home/alpine \
 && apk --no-cache add \
      bash \
      openbox \
      python2 \
      supervisor \
      ttf-cantarell \
      x11vnc \
      xvfb \
 && mkdir /noVNC \
 && wget -q -O - https://github.com/novnc/noVNC/archive/${NOVNC_VERSION}.tar.gz \
    | tar xz --strip 1 -C /noVNC \
 && mkdir /noVNC/utils/websockify \
 && wget -q -O - https://github.com/novnc/websockify/archive/${WEBSOCKIFY_VERSION}.tar.gz \
    | tar xz --strip 1 -C /noVNC/utils/websockify \
 && sed -i -- "s/ps -p/ps -o pid | grep/g" /noVNC/utils/launch.sh \
 && rm -rf /tmp/* /var/cache/apk/*

COPY supervisord.conf /etc/supervisord.conf

ENV DISPLAY=:0 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720

EXPOSE 8080
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
