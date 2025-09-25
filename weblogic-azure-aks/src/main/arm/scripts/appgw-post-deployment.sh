# Copyright (c) 2021, 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# This script runs on Azure Container Instance with Alpine Linux that Azure Deployment script creates.

#!/bin/bash

set -Eeuo pipefail

echo "inside app-gw-post-deployment.sh script"

# Update the IP configuration of network interface assigned to each worker node of the cluster by setting its private ip allocation method to Static
#if [[ "${CONFIGURE_APPGW,,}" == "true" ]]; then
#  for i in $(seq 1 $NUMBER_OF_WORKER_NODES); do
#    nicName=${WORKER_NODE_PREFIX}${i}-if
#    ipConfigName=$(az network nic show -g ${RESOURCE_GROUP_NAME} -n ${nicName} --query 'ipConfigurations[0].name' -o tsv)
#    az network nic ip-config update -g ${RESOURCE_GROUP_NAME} --nic-name ${nicName} -n ${ipConfigName} --set privateIpAllocationMethod=Static
#  done
#fi

