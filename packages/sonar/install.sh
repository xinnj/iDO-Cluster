#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Sonarqube ###"
echo "IDO_CLUSTER_URL=${IDO_CLUSTER_URL}"
echo "IDO_TEAM=${IDO_TEAM}"
echo "IDO_DOCKER_CONTAINER_MIRROR=${IDO_DOCKER_CONTAINER_MIRROR}"
echo "IDO_STORAGE_CLASS=${IDO_STORAGE_CLASS}"
echo "IDO_SONAR_STORAGE_SIZE=${IDO_SONAR_STORAGE_SIZE}"
echo "IDO_SONAR_PG_STORAGE_SIZE=${IDO_SONAR_PG_STORAGE_SIZE}"

if [ "${IDO_TEAM}" == "default" ]; then
  TEAM_URL="${IDO_CLUSTER_URL}"
else
  TEAM_URL="${IDO_CLUSTER_URL}/${IDO_TEAM}"
fi
SONAR_URL="${TEAM_URL}/sonarqube"
SONAR_URL_PREFIX="/${SONAR_URL#*://*/}" && [[ "/${SONAR_URL}" == "${SONAR_URL_PREFIX}" ]] && SONAR_URL_PREFIX="/"

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}"/pvc.yaml

# Install Sonarqube
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade sonarqube --install --create-namespace --namespace ${IDO_TEAM} --wait --timeout 30m -f "${base}"/values.yaml "${base}"/sonarqube-chart