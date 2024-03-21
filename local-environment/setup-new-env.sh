#!/bin/bash
#
## Created By: Mouad@Linux
# Created On: Mon 09 Jan 2023 12:35:28 PM CST
# # Project: VCluster pitch
#
#
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

NUM_VCLUSTERS=0
declare -a VCLUSTER_SELECTION

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
    --distro=$3 \
    --create-namespace=true \
    --connect=false \
    -f config/vcluster/admin-values.yaml
  # create network policy for admin-vcluster
  kubectl -n $2 create -f config/networkpolicy/admin-calico-netpol.yaml
  # RBAC Admin für admin-vcluster
./rbac-management/create-rbac-kubeconfig.sh "$1-sa" administration config/role-rbac-tmp/admin-admin-rbac.temp
}
create_simple_vclusters(){
  echo "Deploy VCluster "
  # create a Simple vcluster
  vcluster create $1 \
    --namespace=$2 \
    --create-namespace=true \
    --connect=false \
    -f config/vcluster/dev-values.yaml
  # create network policy for admin-vcluster
  kubectl -n $2 create -f config/networkpolicy/admin-calico-netpol.yaml
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
  echo "Deploye und konfiguriere Prometheus und Grafana im Hauptcluster..."
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


##
# Color  Variables
##
RED='\e[1;41m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
CLEAR='\e[0m'

BG_RED='\e[1;41m'
BG_GREEN='\e[1;32m'
BG_YELLOW='\e[1;33m'
BG_BLUE='\e[1;34m'
BG_MAGENTA='\e[1;35m'
BG_CYAN='\e[1;36m'

##
# Color Functions
##

color_red(){
	echo -ne $RED$1$CLEAR
}

color_green(){
	echo -ne $GREEN$1$CLEAR
}

color_yellow(){
	echo -ne $YELLOW$1$CLEAR
}

color_blue(){
	echo -ne $BLUE$1$CLEAR
}

color_magenta(){
	echo -ne $MAGENTA$1$CLEAR
}

color_cyan(){
	echo -ne $CYAN$1$CLEAR
}

color_bg_red(){
	echo -ne $BG_RED$1$CLEAR
}

color_bg_green(){
	echo -ne $BG_GREEN$1$CLEAR
}

color_bg_yellow(){
	echo -ne $BG_YELLOW$1$CLEAR
}

color_bg_blue(){
	echo -ne $BG_BLUE$1$CLEAR
}

color_bg_magenta(){
	echo -ne $BG_MAGENTA$1$CLEAR
}

color_bg_cyan(){
	echo -ne $BG_CYAN$1$CLEAR
}
is_number() {
  # Check if the input is a number
  if [[ $1 =~ ^[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}

# Display menu options
vcluster_menu(){
  clear
  read -p "Wie viele vcluster wollen Sie erstellen?: " NUM_VCLUSTERS
  # Check if input is a number and greater than 0
  if is_number "$NUM_VCLUSTERS" && ((NUM_VCLUSTERS > 0)); then
    create_vclusters_menu
  else
    echo "Ungültige Eingabe. Bitte geben Sie Wie viele vcluster wollen Sie erstellen?"
    vcluster_menu
  fi
}
display_distro(){
    echo "Die ausgewählte Kubernetes-Distribution: ${VCLUSTER_SELECTION[3]}"
}
check_kubernetes_disro() {
  read -p "$i- Welcher Kubernetes-Distribution wollen verwenden? \n(Zulässige Distributionen: k3s, k0s, k8s, eks (Drücken Sie Enter für die Default „k3s“)): " input_distribution

  case "${input_distribution,,}" in
    "")
      VCLUSTER_SELECTION[3]="k3s"
      ;;
    k3s|k0s|k8s|eks)
      VCLUSTER_SELECTION[3]="${input_distribution,,}"
      ;;
    *)
      echo "-$input_distribution- Ungültige Eingabe! Bitte wählen Sie eine der folgenden Optionen: k3s, k0s, k8s, eks"
      check_kubernetes_disro
      ;;
  esac
  display_distro
}
check_iso_secure() {

  read -p "$i- Möchten Sie vCluster mit höchster Sicherheit und Isolation erstellen?" input_iso_secure

  case "${input_iso_secure,,}" in
    "")
      VCLUSTER_SELECTION[2]="n"
      ;;
    y|yes|j|ja|n|no|nein)
      VCLUSTER_SELECTION[2]="${input_iso_secure,,}"
      ;;
    *)
      echo "-$input_iso_secure- Ungültige Eingabe! Bitte wählen Sie eine der folgenden Optionen: y, yes, j, ja, n, no, nein"
      check_iso_secure
      ;;
  esac
}
create_vclusters_menu(){
clear
# Loop to create the desired number of vClusters
for ((i=1; i<=$NUM_VCLUSTERS; i++)); do
  echo "=================Bereitstellung der $i. vcluster==================="
  read -p "$i- vcluster name: " VCLUSTER_SELECTION[0]
  read -p "$i- vcluster namespace: " VCLUSTER_SELECTION[1]
  #read -p "$i- Möchten Sie vCluster mit höchster Sicherheit und Isolation erstellen?" VCLUSTER_SELECTION[2]
  check_iso_secure
  # shellcheck disable=SC1111
  check_kubernetes_disro
  # check_kubernetes_disro VCLUSTER_SELECTION[3]
  echo "$i. vCluster name: ${VCLUSTER_SELECTION[0]} in namespace: ${VCLUSTER_SELECTION[1]} und mit der Kubernetes-Distribution ${VCLUSTER_SELECTION[3]}"
  # unset VCLUSTER_SELECTION
done
}
display_main_menu() {
    clear
    echo -ne "
    $(color_bg_red 'Wähle eine Option:')
    $(color_green '1. VClusters erstellen und konfigurieren')
    $(color_blue '2. Prometheus and Grafana installieren')
    $(color_cyan '3. Verlasen')
    $(color_cyan 'Wähle eine Option:')
    "

}
# Function to display submenu for vClusters creation
display_vcluster_create_submenu() {
    clear
    echo -ne "
    $(color_bg_green 'VClusters erstellen und konfigurieren:\n')
    $(color_blue '1. Wie viele vClusters wollen Sie erstellen?')
    $(color_red '2. Zurück zum Hauptmenü')
    "
}
# Function to display submenu for vClusters creation
display_vcluster_create_submenu() {
    clear
    echo -ne "
    $(color_bg_green 'VClusters erstellen und konfigurieren:')
    $(color_blue 'Wie viele vClusters wollen Sie erstellen?')
    "

    # (color_red '2. Zurück zum Hauptmenü')
}
exit_menu(){
  # Exit
  echo "Verlassen..."
  exit
}
#display_vcluster_vcluster_configuration(){
#
#}
# Main script
while true; do
    display_main_menu
    read main_choice
    case $main_choice in
        1) # Submenu 1: VClusters erstellen und konfigurieren
            while true; do
                vcluster_menu
                read -p "Drücken Sie die Eingabetaste, um fortzufahren ..."
            done;;
        2) # Submenu 2: Prometheus and Grafana installieren
            deploy_prometheus_grafana;;
        0) # Submenu 2: Exit
            exit_menu
            ;;
        *) echo "Ungültige Eingabe";;
    esac
    read -p "Drücken Sie die Eingabetaste, um fortzufahren ..."
done








#PS3="Wähle eine Option:"
#while true; do
#  select choice in "VClusters erstellen und konfigurieren" "Prometheus and Grafana installieren" "verlassen"; do
#    case $choice in
#     "1- VClusters erstellen und konfigurieren")
#      echo "VClusters wird deployt"
#    ;;
#    "2- Prometheus and Grafana installieren")
#      echo "Prometheus and Grafana wird deployt"
#    ;;
#    "3- verlassen")
#      echo "Menu wird verlassen"
#      break
#      ;;
#    *)
#      echo "$REPLY Ungültige Auswahl. Bitte geben Sie eine gültige Option ein."
#      ;;
#    esac
#  done
#done

#while true; do
#    display_menu
#
#    read -p "Geben Sie Ihre Wahl ein: " choice
#
#    case $choice in
#        1) create_vclusters_menu ;;
#        2) deploy_prometheus_grafana ;;
#        3) echo "Exiting..."; exit ;;
#        *) echo "Invalid choice. Please enter a valid option." ;;
#    esac
#
#    echo
#done