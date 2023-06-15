param location string
param devCenterName string

// Deploy DevCenter
resource devCenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

output Id string = devCenter.id
output Name string = devCenter.name
