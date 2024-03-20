#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Zentao ###"

IDO_ZENTAO_URL="${IDO_TEAM_URL}/pm"
IDO_ZENTAO_URL_PREFIX="/${IDO_ZENTAO_URL#*://*/}" && [[ "/${IDO_ZENTAO_URL}" == "${IDO_ZENTAO_URL_PREFIX}" ]] && IDO_ZENTAO_URL_PREFIX="/"

IDO_ZENTAO_DOMAIN=$(echo "${IDO_ZENTAO_URL}" | awk -F/ '{print $3}')

if [ "${IDO_TLS_HOST}" == "" ]; then
  IDO_TLS_ENABLED=false
else
  IDO_TLS_ENABLED=true
fi

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
"${base}/../check-undefined-env.sh" "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install
envsubst '${IDO_ZENTAO_URL_PREFIX}, ${IDO_ZENTAO_DOMAIN}, ${IDO_FORCE_SSL_REDIRECT}, ${IDO_TLS_ACME}, ${IDO_INGRESS_HOSTNAME}, ${IDO_TLS_ENABLED}, ${IDO_TLS_SECRET}, ${IDO_TLS_HOST}' < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade zentao --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/zentao-chart
