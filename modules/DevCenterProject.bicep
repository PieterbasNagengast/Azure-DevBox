param location string
param roleAssignments array
param ProjectName string
param ProjectDescription string
param DevCenterID string

resource Project 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: ProjectName
  location: location
  properties: {
    devCenterId: DevCenterID
    description: ProjectDescription
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleAssignment in roleAssignments: {
  name: guid(Project.id, roleAssignment.roleID, roleAssignment.principalID)
  scope: Project
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleID)
    principalId: roleAssignment.principalID
    principalType: roleAssignment.principalType
  }
}]

output Id string = Project.id
output Name string = Project.name
