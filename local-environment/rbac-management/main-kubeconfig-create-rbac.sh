#!/bin/bash
set -e
set -o pipefail

# Add user to k8s using service account, RBAC role file needed
if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
 echo "usage: $0 <service_account_name> <namespace> [rbac-role-yaml]"
 exit 1
fi

SERVICE_ACCOUNT_NAME=$1
NAMESPACE="$2"
RBAC_ROLE_YAML=$3
# KUBECFG_FILE_NAME="./kube/k8s-${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-kubeconfig.yaml"
TARGET_FOLDER="./kube"
KUBECFG_FILE_NAME=~/.kube/config
CLUSTER_NAME="empty"


create_target_folder() {
    echo -n "Creating target directory to hold files in ${TARGET_FOLDER}..."
    mkdir -p "${TARGET_FOLDER}"
    printf "done"
}


# # TODO create service-account with SECRET / TOKEN
create_rbac_role() {
    echo -e "\\nCreating a rbac role in ${NAMESPACE} namespace: ${RBAC_ROLE_YAML}"
    kubectl create -f $RBAC_ROLE_YAML --namespace "${NAMESPACE}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create RBAC role"
        exit 1
    fi
}

create_service_account() {
    echo -e "\\nCreating a service account in ${NAMESPACE} namespace: ${SERVICE_ACCOUNT_NAME}"
    kubectl create sa "${SERVICE_ACCOUNT_NAME}" --namespace "${NAMESPACE}"

    echo -e "\\nCreating a token for the service account ${SERVICE_ACCOUNT_NAME} in ${NAMESPACE} namespace..."
    # Generate a token for the service account and store it in a variable
    SERVICE_ACCOUNT_TOKEN=$(kubectl create token "${SERVICE_ACCOUNT_NAME}" --namespace="${NAMESPACE}")

    # Create a secret for the service account using the generated token
    SECRET_NAME="${SERVICE_ACCOUNT_NAME}-token-secret"
    kubectl create secret generic "${SECRET_NAME}" \
        --namespace "${NAMESPACE}" \
        --from-literal=token="${SERVICE_ACCOUNT_TOKEN}"

    # Link the secret with the service account
    kubectl patch serviceaccount "${SERVICE_ACCOUNT_NAME}" \
        --namespace "${NAMESPACE}" \
        -p "{\"secrets\": [{\"name\": \"${SECRET_NAME}\"}]}"
}


get_secret_name_from_service_account() {
    echo -e "\\nGetting secret of service account ${SERVICE_ACCOUNT_NAME} on ${NAMESPACE}"
    SECRET_DATA=$(kubectl get sa "${SERVICE_ACCOUNT_NAME}" --namespace="${NAMESPACE}" -o json)
    if jq -e '.secrets' <<< "$SECRET_DATA" > /dev/null; then
        SECRET_NAME=$(jq -r '.secrets[].name' <<< "$SECRET_DATA")
        if [ -z "$SECRET_NAME" ]; then
            echo "Error: Secret name not found for service account ${SERVICE_ACCOUNT_NAME} in namespace ${NAMESPACE}"
            exit 1
        fi
        echo "Secret name: ${SECRET_NAME}"
    else
        echo "Error: No secrets found for service account ${SERVICE_ACCOUNT_NAME} in namespace ${NAMESPACE}"
        exit 1
    fi
}

extract_ca_crt_from_secret() {
    echo -e -n "\\nExtracting ca.crt from secret..."
    kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq \
    -r '.data["ca.crt"]' | base64 -d > "${TARGET_FOLDER}/${SERVICE_ACCOUNT_NAME}-ca.crt"
    printf "done"
}

get_user_token_from_secret() {
    echo -e -n "\\nGetting user token from secret..."
    USER_TOKEN=$(kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq -r '.data["token"]' | base64 -d)
    printf "done"
}

