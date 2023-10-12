#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

echo "### Install Samba Server ###"
echo "CLUSTER_URL=${CLUSTER_URL}"
echo "TEAM=${TEAM}"
echo "DOCKER_CONTAINER_MIRROR=${DOCKER_CONTAINER_MIRROR}"
echo "TIMEZONE=${TIMEZONE}"
echo "SMB_NODE_PORT=${SMB_NODE_PORT}"

# Install samba-server
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade samba-server --install --create-namespace --namespace ${TEAM} -f "${base}"/values.yaml "${base}"/samba-server-chart