#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/drycc/scripts/liblog.sh

if [[ "$*" = *"/opt/drycc/scripts/minio/run.sh"* ]]; then
    info "** Starting MinIO setup **"
    /opt/drycc/scripts/minio/setup.sh
    info "** MinIO setup finished! **"
fi

echo ""
exec "$@"
