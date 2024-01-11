#!/bin/bash

# -> Step 1: Installing the required tools #
# KUBECFG_FILE_NAME=~/.kube/config

# back_up_kube_config(){
#     cp $KUBECFG_FILE_NAME config.backup
# }
# 1- install kubectl

#TODO k3d installieren und cluster erstellen
#TODO Github repo pushen
#TODO Readme how to install
#TODO Local Auf AWS 

# installing k3d
chmod +x k3d/install.sh

if [[ $(command -v k3d) ]]; 
then
    echo "🧉 [k3d] already installed"
    kubectl version
else
    echo "⏳ Installing [k3d] command-line tool. ⏳"
    ./k3d/install.sh
    kubectl version
fi

# Get the list of clusters
clusters=$(kubectl config get-clusters)

# Check if 'main-cluster' is in the list
if echo "$clusters" | grep -q "main-cluster"; then
    echo "main-cluster is installed."
else
    echo "main-cluster is not installed."
    k3d cluster create main-cluster
fi

k3d cluster start main-cluster

if [[ $(command -v kubectl) ]]; 
then
    echo "🧉 [kubectl] already installed"
    kubectl version
else
    echo "⏳ Installing [kubectl] command-line tool. ⏳"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# 2- install vcluster
if [[ $(command -v vcluster) ]]; 
then
    echo "🧉 [vcluster] already installed"
else
    echo "⏳ Installing [vcluster] command-line tool. ⏳"
    curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster
fi

chmod +x rbac-management/kubeconfig-create-rbac.sh
# create vcluster admin, dev and prod

vcluster create v-admin \
    --namespace=administration \
    --connect=false \
     --update-current=false \
    -f config/vcluster/admin-values.yaml

vcluster create v-dev \
    --namespace=development \
    --connect=false \
    -f config/vcluster/dev-values.yaml

vcluster create v-prod \
    --namespace=production \
    --connect=false \
    -f config/vcluster/prod-values.yaml

# RBAC Admin für v-admin cluster
./rbac-management/kubeconfig-create-rbac.sh admin-sa administration config/role-rb-cr-crb/admin-admin-rbac.yaml

# kubectl config use-context $SERVICE_ACCOUNT_NAME-context --kubeconfig=$KUBECONFIG_FILE
# export KUBECONFIG=kube/k8s-admin-sa-administration-kubeconfig.yaml

# RBAC Admin für v-dev cluster
./rbac-management/kubeconfig-create-rbac.sh admin-dev-sa development config/role-rb-cr-crb/admin-dev-rbac.yaml

# RBAC dev für v-dev cluster
./rbac-management/kubeconfig-create-rbac.sh dev-dev-sa development config/role-rb-cr-crb/dev-dev-rbac.yaml

# RBAC dev für v-prod cluster
./rbac-management/kubeconfig-create-rbac.sh dev-prod-sa production config/role-rb-cr-crb/dev-prod-rbac.yaml

# RBAC admin für v-prod cluster
./rbac-management/kubeconfig-create-rbac.sh admin-prod-sa production config/role-rb-cr-crb/admin-prod-rbac.yaml


#vcluster create v-administration -n administration --context admin-sa-administration-k3d-main-cluster --connect false --expose false
#kubectl create ns production
#./sa-kubeconfig-gen.sh prod-admin-sa production /config/prod-admin-rbac-role.yaml
# ./kube/k8s-prod-admin-sa-production-kubeconfig.yaml
#./sa-kubeconfig-gen.sh prod-dev-sa production /config/prod-dev-rbac-role.yaml
# ./kube/k8s-prod-dev-sa-production-kubeconfig.yaml
#kubectl create ns development
#./sa-kubeconfig-gen.sh admin-dev-sa development /config/admin-dev-rbac-role.yaml
# ./kube/k8s-admin-dev-sa-development-kubeconfig.yaml
#./sa-kubeconfig-gen.sh dev-dev-sa development /config/dev-dev-rbac-role.yaml
# ./kube/k8s-dev-dev-sa-development-kubeconfig.yaml

# export KUBECONFIG=~/.kube/config

# Monitoring
vcluster create mv-admin \
    --namespace=monitoring-admin \
    --connect=false \
    -f config/vcluster/admin-values.yaml
# connecting to mv-admin    
vcluster connect mv-admin
# installing metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# Wait until the metrics server has started. You should be now able to use kubectl top pods and kubectl top nodes within the vCluster:
echo "⏳ Warte, bis der Metriken-Server gestartet ist."
sleep 60
echo "Test metrics server."
kubectl top pods
kubectl top pods --all-namespaces
# kubectl patch deployment metrics-server --patch-file metrics_patch.yaml -n kube-system
kubectl patch deployment metrics-server --patch-file config/monitoring/metrics_patch.yaml -n kube-system
vcluster disconnect
# Schritt 4: Prometheus und Grafana im Haupt-Cluster installieren und konfigurieren
echo "Installiere und konfiguriere Prometheus und Grafana im Haupt-Cluster..."
# Installation von Prometheus und Grafana
# kubectl create namespace monitoring
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo update
# helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring

# kubectl port-forward -n monitoring prometheus-prometheus-stack-kube-prom-prometheus-0 9090 --address=0.0.0.0
# kubectl port-forward -n monitoring prometheus-stack-grafana-8d9b6d98c-ghfpx 3000 --address=0.0.0.0

# the default username and password should be “admin” and “prom-operator”.