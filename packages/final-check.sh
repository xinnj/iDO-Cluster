#! /bin/bash
set -euao pipefail

not_ready_pod_list() {
  pod_list=""
  for p in $(kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded -o=jsonpath="{range .items[*]}{.metadata.name}{';'}{.metadata.ownerReferences[?(@.kind != 'Job')].name}{'\n'}{end}"); do
    v_owner_name=$(echo $p | cut -d';' -f2)
    if [ ! -z "$v_owner_name" ]; then
      v_pod_name=$(echo $p | cut -d';' -f1)
      pod_list="$pod_list $v_pod_name"
    fi
  done
  echo $pod_list
}

kubectl delete pod --all -n ingress-nginx >/dev/null

echo "##########################################################################"

result=$(not_ready_pod_list)
if [ "${result}" != "" ]; then
  echo "Please wait for these pods to be ready..."
  kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded -o=custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount,OWNER-KIND:.metadata.ownerReferences[*].kind'|grep -v 'Job'|grep -v 'Challenge'
fi

while [ "$result" != "" ]; do
  sleep 10

  new_result=$(not_ready_pod_list)
  if [ "${new_result}" != "" ]; then
    if [ "${new_result}" != "${result}" ]; then
      echo "##########################################################################"
      echo "Please wait for these pods to be ready..."
      kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded -o=custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount,OWNER-KIND:.metadata.ownerReferences[*].kind'|grep -v 'Job'|grep -v 'Challenge'
    fi
  fi
  result=${new_result}
done

helm list -n ${IDO_TEAM} --no-headers=true | awk '{print $1'} > packages.txt
kubectl delete -n ${IDO_TEAM} cm packages-installed --ignore-not-found=true
kubectl create -n ${IDO_TEAM} cm packages-installed --from-file=packages=./packages.txt

echo "Done!"