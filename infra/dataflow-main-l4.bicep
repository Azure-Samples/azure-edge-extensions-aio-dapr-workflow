targetScope = 'resourceGroup'

// ------------------------------------------------------------
// Parameters
// ------------------------------------------------------------

@description('AIO Instance Name')
param aioInstanceName string

@description('Custom Location Name')
param customLocationName string

module dataflowEndpoint 'dataflow-endpoint-l4.bicep' = {
  name: 'dataflowEndpoint'
  params: {
    aioInstanceName: aioInstanceName
    customLocationName: customLocationName
  }
}

module dataflowPipeline 'dataflow-pipeline-l4.bicep' = {
  name: 'dataflowPipeline'
  params: {
    aioInstanceName: aioInstanceName
    customLocationName: customLocationName
    l4KafkaDataflowEndpointName: dataflowEndpoint.outputs.l4KafkaDataflowEndpointName
    l4MqttDataflowEndpointName: dataflowEndpoint.outputs.l4MqttDataflowEndpointName
  }
}
