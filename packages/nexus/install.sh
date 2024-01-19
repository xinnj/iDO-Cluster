#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Nexus ###"
echo "IDO_TEAM=${IDO_TEAM}"
echo "IDO_STORAGE_CLASS=${IDO_STORAGE_CLASS}"
echo "IDO_NEXUS_STORAGE_SIZE=${IDO_NEXUS_STORAGE_SIZE}"
echo "IDO_NEXUS_DOCKER_NODE_PORT=${IDO_NEXUS_DOCKER_NODE_PORT}"
echo "IDO_DOCKER_CONTAINER_MIRROR=${IDO_DOCKER_CONTAINER_MIRROR}"

if [ "${IDO_TEAM}" == "default" ]; then
  TEAM_URL="${IDO_CLUSTER_URL}"
else
  TEAM_URL="${IDO_CLUSTER_URL}/${IDO_TEAM}"
fi
NEXUS_URL="${TEAM_URL}/nexus"
NEXUS_URL_PATH="${NEXUS_URL#*://*/}" && [[ "${NEXUS_URL}" == "${NEXUS_URL_PATH}" ]] && NEXUS_URL_PATH=""

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install nexus
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade nexus --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/nexus-repository-manager-chart