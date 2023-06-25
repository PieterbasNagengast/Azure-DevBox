targetScope = 'subscription'

param location string = deployment().location
param DevCenter object

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: DevCenter.resourceGroupName
  location: location
}

// deploy DevCenter
module devCenter 'modules/DevCenter.bicep' = {
  name: 'DevCenter'
  scope: rg
  params: {
    location: location
    devCenterName: DevCenter.name
  }
}

// deploy DevCenter builtin images
module devCenterBuiltinImages 'modules/DevCenterImage.bicep' = [for (definition, i) in DevCenter.definitions: {
  name: 'DeCenterImage${i}'
  scope: rg
  params: {
    location: location
    DevCenterDefinitionName: definition.name
    DevCenterGalleryImageName: definition.image
    DevCenterGalleryName: 'Default'
    DevCenterName: devCenter.outputs.Name
    imageSKU: definition.vmSKU
    imageStorageType: definition.diskSize
  }
}]

output devCenterID string = devCenter.outputs.Id
output devCenterName string = devCenter.outputs.Name
