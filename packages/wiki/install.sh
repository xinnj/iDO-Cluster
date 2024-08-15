#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Xwiki ###"

IDO_XWIKI_URL="${IDO_TEAM_URL}/wiki"
IDO_XWIKI_CONTEXT_PATH="${IDO_XWIKI_URL#*://*/}" && [[ "${IDO_XWIKI_URL}" == "${IDO_XWIKI_CONTEXT_PATH}" ]] && IDO_XWIKI_CONTEXT_PATH=""

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
"${base}/../check-undefined-env.sh" "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install
envsubst '${IDO_DOCKER_CONTAINER_MIRROR}, ${IDO_XWIKI_CONTEXT_PATH}, ${IDO_FORCE_SSL_REDIRECT}, ${IDO_TLS_ACME}, ${IDO_INGRESS_HOSTNAME}, ${IDO_TLS_KEY}, ${IDO_TLS_SECRET}, ${IDO_TLS_HOST}, ${IDO_TIMEZONE}, ' < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade xwiki --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/xwiki
