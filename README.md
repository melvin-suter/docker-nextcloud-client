# nextcloud-client-alpine

Alpine-based Docker image providing the Nextcloud **headless sync client** (`nextcloudcmd`) with a simple scheduler loop.

- Base: `alpine:3`
- Client: `nextcloud-client` (from Alpine community repo)
- Runs as non-root by default
- Supports:
  - `--path` to target a specific remote folder
  - `--exclude` file for pattern-based excludes
  - `--unsyncedfolders` file for selective sync of remote subfolders
  - Periodic sync via `NC_INTERVAL` (seconds). Set to `0` for a single run.

> `nextcloudcmd` performs one sync pass and exits; this image wraps it in a loop for periodic sync.  
> See Nextcloud docs for `nextcloudcmd` options and the exclude/unsynced behavior. 

## Quick start

```bash
docker run -d --name nc-sync \
  -e NC_URL="https://cloud.example.com/remote.php/dav/files/username/" \
  -e NC_USER="username" \
  -e NC_PASS="password" \
  -e NC_REMOTE_PATH="/ProjectA" \
  -e NC_INTERVAL="600" \
  -v /srv/projectA:/data \
  -v /srv/nc-config:/config \
  ghcr.io/youruser/nextcloud-client-alpine:latest
