#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "### Install Jenkins ###"
echo "CLUSTER_URL=${CLUSTER_URL}"
echo "TEAM=${TEAM}"
echo "DOCKER_CONTAINER_MIRROR=${DOCKER_CONTAINER_MIRROR}"
echo "TIMEZONE=${TIMEZONE}"
echo "STORAGE_CLASS=${STORAGE_CLASS}"
echo "CONTROLLER_STORAGE_SIZE=${CONTROLLER_STORAGE_SIZE}"
echo "AGENT_STORAGE_SIZE=${AGENT_STORAGE_SIZE}"
echo "ENABLE_PROMETHEUS=${ENABLE_PROMETHEUS}"

if [ "${TEAM}" == "default" ]; then
  TEAM_URL="${CLUSTER_URL}"
else
  TEAM_URL="${CLUSTER_URL}/${TEAM}"
fi
JENKINS_URL="${TEAM_URL}/jenkins"
JENKINS_URL_PREFIX="/${JENKINS_URL#*://*/}" && [[ "/${JENKINS_URL}" == "${JENKINS_URL_PREFIX}" ]] && JENKINS_URL_PREFIX="/"
UPDATE_CENTER="https://updates.jenkins.io/update-center.json"

# Create namespaces
kubectl create ns ${TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install Jenkins
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade jenkins --install --create-namespace --namespace ${TEAM} -f "${base}"/values.yaml "${base}"/jenkins-chart
