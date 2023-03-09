#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

CONTAINER_MIRROR="${CONTAINER_MIRROR:-true}"

# ceph-filesystem, nfs-client
STORAGE_CLASS="ceph-filesystem"
STORAGE_SIZE="200Gi"

# long name of timezone, refer: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
TIMEZONE="Asia/Shanghai"

# Create namespaces
kubectl create ns files || :

# Create PVC
perl -0777 -p -i \
    -e "s/<STORAGE_CLASS>/${STORAGE_CLASS}/g;" \
    -e "s/<STORAGE_SIZE>/${STORAGE_SIZE}/g" \
    "${base}"/pvc.yaml
kubectl apply -f "${base}"/pvc.yaml

# Install file-server
if [ "${CONTAINER_MIRROR}" == "true" ]; then
    perl -0777 -p -i \
        -e "s/docker\.io/docker.m.daocloud.io/g" \
        "${base}"/values-override.yaml
fi

perl -0777 -p -i \
    -e "s#<TIMEZONE>#${TIMEZONE}#g" \
    "${base}"/values-override.yaml
helm upgrade file-server --install --create-namespace --namespace files -f "${base}"/values-override.yaml "${base}"/file-server-chart