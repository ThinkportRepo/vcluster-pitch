#!/bin/bash
echo "The Test-Script is Successful"
kubectl cluster-info

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
if [[ $(command -v vcluster) ]];
then
    echo "🧉 [vcluster] already installed"
else
    echo "⏳ Installing [vcluster] command-line tool. ⏳"
    curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && sudo install -c -m 0755 config-vcluster /usr/local/bin && rm -f config-vcluster
fi
vcluster version
chmod +x kubeconfig-create-rbac.sh
# create config-vcluster admin, dev and prod
#kubectl create ns administration
# RBAC Admin für v-admin cluster
#./kubeconfig-create-rbac.sh admin-sa administration role-rbac-tmp/admin-admin-rbac.yaml

vcluster create v-admin \
    --namespace=administration \
    --connect=false \
     --update-current=false \
    -f config-vcluster/admin-values.yaml
# RBAC Admin für v-admin cluster
sh kubeconfig-create-rbac.sh admin-sa administration config/role-rbac-tmp/admin-admin-rbac.yaml

#vcluster create v-dev \
#    --namespace=development \
#    --connect=false \
#    -f config-vcluster/dev-values.yaml
#
#vcluster create v-prod \
#    --namespace=production \
#    --connect=false \
#    -f config-vcluster/prod-values.yaml