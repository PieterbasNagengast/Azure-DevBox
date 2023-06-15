param location string
param DevCenterName string
param DevCenterGalleryName string
param DevCenterGalleryImageName string
param DevCenterDefinitionName string

@allowed([
  'general_a_8c32gb_v1'
])
param imageSKU string
@allowed([
  'ssd_256gb'
  'ssd_512gb'
  'ssd_1024gb'
])
param imageStorageType string

resource DevCenter 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  name: DevCenterName
}

resource DevCenterGallery 'Microsoft.DevCenter/devcenters/galleries@2023-04-01' existing = {
  name: DevCenterGalleryName
  parent: DevCenter
}

resource image 'Microsoft.DevCenter/devcenters/galleries/images@2023-04-01' existing = {
  name: DevCenterGalleryImageName
  parent: DevCenterGallery
}

resource Definition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01' = {
  name: DevCenterDefinitionName
  parent: DevCenter
  location: location
  properties: {
    imageReference: {
      id: image.id
    }
    sku: {
      name: imageSKU
    }
    osStorageType: imageStorageType
  }
}

output imageID string = image.id
output imageDescription string = image.properties.description
output imagePublisher string = image.properties.publisher
output imageOffer string = image.properties.offer
output imageSKU string = image.properties.sku
