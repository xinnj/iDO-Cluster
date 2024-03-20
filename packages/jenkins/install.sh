#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Jenkins ###"

IDO_JENKINS_URL="${IDO_TEAM_URL}/jenkins"
IDO_JENKINS_URL_PREFIX="/${IDO_JENKINS_URL#*://*/}" && [[ "/${IDO_JENKINS_URL}" == "${IDO_JENKINS_URL_PREFIX}" ]] && IDO_JENKINS_URL_PREFIX="/"
IDO_JENKINS_UPDATE_CENTER="https://updates.jenkins.io/update-center.json"

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
"${base}/../check-undefined-env.sh" "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install Jenkins
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade jenkins --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/jenkins-chart
