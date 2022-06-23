#!/bin/bash

# shellcheck disable=SC1091

# Load libraries
. /opt/drycc/scripts/libfs.sh
. /opt/drycc/scripts/libminio.sh

# Load MinIO environment
. /opt/drycc/scripts/minio-env.sh

# Ensure non-root user has write permissions on a set of directories
for dir in "$MINIO_DATA_DIR" "$MINIO_CERTS_DIR" "$MINIO_LOGS_DIR" "$MINIO_SECRETS_DIR"; do
    ensure_dir_exists "$dir"
done
chmod -R g+rwX "$MINIO_DATA_DIR" "$MINIO_CERTS_DIR" "$MINIO_LOGS_DIR" "$MINIO_SECRETS_DIR"

# Redirect all logging to stdout/stderr
ln -sf /dev/stdout "$MINIO_LOGS_DIR/minio-http.log"
