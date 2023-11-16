#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Gitea ###"

if [ "${TEAM}" == "default" ]; then
  TEAM_URL="${CLUSTER_URL}"
else
  TEAM_URL="${CLUSTER_URL}/${TEAM}"
fi
GITEA_URL="${TEAM_URL}/git/"

DOMAIN=$(echo "${GITEA_URL}" | awk -F/ '{print $3}')

echo "GITEA_URL=${GITEA_URL}"
echo "STORAGE_CLASS=${STORAGE_CLASS}"
echo "SSH_NODE_PORT=${SSH_NODE_PORT}"
echo "GITEA_SHARED_STORAGE_SIZE=${GITEA_SHARED_STORAGE_SIZE}"
echo "DOMAIN=${DOMAIN}"
echo "GITEA_PG_STORAGE_SIZE=${GITEA_PG_STORAGE_SIZE}"

# Create namespaces
kubectl create ns ${TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Install gitlab
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade gitea --install --create-namespace --namespace ${TEAM} -f "${base}"/values.yaml "${base}"/gitea-chart