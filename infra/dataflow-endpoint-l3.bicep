// ------------------------------------------------------------
// Parameters
// ------------------------------------------------------------

@description('AIO Instance Name')
param aioInstanceName string

@description('Custom Location Name')
param customLocationName string

resource aioInstance 'Microsoft.IoTOperations/instances@2024-11-01' existing = {
  name: aioInstanceName
}

resource customLocation 'Microsoft.ExtendedLocation/customLocations@2021-08-31-preview' existing = {
  name: customLocationName
}

// ------------------------------------------------------------
// Dataflow Endpoints
// ------------------------------------------------------------

resource l3MqttBrokerDataflowEndpoint 'Microsoft.IoTOperations/instances/dataflowEndpoints@2024-11-01' = {
  parent: aioInstance
  name: 'mqtt-local'
  extendedLocation: {
    name: customLocation.id
    type: 'CustomLocation'
  }
  properties: {
    endpointType: 'Mqtt'
    mqttSettings: {
      host: 'aio-broker:18083'
      authentication: {
        method: 'Anonymous'
      }
      protocol: 'WebSockets'
      keepAliveSeconds: 60
      maxInflightMessages: 100
      sessionExpirySeconds: 3600
      retain: 'Keep'
      qos: 1
      clientIdPrefix: 'local-mqtt-client'
      cloudEventAttributes: 'Propagate'
      tls: {
        mode: 'Enabled'
        trustedCaCertificateConfigMapRef: 'azure-iot-operations-aio-ca-trust-bundle'
      }
    }
  }
}

resource l4MqttBrokerDataflowEndpoint 'Microsoft.IoTOperations/instances/dataflowEndpoints@2024-11-01' = {
  parent: aioInstance
  name: 'mqtt-l4'
  extendedLocation: {
    name: customLocation.id
    type: 'CustomLocation'
  }
  properties: {
    endpointType: 'Mqtt'
    mqttSettings: {
      host: 'aio-broker.corp.contoso.com:18083'
      authentication: {
        method: 'Anonymous'
      }
      protocol: 'WebSockets'
      keepAliveSeconds: 60
      maxInflightMessages: 100
      sessionExpirySeconds: 3600
      retain: 'Keep'
      qos: 1
      clientIdPrefix: 'l4-client'
      cloudEventAttributes: 'Propagate'
      tls: {
        mode: 'Enabled'
        trustedCaCertificateConfigMapRef: 'l4-client-ca-configmap'
      }
    }
  }
}

// ------------------------------------------------------------
// Outputs
// ------------------------------------------------------------

@description('L3 Mqtt Dataflow Endpoint Name')
output l3MqttDataflowEndpointName string = l3MqttBrokerDataflowEndpoint.name

@description('L4 Mqtt Dataflow Endpoint Name')
output l4MqttDataflowEndpointName string = l4MqttBrokerDataflowEndpoint.name
