// ------------------------------------------------------------
// Parameters
// ------------------------------------------------------------

@description('AIO Instance Name')
param aioInstanceName string

@description('Custom Location Name')
param customLocationName string

@description('L4 Kafka Dataflow Endpoint Name')
param l4KafkaDataflowEndpointName string

@description('L4 MQTT Dataflow Endpoint Name')
param l4MqttDataflowEndpointName string

resource aioInstance 'Microsoft.IoTOperations/instances@2024-11-01' existing = {
  name: aioInstanceName
}

resource customLocation 'Microsoft.ExtendedLocation/customLocations@2021-08-31-preview' existing = {
  name: customLocationName
}

resource defaultDataflowProfile 'Microsoft.IoTOperations/instances/dataflowProfiles@2024-11-01' existing = {
  parent: aioInstance
  name: 'default'
}

// ------------------------------------------------------------
// Dataflow Endpoints
// ------------------------------------------------------------

resource dataflowkafkal4 'Microsoft.IoTOperations/instances/dataflowProfiles/dataflows@2024-11-01' = {
  parent: defaultDataflowProfile
  name: 'labs-kafka-data-to-l4'
  extendedLocation: {
    name: customLocation.id
    type: 'CustomLocation'
  }
  properties: {
    mode: 'Enabled'
    operations: [
      {
        operationType: 'Source'
        sourceSettings: {
          endpointRef: l4KafkaDataflowEndpointName
          dataSources: [
            'karen-ps_QCDHL_Results'
          ]
        }
      }
      {
        operationType: 'BuiltInTransformation'
        builtInTransformationSettings: {
          map: [
            {
              inputs: [
                '*'
              ]
              output: '*'
            }
          ]
        }
      }
      {
        operationType: 'Destination'
        destinationSettings: {
          endpointRef: l4MqttDataflowEndpointName
          dataDestination: 'data/kafka'
        }
      }
    ]
  }
}

