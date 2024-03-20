#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Cert-manager ###"

envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade cert-manager --install --create-namespace --namespace cert-manager --wait --timeout 30m -f "${base}"/values.yaml "${base}"/cert-manager-chart

envsubst < "${base}/cluster-issuer-template.yaml" > "${base}/cluster-issuer.yaml"
"${base}/../check-undefined-env.sh" "${base}/cluster-issuer.yaml"
kubectl apply -f "${base}/cluster-issuer.yaml"