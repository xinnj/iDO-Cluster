#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Samba Server ###"
echo "IDO_CLUSTER_URL=${IDO_CLUSTER_URL}"
echo "IDO_TEAM=${IDO_TEAM}"
echo "IDO_DOCKER_CONTAINER_MIRROR=${IDO_DOCKER_CONTAINER_MIRROR}"
echo "IDO_TIMEZONE=${IDO_TIMEZONE}"
echo "IDO_SMB_NODE_PORT=${IDO_SMB_NODE_PORT}"

# Install samba-server
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade samba-server --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/samba-server-chart