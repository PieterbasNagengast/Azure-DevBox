targetScope = 'subscription'
param location string = deployment().location

@description('Subscription ID where Dev Center will be deployed')
param subscriptionID string

@description('Dev Center Name')
param DevCenterName string

@description('Default resource Group')
param resourceGroupName string

@description('Array of Networks to be used in Dev Center. Name, Location and Subnet resourceID')
param networks array

@description('Array of Projects and Pools to be used in Dev Center')
param projects array

@description('Array of Image Definitions to be used in Dev Center')
param definitions array

var DevCenter = {
  name: DevCenterName
  resourceGroupName: resourceGroupName
  subscriptionID: subscriptionID
  networks: networks
  projects: projects
  definitions: definitions
}

// Deploy DevCenter
module devCenterInfra 'DevBox-Infra.bicep' = {
  name: 'DevCenterInfra'
  scope: subscription(DevCenter.subscriptionID)
  params: {
    location: location
    DevCenter: DevCenter
  }
}

// Deploy Virtual Network Connections
module devCenterNetworkConnections 'DevBox-Networks.bicep' = [for (network, i) in DevCenter.networks: {
  name: 'DevCenterNetworkConnection${i}'
  scope: subscription(split(network.subnetID, '/')[2])
  params: {
    location: network.location
    subnetID: network.subnetID
    resourceGroupName: DevCenter.resourceGroupName
    DevCenterName: devCenterInfra.outputs.devCenterName
    DevCenterSubscriptionID: DevCenter.subscriptionID
    networkAttachName: network.name
  }
}]

// Deploy projects and pools
module devCenterProjectsAndPools 'DevBox-Projects.bicep' = [for (project, i) in DevCenter.projects: {
  name: 'DevCenterProject${i}'
  scope: subscription(DevCenter.subscriptionID)
  dependsOn: [
    devCenterNetworkConnections
  ]
  params: {
    location: location
    resourceGroupName: DevCenter.resourceGroupName
    devCenterID: devCenterInfra.outputs.devCenterID
    devCenterProject: project
  }
}]
