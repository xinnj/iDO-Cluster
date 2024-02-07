#! /bin/bash
set -euao pipefail

echo "##########################################################################"
echo "### Populate Configuration ###"

export -p | awk '{print $3'} | grep "^IDO" | tr -d '"' > packages_env_new.txt

kubectl get cm packages-env --ignore-not-found=true -o jsonpath="{.data}" | jq -r 'to_entries[] | .key + "=" + .value' > packages_env_exist.txt
declare -A packages_env_exist
while IFS='=' read -r k v; do
  packages_env_exist[$k]=$v
done < packages_env_exist.txt

declare -A packages_env_new
while IFS='=' read -r k v; do
  packages_env_new[$k]=$v
done < packages_env_new.txt

for k in "${!packages_env_new[@]}"; do
  packages_env_exist[$k]="${packages_env_new[$k]}"
done

rm -f packages_env_all.txt
for k in "${!packages_env_exist[@]}"; do
  echo "$k=${packages_env_exist[$k]}" >> packages_env_all.txt
done

kubectl delete -n ${IDO_TEAM} cm packages-env --ignore-not-found=true
kubectl create -n ${IDO_TEAM} cm packages-env --from-env-file=./packages_env_all.txt
