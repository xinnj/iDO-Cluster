#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install NFS Provisioner ###"
echo "NFS_SERVER=${NFS_SERVER}"
echo "NFS_PATH=${NFS_PATH}"
echo "GCR_CONTAINER_MIRROR=${GCR_CONTAINER_MIRROR}"

# Install nfs provisioner
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade nfs-subdir-external-provisioner --install --create-namespace --namespace nfs-provisioner -f "${base}"/values.yaml "${base}"/nfs-subdir-external-provisioner-chart
