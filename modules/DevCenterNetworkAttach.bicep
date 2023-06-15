param devCenterName string
param networkConnectionID string
param networkAttachName string

// Attach DevCenter Network Connection to DevCenter
resource networkAttach 'Microsoft.DevCenter/devcenters/attachednetworks@2023-04-01' = {
  name: '${devCenterName}/${networkAttachName}'
  properties: {
    networkConnectionId: networkConnectionID
  }
}

output NetworkAttachName string = networkAttach.name
