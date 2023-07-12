#! /bin/bash
set -euao pipefail
base=$(dirname "$0")

echo "### Install Ceph ###"
echo "DOCKER_CONTAINER_MIRROR=${DOCKER_CONTAINER_MIRROR}"
echo "QUAY_CONTAINER_MIRROR=${QUAY_CONTAINER_MIRROR}"
echo "K8S_CONTAINER_MIRROR=${K8S_CONTAINER_MIRROR}"

node_num=$(kubectl get node --no-headers|wc -l)
if (( node_num >= 3 )); then
    install_mode="ha"
else
    install_mode="single"
fi
echo "Install ceph as $install_mode mode..."

# Install rook-ceph operator
envsubst < "${base}/values-rook-ceph-${install_mode}-template.yaml" > "${base}/values-rook-ceph-${install_mode}.yaml"
helm upgrade rook-ceph --install --create-namespace --namespace rook-ceph --wait --wait-for-jobs --timeout 10m -f "${base}/values-rook-ceph-${install_mode}.yaml" "${base}/rook-ceph-chart"

# Install ceph cluster
envsubst < "${base}/values-rook-ceph-cluster-${install_mode}-template.yaml" > "${base}/values-rook-ceph-cluster-${install_mode}.yaml"
helm upgrade rook-ceph-cluster --install --create-namespace --namespace rook-ceph -f "${base}/values-rook-ceph-cluster-${install_mode}.yaml" "${base}/rook-ceph-cluster-chart"

health=''
while [ "$health" != "HEALTH_OK" ]; do
    echo Wait the ceph cluster is ready...
    sleep 5
    health=$(kubectl --namespace rook-ceph get cephcluster -o custom-columns=HEALTH:.status.ceph.health --no-headers=true)
    kubectl --namespace rook-ceph get cephcluster
done
