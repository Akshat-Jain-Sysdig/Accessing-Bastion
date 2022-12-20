#!/usr/bin/env bash

set -euo pipefail
#set -x

function update_kube_config() {
    server=https://127.0.0.1:${localhost_port}
    kubectl config set-cluster ${cluster} --server=${server} --insecure-skip-tls-verify=true > /dev/null
}

# Input Variables
readonly cluster_name=${1:-}
readonly localhost_port=${2:-}

# Set Variables
if [ "${cluster_name}" == "aws-dev-01" ]; then
    readonly domain_name="dev.kubernetes.sysdig.tools"
    readonly aws_region=us-east-1
    readonly environment=dev01
    readonly bastion_ip=54.161.115.4
elif [ "${cluster_name}" == "aws-devops-utility" ]; then
    readonly domain_name="internal.sysdig.tools"
    readonly aws_region=us-east-1
    readonly environment=utility
    readonly bastion_ip=44.199.143.178
elif [ "${cluster_name}" == "aws-integration-01" ]; then
    readonly domain_name="dev.kubernetes.sysdig.tools"
    readonly aws_region=us-east-1
    readonly environment=integration01
    readonly bastion_ip=35.173.172.184
elif [ "${cluster_name}" == "aws-prod-au-1" ]; then
    readonly domain_name="kubernetes.sysdig.tools"
    readonly aws_region=ap-southeast-2
    readonly environment=production
    readonly bastion_ip=13.238.212.186
elif [ "${cluster_name}" == "aws-prod-eu-1" ]; then
    readonly domain_name="kubernetes.sysdig.tools"
    readonly aws_region=eu-central-1
    readonly environment=production
    readonly bastion_ip=18.156.196.56
elif [ "${cluster_name}" == "aws-prod-us-1" ]; then
    readonly domain_name="us1.kubernetes.sysdig.tools"
    readonly aws_region=us-east-1
    readonly environment=production
    readonly bastion_ip=54.198.154.143
elif [ "${cluster_name}" == "aws-prod-us-2" ]; then
    readonly domain_name="kubernetes.sysdig.tools"
    readonly aws_region=us-west-2
    readonly environment=production
    readonly bastion_ip=52.13.146.159
elif [ "${cluster_name}" == "aws-prod-us-3" ]; then
    readonly domain_name="us3.kubernetes.sysdig.tools"
    readonly aws_region=us-east-1
    readonly environment=production
    readonly bastion_ip=18.211.204.233      
elif [ "${cluster_name}" == "aws-prodmon" ]; then
    readonly domain_name="kubernetes.sysdig.tools"
    readonly aws_region=us-west-2
    readonly environment=prodmon
    readonly bastion_ip=44.233.2.195
elif [ "${cluster_name}" == "aws-staging-01" ]; then
    readonly domain_name="staging.kubernetes.sysdig.tools"
    readonly aws_region=us-east-1
    readonly environment=staging01
    readonly bastion_ip=44.199.143.178
    
#For "${cluster_name}" = "aws-staging-2-new"
else
    readonly domain_name="dev.kubernetes.sysdig.tools"
    readonly aws_region=us-east-1
    readonly environment=staging2
    readonly bastion_ip=3.215.83.92
fi

if [ -e ~/.ssh/bastions_key ]; then
    echo "Bastions Private Key File already exists."
else    
    key=$(lpass show 7276179070200790716 --field="Private Key")
    echo "${key}" > ~/.ssh/bastions_key
    chmod 400 ~/.ssh/bastions_key
fi


# Computed Variables
readonly cluster="${environment}.${aws_region}.${domain_name}"
readonly cmd="ssh -i ~/.ssh/bastions_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -L ${localhost_port}:api.${cluster}:443 -fN ubuntu@${bastion_ip}"
update_kube_config

pkill -f "${cmd}" || true
${cmd}
sed -i .bak -e 's/v1alpha1/v1beta1/' ~/.kube/config
