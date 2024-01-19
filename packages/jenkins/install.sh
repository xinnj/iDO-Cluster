#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Jenkins ###"
echo "IDO_CLUSTER_URL=${IDO_CLUSTER_URL}"
echo "IDO_TEAM=${IDO_TEAM}"
echo "IDO_DOCKER_CONTAINER_MIRROR=${IDO_DOCKER_CONTAINER_MIRROR}"
echo "IDO_TIMEZONE=${IDO_TIMEZONE}"
echo "IDO_STORAGE_CLASS=${IDO_STORAGE_CLASS}"
echo "IDO_JENKINS_CONTROLLER_STORAGE_SIZE=${IDO_JENKINS_CONTROLLER_STORAGE_SIZE}"
echo "IDO_JENKINS_AGENT_STORAGE_SIZE=${IDO_JENKINS_AGENT_STORAGE_SIZE}"
echo "IDO_ENABLE_PROMETHEUS=${IDO_ENABLE_PROMETHEUS}"

if [ "${IDO_TEAM}" == "default" ]; then
  TEAM_URL="${IDO_CLUSTER_URL}"
else
  TEAM_URL="${IDO_CLUSTER_URL}/${IDO_TEAM}"
fi
JENKINS_URL="${TEAM_URL}/jenkins"
JENKINS_URL_PREFIX="/${JENKINS_URL#*://*/}" && [[ "/${JENKINS_URL}" == "${JENKINS_URL_PREFIX}" ]] && JENKINS_URL_PREFIX="/"
UPDATE_CENTER="https://updates.jenkins.io/update-center.json"

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install Jenkins
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade jenkins --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/jenkins-chart
