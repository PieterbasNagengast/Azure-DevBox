param location string
param SubnetID string
param NetworkConnectionName string
param networkingResourceGroupName string

// Deploy DevCenter Network Connection
resource NetworkConnection 'Microsoft.DevCenter/networkConnections@2023-04-01' = {
  name: NetworkConnectionName
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: SubnetID
    networkingResourceGroupName: networkingResourceGroupName
  }
}

output networkConnectionID string = NetworkConnection.id
output networkConnectionName string = NetworkConnection.name
