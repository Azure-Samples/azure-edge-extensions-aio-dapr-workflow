param aioInstanceName string
param customLocationName string
param l3MqttDataflowEndpointName string
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

resource dataflowl3l4 'Microsoft.IoTOperations/instances/dataflowProfiles/dataflows@2024-11-01' = {
  parent: defaultDataflowProfile
  name: 'opc-l3-data-to-l4'
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
          endpointRef: l3MqttDataflowEndpointName
          dataSources: [
            'data/opc'
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
          dataDestination: 'data/site1'
        }
      }
    ]
  }
}

resource dataflowl4l3 'Microsoft.IoTOperations/instances/dataflowProfiles/dataflows@2024-11-01' = {
  // Reference to the parent dataflow profile, the default profile in this case
  // Same usage as profileRef in Kubernetes YAML
  parent: defaultDataflowProfile
  name: 'kafka-l4-data-to-l3'
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
          endpointRef: l4MqttDataflowEndpointName
          dataSources: [
            'data/kafka'
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
          endpointRef: l3MqttDataflowEndpointName
          dataDestination: 'data/kafka-l4'
        }
      }
    ]
  }
}
