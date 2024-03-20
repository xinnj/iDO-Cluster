#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Keycloak ###"

IDO_KEYCLOAK_URL="${IDO_TEAM_URL}/auth"
IDO_KEYCLOAK_URL_PATH="${IDO_KEYCLOAK_URL#*://*/}" && [[ "${IDO_KEYCLOAK_URL}" == "${IDO_KEYCLOAK_URL_PATH}" ]] && IDO_KEYCLOAK_URL_PATH=""

if [ "${IDO_TLS_KEY}" == "tls" ]; then
  IDO_TLS_ENABLED=true
else
  IDO_TLS_ENABLED=false
fi

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
"${base}/../check-undefined-env.sh" "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install nexus
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade keycloak --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/keycloak-chart