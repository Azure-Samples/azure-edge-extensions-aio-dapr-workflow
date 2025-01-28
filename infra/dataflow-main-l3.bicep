targetScope = 'resourceGroup'

// ------------------------------------------------------------
// Parameters
// ------------------------------------------------------------

@description('AIO Instance Name')
param aioInstanceName string

@description('Custom Location Name')
param customLocationName string

module dataflowEndpoint 'dataflow-endpoint-l3.bicep' = {
  name: 'dataflowEndpoint'
  params: {
    aioInstanceName: aioInstanceName
    customLocationName: customLocationName
  }
}

module dataflowPipeline 'dataflow-pipeline-l3.bicep' = {
  name: 'dataflowPipeline'
  params: {
    aioInstanceName: aioInstanceName
    customLocationName: customLocationName
    l3MqttDataflowEndpointName: dataflowEndpoint.outputs.l3MqttDataflowEndpointName
    l4MqttDataflowEndpointName: dataflowEndpoint.outputs.l4MqttDataflowEndpointName
  }
}
