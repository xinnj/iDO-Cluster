#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Nexus ###"

IDO_NEXUS_URL="${IDO_TEAM_URL}/nexus"
IDO_NEXUS_URL_PATH="${IDO_NEXUS_URL#*://*/}" && [[ "${IDO_NEXUS_URL}" == "${IDO_NEXUS_URL_PATH}" ]] && IDO_NEXUS_URL_PATH=""

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
"${base}/../check-undefined-env.sh" "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install nexus
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade nexus --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/nexus-repository-manager-chart