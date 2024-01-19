#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install File Server ###"
echo "IDO_CLUSTER_URL=${IDO_CLUSTER_URL}"
echo "IDO_TEAM=${IDO_TEAM}"
echo "IDO_DOCKER_CONTAINER_MIRROR=${IDO_DOCKER_CONTAINER_MIRROR}"
echo "IDO_TIMEZONE=${IDO_TIMEZONE}"
echo "IDO_STORAGE_CLASS=${IDO_STORAGE_CLASS}"
echo "IDO_FILE_STORAGE_SIZE=${IDO_FILE_STORAGE_SIZE}"

echo "IDO_FILE_URL=${IDO_FILE_URL}"
FILE_URL_PREFIX="/${IDO_FILE_URL#*://*/}" && [[ "/${IDO_FILE_URL}" == "${FILE_URL_PREFIX}" ]] && FILE_URL_PREFIX="/"
echo "FILE_URL_PREFIX=${FILE_URL_PREFIX}"

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install file-server
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade file-server --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/file-server-chart