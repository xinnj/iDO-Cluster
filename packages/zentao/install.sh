#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Zentao ###"
echo "CLUSTER_URL=${CLUSTER_URL}"
echo "TEAM=${TEAM}"
echo "STORAGE_CLASS=${STORAGE_CLASS}"
echo "ZENTAO_STORAGE_SIZE=${ZENTAO_STORAGE_SIZE}"
echo "ZENTAO_DB_STORAGE_SIZE=${ZENTAO_DB_STORAGE_SIZE}"

if [ "${TEAM}" == "default" ]; then
  TEAM_URL="${CLUSTER_URL}"
else
  TEAM_URL="${CLUSTER_URL}/${TEAM}"
fi
ZENTAO_URL="${TEAM_URL}/pm"
ZENTAO_URL_PREFIX="/${ZENTAO_URL#*://*/}" && [[ "/${ZENTAO_URL}" == "${ZENTAO_URL_PREFIX}" ]] && ZENTAO_URL_PREFIX="/"

DOMAIN=$(echo "${ZENTAO_URL}" | awk -F/ '{print $3}')

if [ "${TLS_HOST}" == "" ]; then
  TLS_ENABLED=false
else
  TLS_ENABLED=true
fi

# Create namespaces
kubectl create ns ${TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install
envsubst '${ZENTAO_URL_PREFIX}, ${DOMAIN}, ${FORCE_SSL_REDIRECT}, ${TLS_ACME}, ${CLUSTER_HOSTNAME}, ${TLS_ENABLED}, ${TLS_SECRET}, ${TLS_HOST}' < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade zentao --install --create-namespace --namespace ${TEAM} -f "${base}"/values.yaml "${base}"/zentao-chart
