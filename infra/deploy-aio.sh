#! /bin/bash

export CLUSTER_NAME=$1
export RESOURCE_GROUP=$2
export SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export LOCATION=$3

# install CLI extensions
echo "Installing CLI extensions..."
az extension add --name connectedk8s;
az extension add --name azure-iot-ops;

# create resource group
if [ ! $(az group exists -n $RESOURCE_GROUP) ]; then
    echo "Creating RG $RESOURCE_GROUP..."
    az group create --location $LOCATION --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID
fi

# connect arc cluster
echo "Connecting cluster $CLUSTER_NAME..."
az connectedk8s connect -n $CLUSTER_NAME -l $LOCATION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID

# get object id of app registration
echo "Getting object id of app registration..."
export OBJECT_ID=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)

# enable custom location support on cluster
echo "Enabling custom location support on cluster $CLUSTER_NAME..."
az connectedk8s enable-features -n $CLUSTER_NAME -g $RESOURCE_GROUP --custom-locations-oid $OBJECT_ID --features cluster-connect custom-locations

# create keyvault
echo "Creating keyvault..."
az keyvault create --enable-rbac-authorization false --name ${CLUSTER_NAME:0:24} --resource-group $RESOURCE_GROUP

# deploy AIO
echo "Deploying AIO..."
az iot ops init --include-dp --simulate-plc --cluster $CLUSTER_NAME --resource-group $RESOURCE_GROUP --kv-id $(az keyvault show --name ${CLUSTER_NAME:0:24} -o tsv --query id)
