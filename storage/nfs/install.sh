#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

CONTAINER_MIRROR="${CONTAINER_MIRROR:-true}"
NFS_SERVER="my-nfs-server"
NFS_PATH="/home/nfsshare"

# Install nfs provisioner
if [ "${CONTAINER_MIRROR}" == "true" ]; then
    perl -0777 -p -i \
        -e "s/k8s\.gcr\.io/k8s-gcr.m.daocloud.io/g" \
        "${base}"/values-override.yaml
fi

perl -0777 -p -i \
    -e "s#server:.*#server: ${NFS_SERVER}#g;" \
    -e "s#path:.*#path: ${NFS_PATH}#g" \
    "${base}"/values-override.yaml

helm upgrade nfs-subdir-external-provisioner --install --create-namespace --namespace nfs-provisioner -f "${base}"/values-override.yaml "${base}"/nfs-subdir-external-provisioner-chart
