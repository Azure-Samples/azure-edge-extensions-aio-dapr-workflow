targetScope = 'resourceGroup'

param aioInstanceName string
param customLocationName string

module dataflowEndpoint 'dataflow-endpoint.bicep' = {
  name: 'dataflowEndpoint'
  params: {
    aioInstanceName: aioInstanceName
    customLocationName: customLocationName
  }
}

module dataflowPipeline 'dataflow-pipeline.bicep' = {
  name: 'dataflowPipeline'
  params: {
    aioInstanceName: aioInstanceName
    customLocationName: customLocationName
    l3MqttDataflowEndpointName: dataflowEndpoint.outputs.l3MqttDataflowEndpointName
    l4MqttDataflowEndpointName: dataflowEndpoint.outputs.l4MqttDataflowEndpointName
  }
}
