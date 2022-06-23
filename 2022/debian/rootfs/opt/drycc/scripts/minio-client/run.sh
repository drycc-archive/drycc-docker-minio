#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/drycc/scripts/liblog.sh
. /opt/drycc/scripts/libos.sh
. /opt/drycc/scripts/libminioclient.sh

# Load MinIO Client environment
. /opt/drycc/scripts/minio-client-env.sh

# Constants
EXEC=$(command -v mc)
ARGS=("--config-dir" "${MINIO_CLIENT_CONF_DIR}" "$@")

if am_i_root; then
    exec gosu "${MINIO_CLIENT_DAEMON_USER}" "${EXEC}"  "${ARGS[@]}"
else
    exec "${EXEC}" "${ARGS[@]}"
fi
