param location string
param DevCenterProjectName string
param LicenseType string = 'Windows_Client'
param networkConnectionName string
param devBoxDefinitionName string
@allowed([
  'Enabled'
  'Disabled'
])
param localAdministrator string
@minValue(60)
param gracePeriodMinutes int
@allowed([
  'Enabled'
  'Disabled'
])
param stopOnDisconnect string
param deploySchedule bool
param scheduleTime string = '00:00:00'
param scheduleTimeZone string = 'Europe/Amsterdam'
@allowed([
  'Daily'
])
param scheduleFrequency string = 'Daily'
@allowed([
  'StopDevBox'
])
param scheduletype string = 'StopDevBox'

resource ProjectPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: '${DevCenterProjectName}/${devBoxDefinitionName}'
  location: location
  properties: {
    licenseType: LicenseType
    networkConnectionName: networkConnectionName
    devBoxDefinitionName: devBoxDefinitionName
    stopOnDisconnect: {
      gracePeriodMinutes: gracePeriodMinutes
      status: stopOnDisconnect
    }
    localAdministrator: localAdministrator
  }
}

resource ProjectSchedule 'Microsoft.DevCenter/projects/pools/schedules@2023-04-01' = {
  name: 'default'
  parent: ProjectPool
  properties: {
    timeZone: deploySchedule ? scheduleTimeZone : 'UTC'
    frequency: deploySchedule ? scheduleFrequency : 'Daily'
    state: deploySchedule ? 'Enabled' : 'Disabled'
    time: deploySchedule ? scheduleTime : '00:00'
    type: deploySchedule ? scheduletype : 'StopDevBox'
  }
}
