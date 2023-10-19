#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Sonarqube ###"
echo "CLUSTER_URL=${CLUSTER_URL}"
echo "TEAM=${TEAM}"
echo "DOCKER_CONTAINER_MIRROR=${DOCKER_CONTAINER_MIRROR}"
echo "STORAGE_CLASS=${STORAGE_CLASS}"
echo "SONAR_STORAGE_SIZE=${SONAR_STORAGE_SIZE}"
echo "SONAR_PG_STORAGE_SIZE=${SONAR_PG_STORAGE_SIZE}"

if [ "${TEAM}" == "default" ]; then
  TEAM_URL="${CLUSTER_URL}"
else
  TEAM_URL="${CLUSTER_URL}/${TEAM}"
fi
SONAR_URL="${TEAM_URL}/sonarqube"
SONAR_URL_PREFIX="/${SONAR_URL#*://*/}" && [[ "/${SONAR_URL}" == "${SONAR_URL_PREFIX}" ]] && SONAR_URL_PREFIX="/"

# Create namespaces
kubectl create ns ${TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
kubectl apply -f "${base}"/pvc.yaml

# Install Sonarqube
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade sonarqube --install --create-namespace --namespace ${TEAM} -f "${base}"/values.yaml "${base}"/sonarqube-chart