#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

echo "### Install Prometheus Stack ###"

# Install prometheus
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
helm upgrade prometheus --install --create-namespace --namespace monitoring -f "${base}"/values.yaml "${base}"/kube-prometheus-stack