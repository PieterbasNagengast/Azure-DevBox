param location string = resourceGroup().location

param DevCenterName string = 'DevCenter01'
param DevVNETname string = 'DevVNET01'

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: DevVNETname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

// DevBox Infra

// Deploy DevCenter 
resource DevCenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' = {
  name: DevCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

// Deploy DevBox Definition (Image + SKU + StorageType)
resource Definition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-01-01-preview' = {
  name: 'DevBoxDefinition01'
  parent: DevCenter
  location: location
  properties: {
    imageReference: {
      id: '${resourceId('Microsoft.DevCenter/devcenters/galleries', DevCenterName, 'Default')}/images/microsoftwindowsdesktop_windows-ent-cpc_win11-22h2-ent-cpc-os'
    }
    sku: {
      name: 'general_a_8c32gb_v1'
    }
    osStorageType: 'ssd_1024gb'
  }
}

// DevBox DevTeam
// Note1: networkingResourceGroupName is the name of the resource group where the NIC's will be created
resource NetworkConnection 'Microsoft.DevCenter/networkConnections@2023-01-01-preview' = {
  name: '${DevVNETname}-connection'
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: vnet.properties.subnets[0].id
    networkingResourceGroupName: '${resourceGroup().name}-nics'
  }
}

resource Project 'Microsoft.DevCenter/projects@2023-01-01-preview' = {
  name: 'Project01'
  location: location
  properties: {
    devCenterId: DevCenter.id
    description: 'This is a sample project'
  }
}

resource NetworkAttach 'Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview' = {
  name: '${DevVNETname}-attach'
  parent: DevCenter
  properties: {
    networkConnectionId: NetworkConnection.id
  }
}

resource ProjectPool 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' = {
  name: 'Pool01'
  parent: Project
  location: location
  properties: {
    licenseType: 'Windows_Client'
    networkConnectionName: NetworkAttach.name
    devBoxDefinitionName: Definition.name
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Enabled'
    }
    localAdministrator: 'Enabled'
  }
}

// role assignment on Project for role name: 'DevCenter Project Admin' / role id: 331c37c6-af14-46d9-b9f4-e1909e1b95a0
