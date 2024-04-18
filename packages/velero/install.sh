#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Velero ###"

# Install velero
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade velero --install --create-namespace --namespace velero -f "${base}"/values.yaml "${base}"/velero-chart