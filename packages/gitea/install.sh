#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Gitea ###"

if [ "${IDO_TEAM}" == "default" ]; then
  TEAM_URL="${IDO_CLUSTER_URL}"
else
  TEAM_URL="${IDO_CLUSTER_URL}/${IDO_TEAM}"
fi
GITEA_URL="${TEAM_URL}/git"
GITEA_URL_PREFIX="/${GITEA_URL#*://*/}" && [[ "/${GITEA_URL}" == "${GITEA_URL_PREFIX}" ]] && GITEA_URL_PREFIX="/"

DOMAIN=$(echo "${GITEA_URL}" | awk -F/ '{print $3}')

echo "GITEA_URL=${GITEA_URL}"
echo "GITEA_URL_PREFIX=${GITEA_URL_PREFIX}"
echo "IDO_STORAGE_CLASS=${IDO_STORAGE_CLASS}"
echo "IDO_GITEA_SSH_NODE_PORT=${IDO_GITEA_SSH_NODE_PORT}"
echo "IDO_GITEA_SHARED_STORAGE_SIZE=${IDO_GITEA_SHARED_STORAGE_SIZE}"
echo "DOMAIN=${DOMAIN}"
echo "IDO_GITEA_PG_STORAGE_SIZE=${IDO_GITEA_PG_STORAGE_SIZE}"

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Install gitlab
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade gitea --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/gitea-chart