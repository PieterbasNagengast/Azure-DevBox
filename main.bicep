param location string = resourceGroup().location

param DevVNETname string = 'DevVNET01'

param DevCenterSettings object = {
  name: 'DevCenter01'
  definitions: [
    {
      name: 'W11'
      image: 'microsoftwindowsdesktop_windows-ent-cpc_win11-22h2-ent-cpc-os'
      diskSize: 'ssd_1024gb'
      vmSKU: 'general_a_8c32gb_v1'
    }
    {
      name: 'W11_M365'
      image: 'microsoftwindowsdesktop_windows-ent-cpc_win11-22h2-ent-cpc-m365'
      diskSize: 'ssd_1024gb'
      vmSKU: 'general_a_8c32gb_v1'
    }

    {
      name: 'W11_M365_VS2022'
      image: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
      diskSize: 'ssd_1024gb'
      vmSKU: 'general_a_8c32gb_v1'
    }
  ]
}

// // Supported DevCenter builtin Gallery images
// 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os'
// 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
// 'microsoftwindowsdesktop_windows-ent-cpc_win10-21h2-ent-cpc-os-g2'
// 'microsoftwindowsdesktop_windows-ent-cpc_win10-21h2-ent-cpc-m365-g2'
// 'microsoftwindowsdesktop_windows-ent-cpc_21h1-ent-cpc-os-g2'
// 'microsoftwindowsdesktop_windows-ent-cpc_21h1-ent-cpc-m365-g2'
// 'microsoftwindowsdesktop_windows-ent-cpc_20h2-ent-cpc-os-g2'
// 'microsoftwindowsdesktop_windows-ent-cpc_20h2-ent-cpc-m365-g2'
// 'microsoftwindowsdesktop_windows-ent-cpc_win11-22h2-ent-cpc-os'
// 'microsoftwindowsdesktop_windows-ent-cpc_win11-22h2-ent-cpc-m365'
// 'microsoftwindowsdesktop_windows-ent-cpc_win10-22h2-ent-cpc-os'
// 'microsoftwindowsdesktop_windows-ent-cpc_win10-22h2-ent-cpc-m365'
// 'microsoftvisualstudio_visualstudio2019plustools_vs-2019-ent-general-win11-m365-gen2'
// 'microsoftvisualstudio_visualstudio2019plustools_vs-2019-pro-general-win11-m365-gen2'
// 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
// 'microsoftvisualstudio_visualstudioplustools_vs-2022-pro-general-win11-m365-gen2'
// 'microsoftvisualstudio_visualstudio2019plustools_vs-2019-ent-general-win10-m365-gen2'
// 'microsoftvisualstudio_visualstudio2019plustools_vs-2019-pro-general-win10-m365-gen2'
// 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win10-m365-gen2'
// 'microsoftvisualstudio_visualstudioplustools_vs-2022-pro-general-win10-m365-gen2'

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: DevVNETname
  // location: location
  // properties: {
  //   addressSpace: {
  //     addressPrefixes: [
  //       '10.0.0.0/16'
  //     ]
  //   }
  //   subnets: [
  //     {
  //       name: 'Subnet-1'
  //       properties: {
  //         addressPrefix: '10.0.0.0/24'
  //       }
  //     }
  //     {
  //       name: 'Subnet-2'
  //       properties: {
  //         addressPrefix: '10.0.1.0/24'
  //       }
  //     }
  //   ]
  // }
}

// DevBox Infra

// Deploy DevCenter
#disable-next-line BCP081
resource DevCenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: DevCenterSettings.name
  location: location
  identity: {
    type: 'SystemAssigned'
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
  dependsOn: [
    DevCenter
  ]
}

resource NetworkAttach 'Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview' = {
  name: '${DevVNETname}-attach'
  parent: DevCenter
  properties: {
    networkConnectionId: NetworkConnection.id
  }
}

module DevCenterBuiltinImages 'modules/DevCenterImage.bicep' = [for (definition, i) in DevCenterSettings.definitions: {
  name: 'DeCenterImage${i}'
  params: {
    location: location
    DevCenterDefinitionName: definition.name
    DevCenterGalleryImageName: definition.image
    DevCenterGalleryName: 'Default'
    DevCenterName: DevCenter.name
    imageSKU: definition.vmSKU
    imageStorageType: definition.diskSize
  }
}]

resource Project 'Microsoft.DevCenter/projects@2023-01-01-preview' = {
  name: 'Project01'
  location: location
  properties: {
    devCenterId: DevCenter.id
    description: 'This is a sample project'
  }
}

module DevCenterProjectPools 'modules/DevCenterProjectPools.bicep' = [for (definition, i) in DevCenterSettings.definitions: {
  name: 'DevCenterProjectPool${i}'
  params: {
    location: location
    DevCenterProjectName: Project.name
    devBoxDefinitionName: definition.name

    localAdministrator: 'Enabled'
    networkConnectionName: NetworkAttach.name
    stopOnDisconnect: 'Enabled'
    gracePeriodMinutes: 60
  }
}]

// role assignment on Project for role name: 'DevCenter Project Admin' / role id: 331c37c6-af14-46d9-b9f4-e1909e1b95a0
