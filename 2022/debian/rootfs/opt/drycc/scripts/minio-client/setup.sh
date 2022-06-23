#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/drycc/scripts/liblog.sh
. /opt/drycc/scripts/libnet.sh
. /opt/drycc/scripts/libminioclient.sh

# Load MinIO Client environment
. /opt/drycc/scripts/minio-client-env.sh

# Configure MinIO Client to use a MinIO server
minio_client_configure_server
