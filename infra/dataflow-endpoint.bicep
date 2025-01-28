param aioInstanceName string
param customLocationName string

output l3MqttDataflowEndpointName string = defaultMqttBrokerDataflowEndpoint.name
output l4MqttDataflowEndpointName string = l4MqttBrokerDataflowEndpoint.name

resource aioInstance 'Microsoft.IoTOperations/instances@2024-11-01' existing = {
  name: aioInstanceName
}

resource customLocation 'Microsoft.ExtendedLocation/customLocations@2021-08-31-preview' existing = {
  name: customLocationName
}

resource defaultMqttBrokerDataflowEndpoint 'Microsoft.IoTOperations/instances/dataflowEndpoints@2024-11-01' = {
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
