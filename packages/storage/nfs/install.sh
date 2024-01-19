#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install NFS Provisioner ###"
echo "IDO_NFS_SERVER=${IDO_NFS_SERVER}"
echo "IDO_NFS_PATH=${IDO_NFS_PATH}"
echo "IDO_GCR_CONTAINER_MIRROR=${IDO_GCR_CONTAINER_MIRROR}"

# Install nfs provisioner
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade nfs-subdir-external-provisioner --install --create-namespace --namespace nfs-provisioner -f "${base}"/values.yaml "${base}"/nfs-subdir-external-provisioner-chart
