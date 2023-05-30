param location string = resourceGroup().location

// Compute Gallery
resource Gallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: 'DevBoxGallery'
  location: location
  properties: {
    description: 'DevBox Gallery'
  }
}

// VM Image definition
resource ImageDef 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: 'W11-VS2022-M365-ent-DevBox'
  parent: Gallery
  location: location
  properties: {
    identifier: {
      offer: 'AzureITis'
      publisher: 'W11-VS2022-M365-ent-DevBox'
      sku: 'gen2'
    }
    osState: 'Generalized'
    osType: 'Windows'
    description: 'custom Dev Box Image Definition'
    hyperVGeneration: 'V2'
    architecture: 'X64'
    features: [
      {
        name: 'SecurityType'
        value: 'TrustedLaunch'
      }
    ]
  }
}

// user assigned identity to be used by ImageTemplate
resource UserID 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'DevBoxIdentity'
  location: location
}

// roleassignment (b24988ac-6180-42a0-ab88-20f7382dd24c = Contributor)
resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, UserID.id)
  properties: {
    principalId: UserID.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalType: 'ServicePrincipal'
  }
}

// Create Image Template from marketplace image
resource ImageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-07-01' = {
  name: 'DevBoxImageTemplate'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${UserID.id}': {}
    }
  }
  properties: {
    source: {
      type: 'PlatformImage'
      offer: 'visualstudioplustools'
      publisher: 'microsoftvisualstudio'
      sku: 'vs-2022-ent-general-win11-m365-gen2'
      version: 'latest'
    }
    vmProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    distribute: [
      {
        galleryImageId: ImageDef.id
        excludeFromLatest: false
        runOutputName: 'runOutputImageVersion'
        type: 'SharedImage'
        storageAccountType: 'Standard_LRS'
        replicationRegions: [
          'westeurope'
        ]
        versioning: {
          scheme: 'Source'
        }
      }
    ]
  }
}

// // trigger build of VM image
// resource ImageTempalteTrigger 'Microsoft.VirtualMachineImages/imageTemplates/triggers@2022-07-01' = {
//   name: '${ImageTemplate.name}-trigger'
//   parent: ImageTemplate
//   properties: {
//     kind: 'SourceImage'
//   }
// }
