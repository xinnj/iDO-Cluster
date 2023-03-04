#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

CONTAINER_MIRROR="${CONTAINER_MIRROR:-true}"

# ceph-filesystem, nfs-client
STORAGE_CLASS="ceph-filesystem"
CONTROLLER_STORAGE_SIZE="20Gi"
AGENT_STORAGE_SIZE="200Gi"

# long name of timezone, refer: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
JENKINS_TIMEZONE="Asia/Shanghai"
JENKINS_URL="http://pipeline.ido-cluster.com/jenkins"
JENKINS_URL_PREFIX="/${JENKINS_URL#*://*/}" && [[ "/${JENKINS_URL}" == "${JENKINS_URL_PREFIX}" ]] && JENKINS_URL_PREFIX="/"
UPDATE_CENTER="https://updates.jenkins.io/update-center.json"

# Create namespaces
kubectl create ns jenkins || :
kubectl create ns builders || :

# Create PVC
perl -0777 -p -i \
    -e "s/<STORAGE_CLASS>/${STORAGE_CLASS}/g;" \
    -e "s/<CONTROLLER_STORAGE_SIZE>/${CONTROLLER_STORAGE_SIZE}/g;" \
    -e "s/<AGENT_STORAGE_SIZE>/${AGENT_STORAGE_SIZE}/g" \
    "${base}"/pvc.yaml
kubectl apply -f "${base}"/pvc.yaml

# Install Jenkins
if [ "${CONTAINER_MIRROR}" == "true" ]; then
    perl -0777 -p -i \
        -e "s/docker\.io/docker.m.daocloud.io/g" \
        "${base}"/values-override.yaml
fi

perl -0777 -p -i \
    -e "s#<JENKINS_TIMEZONE>#${JENKINS_TIMEZONE}#g;" \
    -e "s#<JENKINS_URL>#${JENKINS_URL}#g;" \
    -e "s#<JENKINS_URL_PREFIX>#${JENKINS_URL_PREFIX}#g;" \
    -e "s#<UPDATE_CENTER>#${UPDATE_CENTER}#g" \
    "${base}"/values-override.yaml
helm upgrade jenkins --install --create-namespace --namespace jenkins -f "${base}"/values-override.yaml "${base}"/jenkins-chart