#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "### Install File Server ###"
echo "CLUSTER_URL=${CLUSTER_URL}"
echo "TEAM=${TEAM}"
echo "DOCKER_CONTAINER_MIRROR=${DOCKER_CONTAINER_MIRROR}"
echo "TIMEZONE=${TIMEZONE}"
echo "STORAGE_CLASS=${STORAGE_CLASS}"
echo "FILE_STORAGE_SIZE=${FILE_STORAGE_SIZE}"

if [ "${TEAM}" == "default" ]; then
  TEAM_URL="${CLUSTER_URL}"
else
  TEAM_URL="${CLUSTER_URL}/${TEAM}"
fi
FILE_URL="${TEAM_URL}/download"
FILE_URL_PREFIX="/${FILE_URL#*://*/}" && [[ "/${FILE_URL}" == "${FILE_URL_PREFIX}" ]] && FILE_URL_PREFIX="/"

# Create namespaces
kubectl create ns ${TEAM} || :

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install file-server
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade file-server --install --create-namespace --namespace ${TEAM} -f "${base}"/values.yaml "${base}"/file-server-chart