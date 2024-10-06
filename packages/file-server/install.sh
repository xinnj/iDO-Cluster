#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install File Server ###"

if [ "${IDO_TEAM}" == "default" ];then
  IDO_FILE_URL_PREFIX=""
else
  IDO_FILE_URL_PREFIX="${IDO_TEAM}/"

fi

# Create namespaces
kubectl create ns ${IDO_TEAM} --dry-run=client -o yaml | kubectl apply -f -

# Create PVC
envsubst < "${base}/pvc-template.yaml" > "${base}/pvc.yaml"
"${base}/../check-undefined-env.sh" "${base}/pvc.yaml"
kubectl apply -f "${base}/pvc.yaml"

# Install file-server
envsubst < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade file-server --install --create-namespace --namespace ${IDO_TEAM} -f "${base}"/values.yaml "${base}"/file-server-chart