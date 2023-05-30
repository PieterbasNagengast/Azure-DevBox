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

// #disable-next-line BCP081
resource ProjectPool 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' = {
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
