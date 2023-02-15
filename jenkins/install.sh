#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

# Create PVC
# Todo: storageClassName, storage size
kubectl apply -f "${base}"/pvc.yaml

# Install Jenkins
# Todo: set timezone
# Todo: set url
# Todo: set update center
helm upgrade jenkins --install -f "${base}"/values-override.yaml "${base}"/jenkins-chart