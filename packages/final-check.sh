#! /bin/bash
set -euao pipefail

kubectl delete pod --all -n ingress-nginx >/dev/null

echo "##########################################################################"

result=$(kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded -o custom-columns=Name:.metadata.name --no-headers=true -A)
if [ "${result}" != "" ]; then
  echo "Please wait for these pods to be ready..."
  kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded -A
fi

while [ "$result" != "" ]; do
  sleep 10

  new_result=$(kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded -o custom-columns=Name:.metadata.name --no-headers=true -A)
  if [ "${new_result}" != "" ]; then
    if [ "${new_result}" != "${result}" ]; then
      echo "##########################################################################"
      echo "Please wait for these pods to be ready..."
      kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded -A
    fi
  fi
  result=${new_result}
done

helm list --no-headers=true | awk '{print $1'} > packages.txt
kubectl delete -n ${IDO_TEAM} cm packages-installed --ignore-not-found=true
kubectl create -n ${IDO_TEAM} cm packages-installed --from-file=packages=./packages.txt

echo "Done!"