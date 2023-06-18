#! /bin/bash
set -euaxo pipefail

base=$(dirname "$0")

CONTAINER_MIRROR="${CONTAINER_MIRROR:-true}"

# long name of timezone, refer: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
TIMEZONE="Asia/Shanghai"

NODE_PORT="30445"

# Install samba-server
if [ "${CONTAINER_MIRROR}" == "true" ]; then
    perl -0777 -p -i \
        -e "s/docker\.io/docker.m.daocloud.io/g" \
        "${base}"/values-override.yaml
fi

perl -0777 -p -i \
    -e "s#<TIMEZONE>#${TIMEZONE}#g" \
    -e "s#<NODE_PORT>#${NODE_PORT}#g" \
    "${base}"/values-override.yaml
helm upgrade samba-server --install --create-namespace --namespace jenkins -f "${base}"/values-override.yaml "${base}"/samba-server-chart