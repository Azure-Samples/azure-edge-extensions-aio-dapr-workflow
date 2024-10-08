#! /bin/bash
K3DCLUSTERNAME := devcluster
K3DREGISTRYNAME := k3d-devregistry.localhost:5500
PORTFORWARDING := -p '5002:5002@loadbalancer' -p '5005:5005@loadbalancer' -p '8883:8883@loadbalancer' -p '1883:1883@loadbalancer'
ARCCLUSTERNAME := arc-dapr-workflow
STORAGEACCOUNTNAME := sadaprworkflow
SCHEMAREGISTRYNAME := sr-dapr-workflow
RESOURCEGROUP := rg-dapr-workflow
LOCATION := westeurope
VERSION := $(shell grep "<Version>" ./src/AzureIoTOperations.DaprWorkflow/AzureIoTOperations.DaprWorkflow.csproj | sed 's/[^0-9.]*//g')

all: create_k3d_cluster install_dapr install_redis deploy_aio deploy_opcplcsimulator deploy_mqttui deploy_dapr_components build_dapr_workflow_app deploy_dapr_workflow_app deploy_authorization

create_k3d_cluster:
	@echo "Creating k3d cluster..."
	k3d cluster create $(K3DCLUSTERNAME) $(PORTFORWARDING) --registry-use $(K3DREGISTRYNAME) --servers 1
	@echo "Creating namespace dapr-workflow..."
	kubectl create namespace dapr-workflow

install_dapr:
	@echo "Installing dapr..."
	helm repo add dapr https://dapr.github.io/helm-charts/
	helm repo update
	helm upgrade --install dapr dapr/dapr --namespace dapr-system --create-namespace --wait

install_redis:
	@echo "Installing redis..."
	helm repo add redis-stack https://redis-stack.github.io/helm-redis-stack/
	helm repo update
	helm upgrade --install redis-stack redis-stack/redis-stack --set-string redis_stack.tag="latest" --reuse-values --namespace redis --create-namespace --wait

deploy_aio:
	@echo "Deploying AIO..."
	bash ./infra/deploy-aio.sh $(ARCCLUSTERNAME) $(STORAGEACCOUNTNAME) $(SCHEMAREGISTRYNAME) $(RESOURCEGROUP) $(LOCATION)

deploy_opcplcsimulator:
	@echo "Deploying OPC PLC Simulator..."
	kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/explore-iot-operations/main/samples/quickstarts/opc-plc-deployment.yaml

deploy_mqttui:
	@echo "Deploying mqttui tool..."
	kubectl create serviceaccount mqtt-client -n azure-iot-operations
	kubectl annotate serviceaccount mqtt-client aio-mq-broker-auth/group=mqtt-client -n azure-iot-operations
	kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/explore-iot-operations/main/samples/quickstarts/mqtt-client.yaml

deploy_dapr_components:
	@echo "Deploying dapr components..."
	kubectl apply -f ./src/AzureIoTOperations.DaprWorkflow/Components/components.yaml -n azure-iot-operations
	kubectl apply -f ./src/AzureIoTOperations.DaprWorkflow/Components/dev.redis-statestore.yaml -n azure-iot-operations

build_dapr_workflow_app:
	@echo "Building dapr workflow app..."
	docker build ./src/AzureIoTOperations.DaprWorkflow -f ./src/AzureIoTOperations.DaprWorkflow/Dockerfile -t daprworkflow:$(VERSION)
	docker tag daprworkflow:$(VERSION) $(K3DREGISTRYNAME)/daprworkflow:$(VERSION)
	docker push $(K3DREGISTRYNAME)/daprworkflow:$(VERSION)

deploy_dapr_workflow_app:
	@echo "Deploying dapr workflow app..."
	sed -i "s?__{container_registry}__?$(K3DREGISTRYNAME)?g" ./src/AzureIoTOperations.DaprWorkflow/Components/deploy.yaml
	sed -i "s?__{image_version}__?$(VERSION)?g" ./src/AzureIoTOperations.DaprWorkflow/Components/deploy.yaml
	kubectl apply -f ./src/AzureIoTOperations.DaprWorkflow/Components/deploy.yaml -n azure-iot-operations

deploy_authorization:
	@echo "Deploying authorization..."
	kubectl apply -f ./src/AzureIoTOperations.DaprWorkflow/Components/brokerauthorization.yaml -n azure-iot-operations
	kubectl apply -f ./src/AzureIoTOperations.DaprWorkflow/Components/brokerlistener.yaml -n azure-iot-operations

clean:
	@echo "Cleaning up..."
	k3d cluster delete $(K3DCLUSTERNAME)
	az group delete -n $RESOURCEGROUP --yes
