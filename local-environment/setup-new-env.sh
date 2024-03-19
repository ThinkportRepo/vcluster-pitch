#!/bin/bash

NUM_VCLUSTERS=0
declare -a VCLUSTER_SELECTION
# Function to check if input is a number
check_stdin_number() {
    re='^[0-9]+$'
    if [[ $1 =~ $re ]]; then
        return 0
    else
        return 1
    fi
}

# Function to install Minikube on Linux
install_minikube_linux() {
    echo "Installing Minikube on Linux..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
}

# Function to install Minikube on macOS
install_minikube_mac() {
    echo "Installing Minikube on macOS..."
    brew install minikube
}

# Function to install Minikube on Windows (via WSL)
install_minikube_windows() {
    echo "Installing Minikube on Windows (WSL)..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
}

# Detect the platform
case "$(uname -s)" in
    Linux*)     platform=Linux;;
    Darwin*)    platform=Mac;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*) platform=Windows;;
    *)          platform="UNKNOWN:${unameOut}"
esac



# 1- install kubectl
if [[ $(command -v minikube) ]];
then
    echo "🧉 [kubectl] already installed"
    minikube version
else
      echo "Detected platform: $platform"

      # Install Minikube based on the platform
      case $platform in
            Linux)  install_minikube_linux;;
            Mac)    install_minikube_mac;;
            Windows) install_minikube_windows;;
            *)      echo "Unsupported platform: $platform"; exit 1;;
      esac
fi
# Start Minikube
echo "Starting Minikube with Calico..."
minikube start --network-plugin=cni --cni=calico
#echo "Verify Calico installation..."
#watch kubectl get pods -l k8s-app=calico-node -A

# 1- install kubectl
if [[ $(command -v kubectl) ]]; 
then
    echo "🧉 [kubectl] already installed"
    kubectl version
else
    echo "⏳ Installing [kubectl] command-line tool. ⏳"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# 2- install config-vcluster
if [[ $(command -v config-vcluster) ]];
then
    echo "🧉 [vcluster] already installed"
else
    echo "⏳ Installing [vcluster] command-line tool. ⏳"
    curl -L -o config-vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && sudo install -c -m 0755 config-vcluster /usr/local/bin && rm -f config-vcluster
fi

chmod +x rbac-management/create-rbac-kubeconfig.sh

# Create and configure a virtual cluster (admin-vcluster) using the service account admin-sa,
# and implement a network policy to deny all inbound (Ingress) and outbound (Egress) traffic.
kubectl create namespace administration
# create admin-vcluster
vcluster create admin-vcluster \
    --namespace=administration \
    --connect=false \
    -f config/vcluster/admin-values.yaml
# create network policy for admin-vcluster
kubectl create -f config/networkpolicy/admin-calico-netpol.yaml

# RBAC Admin für admin-vcluster
./rbac-management/create-rbac-kubeconfig.sh admin-admin-sa administration config/role-rbac-tmp/admin-admin-rbac.temp

create_secure_isolate_vclusters(){
  echo "Deploy VCluster "
  # Create and configure a virtual cluster using the service account,
  # and implement a network policy to deny all inbound (Ingress) and outbound (Egress) traffic.

  # create admin-vcluster
  vcluster create $1 \
    --namespace=$2 \
    --create-namespace=true \
    --connect=false \
    -f config/vcluster/admin-values.yaml
  # create network policy for admin-vcluster
  kubectl -n $2 create -f config/networkpolicy/admin-calico-netpol.yaml
  # RBAC Admin für admin-vcluster
./rbac-management/create-rbac-kubeconfig.sh "$1-sa" administration config/role-rbac-tmp/admin-admin-rbac.temp
}
# Create and configure a virtual cluster (dev-vcluster) using the service account admin-sa,
# and implement a network policy to deny all inbound (Ingress) traffic.
kubectl create namespace development
# create dev-vcluster
vcluster create dev-vcluster \
    --namespace=development \
    --connect=false \
    -f config/vcluster/dev-values.yaml

# create network policy for dev-vcluster
kubectl create -f config/networkpolicy/dev-calico-netpol.yaml

# RBAC Admin für dev-vcluster
./rbac-management/create-rbac-kubeconfig.sh admin-dev-sa administration config/role-rbac-tmp/admin-admin-rbac.temp

