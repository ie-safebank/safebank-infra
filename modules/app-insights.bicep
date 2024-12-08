@description('Name of the Application Insights resource')
param name string

@description('Region where the Application Insights resource will be deployed')
param location string

@description('Tags to assign to the Application Insights resource')
param tagsArray object = {}

@description('Type of Application Insights (e.g., web, other types)')
param type string

@description('Resource ID of the linked Log Analytics Workspace')
param workspaceResourceId string

param keyVaultResourceId string
#disable-next-line secure-secrets-in-params
param appInsightsKeyName string
#disable-next-line secure-secrets-in-params
param appInsightsConnectionName string

resource appInsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: name
  location: location
  kind: 'web'
  tags: tagsArray
  properties: {
    Application_Type: type
    Flow_Type: 'Redfield'
    WorkspaceResourceId: workspaceResourceId
    IngestionMode: 'LogAnalytics'
  }
}

// Reference the existing Key Vault
resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: last(split(keyVaultResourceId, '/')) // Extract the name from the resource ID
}

resource appInsightsKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: appInsightsKeyName
  parent: adminCredentialsKeyVault
  properties: {
    value: appInsights.properties.InstrumentationKey
  }
}

resource appInsightsConnection 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: appInsightsConnectionName
  parent: adminCredentialsKeyVault
  properties: {
    value: appInsights.properties.ConnectionString
  }
}

output appInsightsId string = appInsights.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
