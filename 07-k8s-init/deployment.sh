#!/bin/bash
set -euo pipefail

source "${PWD}/config.ini"
source "color.sh"

# Normalize variable names (accept either CLUSTER_NAME / cluster_name and ZONE / zone)
CLUSTER_NAME=${CLUSTER_NAME:-${cluster_name:-}}
ZONE=${ZONE:-${zone:-}}

if [ -z "$CLUSTER_NAME" ] || [ -z "$ZONE" ]; then
  echo "$(tput setaf 1)Error: CLUSTER_NAME and ZONE must be set in config.ini (as CLUSTER_NAME/cluster_name and ZONE/zone)$(tput sgr0)"
  exit 1
fi

set_compute_zone() {
  echo "$(green_text "[+] Setting the compute zone:") $ZONE ..."
  gcloud config set compute/zone "$ZONE"
}

create_cluster() {
  echo "$(green_text "[+] Creating GKE cluster:") $CLUSTER_NAME ..."
  gcloud container clusters create "$CLUSTER_NAME" \
    --zone "$ZONE" \
    --enable-master-authorized-networks \
    --enable-ip-alias \
    --machine-type=e2-small \
    --num-nodes=1 \
    --disk-size 20 \
    --master-authorized-networks "$(curl -s ifconfig.me)/32"
}

create_and_expose_deployment() {
  echo "$(green_text "[+] Creating and exposing deployment using YAML manifests") ..."
  gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$ZONE"

  cat > deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-server
  template:
    metadata:
      labels:
        app: hello-server
    spec:
      containers:
      - name: hello-app
        image: nginx:stable-alpine
        ports:
        - containerPort: 80
EOF

  cat > service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: hello-server
spec:
  type: LoadBalancer
  selector:
    app: hello-server
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

  kubectl apply -f deployment.yaml
  kubectl apply -f service.yaml

  echo "$(green_text "[+] Waiting for deployment rollout to finish...")"
  kubectl rollout status deployment/hello-server

  echo "$(green_text "[+] Deployment finished successfully! 🥳")"
  echo "Check service external IP with: kubectl get svc hello-server -o wide"
}

# Execution
set_compute_zone
create_cluster
create_and_expose_deployment






