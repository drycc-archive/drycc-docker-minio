#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/drycc/scripts/liblog.sh

print_welcome_page

info "** Starting MinIO Client setup **"
/opt/drycc/scripts/minio-client/setup.sh
info "** MinIO Client setup finished! **"

echo ""
exec "/opt/drycc/scripts/minio-client/run.sh" "$@"
