#!/bin/bash
echo "The Test-Script is Successful"
kubectl cluster-info

if [[ $(command -v config-vcluster) ]];
then
    echo "🧉 [vcluster] already installed"
else
    echo "⏳ Installing [vcluster] command-line tool. ⏳"
    curl -L -o config-vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && sudo install -c -m 0755 config-vcluster /usr/local/bin && rm -f config-vcluster
fi
config-vcluster version