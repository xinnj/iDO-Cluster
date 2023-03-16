#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

CONTAINER_MIRROR="${CONTAINER_MIRROR:-true}"

# ceph-filesystem, nfs-client
STORAGE_CLASS="ceph-filesystem"
STORAGE_SIZE="200Gi"

# Create namespaces
kubectl create ns nexus || :

# Create PVC
perl -0777 -p -i \
    -e "s/<STORAGE_CLASS>/${STORAGE_CLASS}/g;" \
    -e "s/<STORAGE_SIZE>/${STORAGE_SIZE}/g" \
    "${base}"/pvc.yaml
kubectl apply -f "${base}"/pvc.yaml

# Install nexus
if [ "${CONTAINER_MIRROR}" == "true" ]; then
    perl -0777 -p -i \
        -e "s/docker\.io/docker.m.daocloud.io/g" \
        "${base}"/values-override.yaml
fi

helm upgrade nexus --install --create-namespace --namespace nexus -f "${base}"/values-override.yaml "${base}"/nexus-repository-manager-chart