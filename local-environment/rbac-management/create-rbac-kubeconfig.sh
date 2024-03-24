#!/bin/bash
set -e
set -o pipefail

# Script to add a user to Kubernetes using a service account and RBAC role

if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
 echo "Usage: $0 <service_account_name> <namespace> <rbac-role-temp>"
 exit 1
fi

service_account_name=$1
namespace="$2"
RBAC_ROLE_TEMP=$3
TARGET_FOLDER="./kube"
KUBECONFIG_FILE_NAME="${HOME}/.kube/config"
cluster_name=""
RBAC_ROLE_YAML="${RBAC_ROLE_TEMP}.yaml"
SED_I_ARG=""
# Detecting the operating system (OS) to correctly set the sed in-place (-i)
# Detect OS
OS="$(uname -s)"

# Get the appropriate sed in-place argument based on the OS
if [[ "$OS" == "Linux"* ]]; then
    SED_I_ARG="-i"
elif [[ "$OS" == "Darwin"* ]]; then
    SED_I_ARG="-i ''"
else
    echo "Unsupported OS: $OS" >&2
    exit 1
fi


make_yaml_from_temp(){
  if [ -f "$RBAC_ROLE_TEMP" ]; then
    # Copy the content from the source file to the destination file
    cp "$RBAC_ROLE_TEMP" "$RBAC_ROLE_YAML"
    echo "File ${RBAC_ROLE_YAML} copied successfully."
  else
    echo "Error: Source file does not exist."
    exit 1
  fi
}

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "jq could not be found, please install it"
    exit 1
fi

create_target_folder() {
    echo "Creating target directory: ${TARGET_FOLDER}"
    mkdir -p "${TARGET_FOLDER}"
}

create_rbac_role() {
    echo "Creating RBAC role in namespace: ${namespace}"
    kubectl create -f "${RBAC_ROLE_YAML}" --namespace "${namespace}" || exit 1
}

create_service_account() {
    echo "Creating service account: ${service_account_name} in namespace: ${namespace}"
    kubectl create sa "${service_account_name}" --namespace "${namespace}" || exit 1
}

create_service_account_token() {
    echo "Creating service account token for: ${service_account_name} in namespace: ${namespace}"
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${service_account_name}-token
  namespace: ${namespace}
  annotations:
    kubernetes.io/service-account.name: ${service_account_name}
type: kubernetes.io/service-account-token
EOF
    if [ $? -ne 0 ]; then
        echo "Failed to create service account token"
        exit 1
    fi
}

link_token_to_service_account() {
    echo "Linking token to service account"
    kubectl patch serviceaccount "${service_account_name}" \
        --namespace="${namespace}" \
        -p "{\"secrets\": [{\"name\": \"${service_account_name}-token\"}]}"
    if [ $? -ne 0 ]; then
        echo "Failed to link token to service account"
        exit 1
    fi
}

get_secret_name_from_service_account() {
    secret_name=$(kubectl get sa "${service_account_name}" --namespace="${namespace}" -o jsonpath='{.secrets[0].name}')
    if [[ -z "$secret_name" ]]; then
        echo "Error: Secret name not found for service account ${service_account_name}"
        exit 1
    fi
    echo "Secret name: ${secret_name}"
}

extract_ca_crt_from_secret() {
    echo "Extracting ca.crt from secret"
    kubectl get secret --namespace "${namespace}" "${secret_name}" -o jsonpath="{.data['ca.crt']}" | base64 -d > "${TARGET_FOLDER}/${service_account_name}-ca.crt"
}

get_user_token_from_secret() {
    echo "Getting user token from secret"
    user_token=$(kubectl get secret --namespace "${namespace}" "${secret_name}" -o jsonpath="{.data.token}" | base64 -d)
}
#../config/developer-role.yaml
get_context_cluster_name(){
    context=$(kubectl config current-context)
    echo -e "\\nSetting current context to: $context"

    cluster_name=$(kubectl config get-contexts "$context" | awk '{print $3}' | tail -n 1)
    echo "Cluster name: ${cluster_name}"
}
set_kube_config_values() {
    endpoint=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"${cluster_name}\")].cluster.server}")
    echo "Endpoint: ${endpoint}"

    ca_data=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name == \"${cluster_name}\")].cluster.'certificate-authority-data'}")

    echo "Setting kubeconfig values"
    kubectl config set-credentials "${service_account_name}-${namespace}-${cluster_name}" --kubeconfig="${KUBECONFIG_FILE_NAME}" --token="${user_token}"
    kubectl config set-context "${service_account_name}-${namespace}-${cluster_name}" --kubeconfig="${KUBECONFIG_FILE_NAME}" --cluster="${cluster_name}" --user="${service_account_name}-${namespace}-${cluster_name}" --namespace="${namespace}"
    # kubectl config use-context "${service_account_name}-${namespace}-${cluster_name}" --kubeconfig="${KUBECONFIG_FILE_NAME}"
}

# Functions to replace and reset placeholders in the RBAC role TEMP
set_username_sa_ns() {
  echo "Setting service account ${service_account_name}, namespace ${namespace}, and cluster name: ${cluster_name} in RBAC role template: ${RBAC_ROLE_YAML}"
  if [[ "$OS" == "Darwin"* ]]; then
    sed -i '' "s/<username>/${service_account_name}-${namespace}-${cluster_name}/g" "$RBAC_ROLE_YAML"
    sed -i '' "s/<serv-acc>/${service_account_name}/g" "$RBAC_ROLE_YAML"
    sed -i '' "s/<namespace>/${namespace}/g" "$RBAC_ROLE_YAML"
  else
    sed -i "s/<username>/${service_account_name}-${namespace}-${cluster_name}/g" "$RBAC_ROLE_YAML"
    sed -i "s/<serv-acc>/${service_account_name}/g" "$RBAC_ROLE_YAML"
    sed -i "s/<namespace>/${namespace}/g" "$RBAC_ROLE_YAML"
  fi

}

clear_yaml_file(){
  echo "Die erstellte YAML-Datei ${RBAC_ROLE_YAML} aufräumen."
  rm "${RBAC_ROLE_YAML}"
}

main() {
  # Create Serviceaccount
  create_target_folder
  create_service_account
  # Create RBAC
  get_context_cluster_name
  make_yaml_from_temp
  set_username_sa_ns
  create_rbac_role
  clear_yaml_file
  # ####
  create_service_account_token
  link_token_to_service_account
  get_secret_name_from_service_account
  extract_ca_crt_from_secret
  get_user_token_from_secret
  set_kube_config_values
}

main
# Main script execution
echo "Das Skript wurde erfolgreich abgeschlossen"