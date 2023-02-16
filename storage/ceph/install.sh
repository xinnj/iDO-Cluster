#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

CONTAINER_MIRROR="${CONTAINER_MIRROR:-true}"

# Install rook-ceph operator
if [ "${CONTAINER_MIRROR}" == "true" ]; then
    perl -0777 -p -i \
        -e "s/docker\.io/docker.m.daocloud.io/g;" \
        -e "s/quay\.io/quay.m.daocloud.io/g;" \
        -e "s/registry\.k8s\.io/k8s.m.daocloud.io/g" \
        "${base}"/values-rook-ceph.yaml
fi
helm upgrade rook-ceph --install --create-namespace --namespace rook-ceph --wait --wait-for-jobs --timeout 10m -f "${base}"/values-rook-ceph.yaml "${base}"/rook-ceph-chart

# Install ceph cluster
if [ "${CONTAINER_MIRROR}" == "true" ]; then
    perl -0777 -p -i \
        -e "s/docker\.io/docker.m.daocloud.io/g;" \
        -e "s/quay\.io/quay.m.daocloud.io/g;" \
        -e "s/registry\.k8s\.io/k8s.m.daocloud.io/g" \
        "${base}"/values-rook-ceph-cluster.yaml
fi
helm upgrade rook-ceph-cluster --install --create-namespace --namespace rook-ceph -f "${base}"/values-rook-ceph-cluster.yaml "${base}"/rook-ceph-cluster-chart
kubectl --namespace rook-ceph get cephcluster