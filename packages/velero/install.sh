#! /bin/bash
set -euao pipefail

base=$(dirname "$0")

echo "##########################################################################"
echo "### Install Velero ###"

# Install velero
envsubst '${IDO_ENABLE_PROMETHEUS}, ${IDO_BACKUP_PROVIDER}, ${IDO_BACKUP_BUCKET}, ${IDO_BACKUP_LOCATION_CONFIG}, ${IDO_BACKUP_REGION}, ${IDO_TIMEZONE}, ${IDO_BACKUP_CLOUD_SECRET}, ${IDO_TEAM}, ${IDO_BACKUP_SCHEDULE}, ${IDO_BACKUP_TTL}, ${IDO_BACKUP_SELECTORS}' < "${base}/values-override.yaml" > "${base}/values.yaml"
"${base}/../check-undefined-env.sh" "${base}/values.yaml"
helm upgrade velero --install --create-namespace --namespace velero -f "${base}"/values.yaml "${base}"/velero-chart