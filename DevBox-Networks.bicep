targetScope = 'subscription'

param location string
param subnetID string
param resourceGroupName string
param DevCenterName string
param DevCenterSubscriptionID string
param networkAttachName string

var networkNamePrefix = '${split(subnetID, '/')[8]}-${last(split(subnetID, '/'))}'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module devCenterNetworkConnection 'modules/DevCenterNetworkConnection.bicep' = {
  name: '${networkNamePrefix}-NetworkConnection'
  scope: rg
  params: {
    location: location
    SubnetID: subnetID
    NetworkConnectionName: '${networkNamePrefix}-NetworkConnection'
    networkingResourceGroupName: '${resourceGroupName}-nics'
  }
}

module devCenterNetworkAttach 'modules/DevCenterNetworkAttach.bicep' = {
  name: networkAttachName
  scope: resourceGroup(DevCenterSubscriptionID, resourceGroupName)
  params: {
    devCenterName: DevCenterName
    networkConnectionID: devCenterNetworkConnection.outputs.networkConnectionID
    networkAttachName: networkAttachName
  }
}
