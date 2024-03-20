#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Sonarqube ###"

IDO_SONAR_URL="${IDO_TEAM_URL}/sonarqube"
IDO_SONAR_URL_PREFIX="/${IDO_SONAR_URL#*://*/}" && [[ "/${IDO_SONAR_URL}" == "${IDO_SONAR_URL_PREFIX}" ]] && IDO_SONAR_URL_PREFIX="/"

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
"${base}/../check-undefined-env.sh" "${base}/pvc.yaml"
kubectl apply -f "${base}"/pvc.yaml

# Install Sonarqube
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade sonarqube --install --create-namespace --namespace ${IDO_TEAM} --timeout 30m -f "${base}"/values.yaml "${base}"/sonarqube-chart