#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Keycloak ###"

KEYCLOAK_URL="${TEAM_URL}/auth"
KEYCLOAK_URL_PATH="${KEYCLOAK_URL#*://*/}" && [[ "${KEYCLOAK_URL}" == "${KEYCLOAK_URL_PATH}" ]] && KEYCLOAK_URL_PATH=""

if [ "${IDO_TLS_KEY}" == "tls" ]; then
  TLS_ENABLED=true
else
  TLS_ENABLED=false
fi
echo "IDO_TEAM=${IDO_TEAM}"
echo "IDO_STORAGE_CLASS=${IDO_STORAGE_CLASS}"
echo "IDO_KEYCLOAK_PG_STORAGE_SIZE=${IDO_KEYCLOAK_PG_STORAGE_SIZE}"
echo "IDO_DOCKER_CONTAINER_MIRROR=${IDO_DOCKER_CONTAINER_MIRROR}"
echo "KEYCLOAK_URL_PATH=${KEYCLOAK_URL_PATH}"
echo "IDO_INGRESS_HOSTNAME=${IDO_INGRESS_HOSTNAME}"
echo "TLS_ENABLED=${TLS_ENABLED}"
echo "IDO_FORCE_SSL_REDIRECT=${IDO_FORCE_SSL_REDIRECT}"
echo "IDO_TLS_ACME=${IDO_TLS_ACME}"
echo "IDO_ENABLE_PROMETHEUS=${IDO_ENABLE_PROMETHEUS}"

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install nexus
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade keycloak --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/keycloak-chart