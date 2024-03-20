#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Prometheus Stack ###"

# Install prometheus
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade prometheus --install --create-namespace --namespace monitoring --timeout 30m -f "${base}"/values.yaml "${base}"/kube-prometheus-stack