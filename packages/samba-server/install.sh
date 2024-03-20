#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Samba Server ###"

# Install samba-server
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade samba-server --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/samba-server-chart