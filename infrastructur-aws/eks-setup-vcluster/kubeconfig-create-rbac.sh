#!/bin/bash
set -e
set -o pipefail

# Usage: script_name <service_account_name> <namespace> <rbac-role-yaml>
if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
 echo "usage: $0 <service_account_name> <namespace> <rbac-role-yaml>"
 exit 1
fi

SERVICE_ACCOUNT_NAME=$1
NAMESPACE="$2"
RBAC_ROLE_YAML=$3
KUBECFG_FILE_NAME="./kube/k8s-${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-kubeconfig.yaml"
TARGET_FOLDER="./kube"
CLUSTER_NAME=""

create_target_folder() {
    echo -n "Creating target directory to hold files in ${TARGET_FOLDER}..."
    if [ ! -d "${TARGET_FOLDER}" ]; then
      echo "${TARGET_FOLDER} does not exist."
      mkdir –p "${TARGET_FOLDER}"
    else
      echo "${TARGET_FOLDER} directory exists."
      chmod +xr "${TARGET_FOLDER}"
    fi
    echo "done"
}

set_username_sa_ns() {
    # Backup the original file before making changes
    cp "$RBAC_ROLE_YAML" "${RBAC_ROLE_YAML}.bak"

    # Replace placeholders with actual values
    sed -i "s/<username>/${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}/g" "$RBAC_ROLE_YAML"
    sed -i "s/<serv-acc>/${SERVICE_ACCOUNT_NAME}/g" "$RBAC_ROLE_YAML"
    sed -i "s/<namespace>/${NAMESPACE}/g" "$RBAC_ROLE_YAML"
}
reset_username_sa_ns() {
    # Restore the original file from backup
    mv "${RBAC_ROLE_YAML}.bak" "$RBAC_ROLE_YAML"
}

create_rbac_role() {
    echo -e "\\nCreating a rbac role in ${NAMESPACE} namespace: ${RBAC_ROLE_YAML}"
    kubectl create -f "$RBAC_ROLE_YAML" --namespace "${NAMESPACE}" || {
        echo "Error: Failed to create RBAC role"
        exit 1
    }
}

create_service_account() {
    echo -e "\\nCreating a service account in ${NAMESPACE} namespace: ${SERVICE_ACCOUNT_NAME}"
    kubectl create sa "${SERVICE_ACCOUNT_NAME}" --namespace "${NAMESPACE}" || {
        echo "Error: Failed to create service account"
        exit 1
    }

    echo -e "\\nCreating a token for the service account ${SERVICE_ACCOUNT_NAME} in ${NAMESPACE} namespace..."
    # shellcheck disable=SC2034
    SERVICE_ACCOUNT_TOKEN=$(kubectl create token "${SERVICE_ACCOUNT_NAME}" --namespace="${NAMESPACE}")
}

get_secret_name_from_service_account() {
    SECRET_NAME=$(kubectl get sa "${SERVICE_ACCOUNT_NAME}" --namespace="${NAMESPACE}" -o jsonpath='{.secrets[0].name}')
    if [ -z "$SECRET_NAME" ]; then
        echo "Error: Secret name not found for service account ${SERVICE_ACCOUNT_NAME} in namespace ${NAMESPACE}"
        exit 1
    fi
    echo "Secret name: ${SECRET_NAME}"
}

extract_ca_crt_from_secret() {
    kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o jsonpath="{.data['ca.crt']}" | base64 -d > "${TARGET_FOLDER}/ca.crt"
}

get_user_token_from_secret() {
    USER_TOKEN=$(kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o jsonpath="{.data['token']}" | base64 -d)
}

get_context_cluster_name(){
    CLUSTER_NAME=$(kubectl config current-context)
    if [ -z "$CLUSTER_NAME" ]; then
        echo "Error: Current Kubernetes context is not set."
        exit 1
    fi
    echo "Using cluster: ${CLUSTER_NAME}"
}

set_kube_config_values() {
    ENDPOINT=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")
    CA_DATA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.'certificate-authority-data'}")

    kubectl config set-cluster "${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --server="${ENDPOINT}" \
    --certificate-authority="${TARGET_FOLDER}/ca.crt" \
    --embed-certs=true

    kubectl config set-credentials \
    "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --token="${USER_TOKEN}"

    kubectl config set-context \
    "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --cluster="${CLUSTER_NAME}" \
    --user="${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --namespace="${NAMESPACE}"

    kubectl config use-context "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}"
}

main() {
    get_context_cluster_name
    create_target_folder
    create_service_account
    set_username_sa_ns
    create_rbac_role
    get_secret_name_from_service_account
    extract_ca_crt_from_secret
    get_user_token_from_secret
    set_kube_config_values
    reset_username_sa_ns
    echo "KUBECONFIG=${KUBECFG_FILE_NAME} kubectl get pods"
}

main
