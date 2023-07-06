#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "### Install Nexus ###"
echo "TEAM=${TEAM}"
echo "STORAGE_CLASS=${STORAGE_CLASS}"
echo "NEXUS_STORAGE_SIZE=${NEXUS_STORAGE_SIZE}"
echo "DOCKER_NODE_PORT=${DOCKER_NODE_PORT}"
echo "DOCKER_CONTAINER_MIRROR=${DOCKER_CONTAINER_MIRROR}"

if [ "${TEAM}" == "default" ]; then
  TEAM_URL="${CLUSTER_URL}"
else
  TEAM_URL="${CLUSTER_URL}/${TEAM}"
fi
NEXUS_URL="${TEAM_URL}/nexus"
NEXUS_URL_PATH="${NEXUS_URL#*://*/}" && [[ "${NEXUS_URL}" == "${NEXUS_URL_PATH}" ]] && NEXUS_URL_PATH=""

# Create namespaces
kubectl create ns ${TEAM} || :

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install nexus
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade nexus --install --create-namespace --namespace ${TEAM} -f "${base}"/values.yaml "${base}"/nexus-repository-manager-chart