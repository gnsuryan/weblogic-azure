# Copyright (c) 2021, 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# This script runs on Azure Container Instance with Alpine Linux that Azure Deployment script creates.

#!/bin/bash

set -Eeuo pipefail

echo "inside app-gw-post-deployment.sh script"

echo "Processing Application Gateway: $APPGW_NAME in Resource Group: $RESOURCE_GROUP_NAME"

# Get all frontend IP configs for this App Gateway
FE_IPS=$(az network application-gateway frontend-ip list \
  --gateway-name $APPGW_NAME \
  -g $RESOURCE_GROUP_NAME \
  --query "[].name" -o tsv)

if [ -z "$FE_IPS" ]; then
  echo "No frontend IP configurations found for $APPGW"
  exit 0
fi

for FE in $FE_IPS; do
  echo "  Checking Frontend IP config: $FE"

  # Get details of frontend config
  PUBLIC_IP=$(az network application-gateway frontend-ip show \
    --gateway-name $APPGW_NAME \
    -g $RESOURCE_GROUP_NAME \
    -n $FE \
    --query "publicIpAddress.id" -o tsv)

  if [ -n "$PUBLIC_IP" ]; then
    PUB_NAME=$(basename $PUBLIC_IP)
    PUB_RG=$(echo $PUBLIC_IP | cut -d'/' -f5)

    # Get tag value of this Public IP
    CURRENT_TAG=$(az network public-ip show -g $PUB_RG -n $PUB_NAME \
      --query "tags.TagName" -o tsv)

    if [ "$CURRENT_TAG" == "$TAGVALUE" ]; then
      echo "Public IP $PUB_NAME matches tag $TAGVALUE"
      echo "Detaching from frontend config..."
      az network application-gateway frontend-ip update \
        --gateway-name $APPGW_NAME \
        -g $RESOURCE_GROUP_NAME \
        -n $FE \
        --public-ip-address ""

      echo "Deleting Public IP resource: $PUB_NAME in $PUB_RG"
      az network public-ip delete -g $PUB_RG -n $PUB_NAME
    else
      echo "Skipping $PUB_NAME (tag does not match)"
    fi

  else
    echo "No Public IP associated with $FE"
  fi
done

echo "Completed processing Application Gateway: $APPGW_NAME in resource group $RESOURCE_GROUP_NAME"
