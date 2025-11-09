# syntax=docker/dockerfile:1
FROM alpine:3

# Install nextcloud-client and basics
RUN apk add --no-cache \
      nextcloud-client \
      ca-certificates \
      tzdata \
      bash \
      tini \
      su-exec

# Create a non-root user to run the sync
ARG PUID=3000
ARG PGID=1000
RUN addgroup -g ${PGID} ncsync && \
    adduser  -D -H -G ncsync -u ${PUID} ncsync

# Folders:
# /data   -> mount the local folder you want to sync
# /config -> optional config with 'exclude' and/or 'unsyncedfolders' files
RUN mkdir -p /data /config
VOLUME ["/data", "/config"]

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV NC_REMOTE_PATH="/" \
    NC_INTERVAL="600" \
    NC_ARGS=""

# Use tini as PID 1 for signal handling
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]
