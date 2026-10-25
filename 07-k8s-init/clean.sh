#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"

delete_k8s_resources() {
  echo "$(red_text "[-] Deleting k8s resources (and the load balancer)") ..."
  kubectl delete -f k8s/ --ignore-not-found
}

delete_cluster() {
  echo "$(red_text "[-] Deleting cluster") $cluster_name ..."
  gcloud container clusters delete $cluster_name --zone $zone --quiet
}

delete_registry() {
  echo "$(red_text "[-] Deleting Artifact Registry repository") asr-registry ..."
  gcloud artifacts repositories delete asr-registry --location=europe-southwest1 --quiet
  echo "$(red_text "[-] All the resources were deleted succesfully! 🍰 🍰 🍰")"
}

delete_k8s_resources
delete_cluster
delete_registry
