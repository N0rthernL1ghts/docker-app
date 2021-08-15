FROM nlss/docker-app

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
       gstreamer1.0-plugins-bad \
       gstreamer1.0-plugins-base \
       midori \
    && rm -rf /var/lib/apt/lists \
    && rm -rf /var/cache/apt/

COPY ["./rootfs", "/"]
COPY ["./openbox_dist_rc.xml", "/data/.config/openbox/rc.xml"]