# Create and configure a virtual cluster (prod-vcluster) using the service account admin-sa,
# and implement a network policy to deny all inbound (Ingress) and outbound (Egress) traffic.
kubectl create namespace production

# create prod-vcluster
vcluster create prod-vcluster \
    --namespace=production \
    --connect=false \
    -f config/vcluster/prod-values.yaml
# RBAC prod für prod-vcluster
kubectl create -f config/networkpolicy/prod-calico-netpol.yaml

# RBAC Admin für prod-vcluster cluster
./rbac-management/create-rbac-kubeconfig.sh admin-prod-sa production config/role-rbac-tmp/admin-prod-rbac.temp


# Monitoring
vcluster create mv-admin \
    --namespace=monitoring-admin \
    --create-namespace=true \
    --connect=false \
    -f config/vcluster/admin-values.yaml

# connecting to mv-admin    
vcluster connect mv-admin

# installing metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# Wait until the metrics server has started. You should be now able to use kubectl top pods and kubectl top nodes within the vCluster:
echo "⏳ Warte, bis der Metriken-Server gestartet ist."
sleep 120
echo "Test metrics server."
kubectl top pods
kubectl top pods --all-namespaces
# kubectl patch deployment metrics-server --patch-file metrics_patch.yaml -n kube-system
kubectl patch deployment metrics-server --patch-file config/monitoring/metrics_patch.yaml -n kube-system
vcluster disconnect

deploy_prometheus_grafana(){
  # Schritt 4: Prometheus und Grafana im Haupt-Cluster installieren und konfigurieren
  echo "Installiere und konfiguriere Prometheus und Grafana im Haupt-Cluster..."
  # Installation von Prometheus und Grafana
  kubectl create namespace monitoring
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
}
start_prometheus_grafana(){
  kubectl port-forward -n monitoring prometheus-prometheus-stack-kube-prom-prometheus-0 9090 --address=0.0.0.0
  kubectl port-forward -n monitoring prometheus-stack-grafana-8d9b6d98c-ghfpx 3000 --address=0.0.0.0
}
# the default username and password should be “admin” and “prom-operator”.
# shellcheck disable=SC1073
vcluster_menu(){
 read -p "Wie viele vcluster wollen Sie erstellen?: " NUM_VCLUSTERS
  # Check if input is a number and greater than 0
  if is_number "$NUM_VCLUSTERS" && ((NUM_VCLUSTERS > 0)); then
    echo "Input is a positive number."
    create_vclusters
    vcluster_configuration
  else
    echo "Ungültige Eingabe. Bitte geben Sie Wie viele vcluster wollen Sie erstellen?"
    vcluster_menu
  fi

}
create_vclusters_menu(){
# Loop to create the desired number of vClusters
for ((i=1; i<=$NUM_VCLUSTERS; i++)); do
  echo "=================Bereitstellung der $i. vcluster==================="
  read -p "$i- vcluster name: " VCLUSTER_SELECTION[0]
  read -p "$i- vcluster namespace: " VCLUSTER_SELECTION[1]
  read -p "$i- Möchten Sie vCluster mit höchster Sicherheit und Isolation erstellen?" VCLUSTER_SELECTION[2]
  # shellcheck disable=SC1111
  read -p "$i- Welcher Kubernetes-Distribution wollen verwenden?\n(Zulässige Distributionen: k3s, k0s, k8s, eks (Drücken Sie Enter für die Default „k3s“)) :" VCLUSTER_SELECTION[3]
  echo "$i. vCluster name: ${VCLUSTER_SELECTION[0]} in namespace: ${VCLUSTER_SELECTION[1]} und mit der Kubernetes-Distribution ${VCLUSTER_SELECTION[3]}"
  unset VCLUSTER_SELECTION


done
}
vcluster_configuration(){

}
# Display menu options
display_menu() {
    echo "Wähle eine Option:"
    echo "1. VClusters erstellen und konfigurieren"
    echo "2. Prometheus and Grafana installieren"
    echo "3. Exit"
}

# Main script
while true; do
    display_menu

    read -p "Geben Sie Ihre Wahl ein: " choice

    case $choice in
        1) create_vclusters_menu ;;
        2) deploy_prometheus_grafana ;;
        3) echo "Exiting..."; exit ;;
        *) echo "Invalid choice. Please enter a valid option." ;;
    esac

    echo
done