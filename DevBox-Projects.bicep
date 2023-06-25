targetScope = 'subscription'

param location string
param devCenterProject object
param devCenterID string
param resourceGroupName string

// deploy resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

// deploy DevCenter Project including role assignments
module DevCenterProject 'modules/DevCenterProject.bicep' = {
  name: 'DevCenter${devCenterProject.name}'
  scope: rg
  params: {
    location: location
    ProjectDescription: devCenterProject.description
    ProjectName: devCenterProject.name
    roleAssignments: devCenterProject.roleAssignments
    DevCenterID: devCenterID
  }
}

// deploy DevCenter Porject Pools
module DevCenterPools 'modules/DevCenterProjectPools.bicep' = [for (pool, i) in devCenterProject.pools: {
  name: '${DevCenterProject.name}pool${i}'
  scope: rg
  params: {
    location: location
    DevCenterProjectName: DevCenterProject.outputs.Name
    devBoxDefinitionName: pool.definitionName
    networkConnectionName: pool.networkConnectionName
    gracePeriodMinutes: pool.gracePeriodMinutes
    localAdministrator: pool.localAdministrator
    stopOnDisconnect: pool.stopOnDisconnect
    deploySchedule: !empty(pool.schedule)
    scheduleTime: !empty(pool.schedule) ? pool.schedule.time : ''
    scheduleTimeZone: !empty(pool.schedule) ? pool.schedule.timeZone : ''
  }
}]
