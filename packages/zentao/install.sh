#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Zentao ###"
echo "IDO_CLUSTER_URL=${IDO_CLUSTER_URL}"
echo "IDO_TEAM=${IDO_TEAM}"
echo "IDO_STORAGE_CLASS=${IDO_STORAGE_CLASS}"
echo "IDO_ZENTAO_STORAGE_SIZE=${IDO_ZENTAO_STORAGE_SIZE}"
echo "IDO_ZENTAO_DB_STORAGE_SIZE=${IDO_ZENTAO_DB_STORAGE_SIZE}"

if [ "${IDO_TEAM}" == "default" ]; then
  TEAM_URL="${IDO_CLUSTER_URL}"
else
  TEAM_URL="${IDO_CLUSTER_URL}/${IDO_TEAM}"
fi
ZENTAO_URL="${TEAM_URL}/zentao"
ZENTAO_URL_PREFIX="/${ZENTAO_URL#*://*/}" && [[ "/${ZENTAO_URL}" == "${ZENTAO_URL_PREFIX}" ]] && ZENTAO_URL_PREFIX="/"

DOMAIN=$(echo "${ZENTAO_URL}" | awk -F/ '{print $3}')

if [ "${IDO_TLS_HOST}" == "" ]; then
  TLS_ENABLED=false
else
  TLS_ENABLED=true
fi

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install
envsubst '${ZENTAO_URL_PREFIX}, ${DOMAIN}, ${IDO_FORCE_SSL_REDIRECT}, ${IDO_TLS_ACME}, ${IDO_INGRESS_HOSTNAME}, ${TLS_ENABLED}, ${IDO_TLS_SECRET}, ${IDO_TLS_HOST}' < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade zentao --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/zentao-chart
