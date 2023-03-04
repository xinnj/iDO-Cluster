#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

CONTAINER_MIRROR="${CONTAINER_MIRROR:-true}"

# ceph-filesystem, nfs-client
STORAGE_CLASS="ceph-filesystem"
SONAR_STORAGE_SIZE="5Gi"
SONAR_PG_STORAGE_SIZE="20Gi"

# A trailing "/" must be included
SONAR_URL_PREFIX="/sonarqube"

# Create namespaces
kubectl create ns sonar || :

# Create PVC
perl -0777 -p -i \
    -e "s/<STORAGE_CLASS>/${STORAGE_CLASS}/g;" \
    -e "s/<SONAR_STORAGE_SIZE>/${SONAR_STORAGE_SIZE}/g;" \
    -e "s/<SONAR_PG_STORAGE_SIZE>/${SONAR_PG_STORAGE_SIZE}/g" \
    "${base}"/pvc.yaml
kubectl apply -f "${base}"/pvc.yaml

# Install Sonarqube
if [ "${CONTAINER_MIRROR}" == "true" ]; then
    perl -0777 -p -i \
        -e "s/docker\.io/docker.m.daocloud.io/g" \
        "${base}"/values-override.yaml
fi

perl -0777 -p -i \
    -e "s#<SONAR_URL_PREFIX>#${SONAR_URL_PREFIX}#g" \
    "${base}"/values-override.yaml
helm upgrade sonarqube --install --create-namespace --namespace sonar -f "${base}"/values-override.yaml "${base}"/sonarqube-chart