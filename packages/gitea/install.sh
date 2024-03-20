#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Gitea ###"

IDO_GITEA_URL="${IDO_TEAM_URL}/git"
IDO_GITEA_URL_PREFIX="/${IDO_GITEA_URL#*://*/}" && [[ "/${IDO_GITEA_URL}" == "${IDO_GITEA_URL_PREFIX}" ]] && IDO_GITEA_URL_PREFIX="/"

IDO_GITEA_DOMAIN=$(echo "${IDO_GITEA_URL}" | awk -F/ '{print $3}')

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Install gitlab
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade gitea --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/gitea-chart