set_username_sa_ns() {
  sed -i "" "s/<username>/${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}/g" $RBAC_ROLE_YAML
  sed -i "" "s/<serv-acc>/${SERVICE_ACCOUNT_NAME}/g" $RBAC_ROLE_YAML 
  sed -i "" "s/<namespace>/${NAMESPACE}/g" $RBAC_ROLE_YAML 
}

reset_username_sa_ns() {
  sed -i "" "s/${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}/<username>/g" $RBAC_ROLE_YAML
  sed -i "" "s/${SERVICE_ACCOUNT_NAME}/<serv-acc>/g" $RBAC_ROLE_YAML 
  sed -i "" "s/${NAMESPACE}/<namespace>/g" $RBAC_ROLE_YAML 
}
#../config/developer-role.yaml
get_context_cluster_name(){    
    context=$(kubectl config current-context)
    echo -e "\\nSetting current context to: $context"

    CLUSTER_NAME=$(kubectl config get-contexts "$context" | awk '{print $3}' | tail -n 1)
    echo "Cluster name: ${CLUSTER_NAME}"
}
set_kube_config_values() {

    ENDPOINT=$(kubectl config view \
    -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")
    echo "Endpoint: ${ENDPOINT}"

    # Extracting the cluster certificate authority data
    CA_DATA=$(kubectl config view --raw -o json | jq -r ".clusters[] | select(.name == \"${CLUSTER_NAME}\").cluster.\"certificate-authority-data\"")
    # kubectl config view --raw -o json | jq -r ".clusters[] | select(.name == \"${CLUSTER_NAME}\").cluster.\"certificate-authority-data\""

    echo "Cluster certificate-authority-data: ${CA_DATA}"

    # Set up the config
    # echo -e "\\nPreparing k8s-${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-kubeconfig.yaml"
    # echo -n "Setting a cluster entry in kubeconfig..."
    # kubectl config set-cluster "${CLUSTER_NAME}" \
    # --kubeconfig="${KUBECFG_FILE_NAME}" \
    # --server="${ENDPOINT}" \
    # --certificate-authority="${TARGET_FOLDER}/ca.crt" \
    # --embed-certs=true

   # --certificate-authority="${CA_DATA}" \

    echo -n "Setting token credentials entry in kubeconfig..."
    kubectl config set-credentials \
    "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --token="${USER_TOKEN}"

    echo -n "Setting a context entry in kubeconfig..."
    kubectl config set-context \
    "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --cluster="${CLUSTER_NAME}" \
    --user="${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --namespace="${NAMESPACE}"

    echo -n "Setting the current-context in the kubeconfig file..."
    kubectl config use-context "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}"


  sed -i "" "s/null/${CA_DATA}/g" $KUBECFG_FILE_NAME
}

extract_ca_crt_from_secret
# if [ "$CLUSTER_NAME" = "empty" ]; then
#     echo "The Clustername is empty. get clustername"
#     get_context_cluster_name
#     create_target_folder
#     create_service_account
#     set_username_sa_ns
#     create_rbac_role
#     get_secret_name_from_service_account
#     extract_ca_crt_from_secret
#     get_user_token_from_secret
#     set_kube_config_values
#     reset_username_sa_ns
# else
#     echo "The Clustername not empty"
#     create_target_folder
#     create_service_account
#     set_username_sa_ns
#     create_rbac_role
#     get_secret_name_from_service_account
#     extract_ca_crt_from_secret
#     get_user_token_from_secret
#     set_kube_config_values
#     reset_username_sa_ns
# fi

# kubectl describe sa "${SERVICE_ACCOUNT_NAME}" -n "${NAMESPACE}"
# echo "user token: ${USER_TOKEN}"                               
# echo -e "\\nAll done! Test with:"
# echo "KUBECONFIG=${KUBECFG_FILE_NAME} kubectl get pods"
# KUBECONFIG=${KUBECFG_FILE_NAME} kubectl get pods

# ~/.kube/config
# chmod +x sa-kubeconfig-gen.sh
# ./sa-kubeconfig-gen.sh user-sa staging rbac-user-role.yaml