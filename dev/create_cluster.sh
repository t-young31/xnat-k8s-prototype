#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cluster_name="xnat"
kubeconfig_path="${SCRIPT_DIR}/../${DEV_KUBECONFIG}"

function cluster_exists(){
    k3d cluster list | grep -q "$cluster_name"
}

function create_cluster(){
  echo "Creating cluster [${cluster_name}]"
  k3d cluster create "$cluster_name" \
    --api-port 6550 \
    --servers 1 \
    --agents 1 \
    --port "${DEV_CLUSTER_LOAD_BALANCER_PORT}:443@loadbalancer" \
    --wait
}

function write_kube_config() {
  echo "Writing kube configuration file"
  k3d kubeconfig get "$cluster_name" > "$kubeconfig_path"
  chmod 600 "$kubeconfig_path"
  echo "$kubeconfig_path created. Run: export KUBECONFIG=${kubeconfig_path}"
}

if ! cluster_exists; then
  create_cluster
  write_kube_config
else
  echo "Cluster [${cluster_name}] exists"
fi
