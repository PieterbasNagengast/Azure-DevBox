using './main.bicep'

param subscriptionID = '<Subscription ID>'
param DevCenterName = '<Dev Center name>'
param resourceGroupName = '<Resource Group Name>'

param networks = [
  {
    name: 'Vnet01-WE-PROD-Subnet1'
    location: 'WestEurope'
    subnetID: '/subscriptions/<Subscription ID>/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/virtualNetworks/<VNET name>/subnets/<Subnet name>'
  }
  {
    name: 'Vnet02-UKS-PROD-Subnet1'
    location: 'UKSouth'
    subnetID: '/subscriptions/<Subscription ID>/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/virtualNetworks/<VNET name>/subnets/<Subnet name>'
  }
  {
    name: 'Vnet03-WE-DEV-Subnet1'
    location: 'WestEurope'
    subnetID: '/subscriptions/<Subscription ID>/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/virtualNetworks/<VNET name>/subnets/<Subnet name>'
  }
]
param projects = [
  {
    name: 'Project01'
    description: 'Project01 Description'
    pools: [
      {
        name: 'W11-Pool'
        definitionName: 'W11' // must be the same as the name in the param definitions block
        networkConnectionName: 'Vnet01-WE-PROD-Subnet1' // must be the same as the networkConnectionName in the networks parameter block
        localAdministrator: 'Enabled'
        stopOnDisconnect: 'Enabled'
        gracePeriodMinutes: 60
      }
      {
        name: 'W11_M365-Pool'
        definitionName: 'W11_M365' // must be the same as the name in the param definitions block
        networkConnectionName: 'Vnet02-UKS-PROD-Subnet1' // must be the same as the networkConnectionName in the networks parameter block
        localAdministrator: 'Enabled'
        stopOnDisconnect: 'Enabled'
        gracePeriodMinutes: 60
      }
      {
        name: 'W11_M365_VS2022-Pool'
        definitionName: 'W11_M365_VS2022' // must be the same as the name in the param definitions block
        networkConnectionName: 'Vnet03-WE-DEV-Subnet1' // must be the same as the networkConnectionName in the networks parameter block
        localAdministrator: 'Enabled'
        stopOnDisconnect: 'Enabled'
        gracePeriodMinutes: 60
      }
    ]
    roleAssignments: [
      {
        roleID: '331c37c6-af14-46d9-b9f4-e1909e1b95a0' // DevCenter Project Admin
        principalID: '<Object ID of the user, group or ServicePrincipal>' // User or Group or ServicePrincipal
        principalType: 'User' // User or Group or ServicePrincipal
      }
      {
        roleID: '45d50f46-0b78-4001-a660-4198cbe8cd05' // DevCenter DevBox User
        principalID: '<Object ID of the user, group or ServicePrincipal>' // User or Group or ServicePrincipal
        principalType: 'User' // User or Group or ServicePrincipal
      }
    ]
  }
  {
    name: 'Project02'
    description: 'Project02 Description'
    pools: [
      {
        name: 'W11-Pool'
        definitionName: 'W11' // must be the same as the name in the param definitions block
        networkConnectionName: 'Vnet03-WE-DEV-Subnet1' // must be the same as the networkConnectionName in the networks parameter block
        localAdministrator: 'Enabled'
        stopOnDisconnect: 'Enabled'
        gracePeriodMinutes: 60
      }
    ]
    roleAssignments: [
      {
        roleID: '331c37c6-af14-46d9-b9f4-e1909e1b95a0' // DevCenter Project Admin
        principalID: '<Object ID of the user, group or ServicePrincipal>' // User or Group or ServicePrincipal
        principalType: 'User' // User or Group or ServicePrincipal
      }
      {
        roleID: '45d50f46-0b78-4001-a660-4198cbe8cd05' // DevCenter DevBox User
        principalID: '<Object ID of the user, group or ServicePrincipal>' // User or Group or ServicePrincipal
        principalType: 'User' // User or Group or ServicePrincipal
      }
    ]
  }
]
param definitions = [
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
