ARG DEBIAN_RELEASE=bullseye
ARG ARCH=amd64

# Stage 1 - Fetch and build easy-novnc
FROM ${ARCH}/golang:1.14-buster AS easy-novnc-build

WORKDIR /src

RUN go mod init build \
    && go get github.com/geek1011/easy-novnc@v1.1.0 \
    && go build -o /bin/easy-novnc github.com/geek1011/easy-novnc


# Stage 2 - Download and prepare attr utility
FROM ${ARCH}/alpine AS attr-downloader

ADD https://gist.githubusercontent.com/xZero707/7a3fb3e12e7192c96dbc60d45b3dc91d/raw/44a755181d2677a7dd1c353af0efcc7150f15240/attr.sh /attr
RUN chmod a+x /attr



# Stage 3 - Prepare rootfs
FROM scratch AS rootfs-builder

COPY --from=attr-downloader          ["/attr",           "/rootfs/usr/bin/"]
COPY --from=easy-novnc-build         ["/bin/easy-novnc", "/rootfs/usr/local/bin/"]
COPY --from=nlss/s6-rootfs:2.2.0.3   ["/",               "/rootfs/"]
COPY ["./rootfs", "/rootfs/"]


# Final stage - environment
FROM ${ARCH}/debian:${DEBIAN_RELEASE}-slim AS app

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       lxterminal \
       nano \
       openbox \
       tigervnc-standalone-server \
       wget \
       xdg-utils \
    && rm -rf /var/lib/apt/lists \
    && rm -rf /var/cache/apt/ \
    && mkdir -p /data/.config/openbox/ \
    && groupadd --gid 1000 app \
    && useradd --home-dir /data --shell /bin/bash --uid 1000 --gid 1000 app \
    && mkdir -p /usr/share/desktop-directories \
    && mv /etc/xdg/openbox/rc.xml /data/.config/openbox/rc.xml

COPY --from=rootfs-builder /rootfs/ /

# Environment variables
ENV APP_NAME    "Openbox"
ENV DISPLAY     ":0"
ENV HOME        "/data/"
ENV S6_KEEP_ENV 1


VOLUME ["/data"]
ENTRYPOINT ["/init"]

EXPOSE 8080
