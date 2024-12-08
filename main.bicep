@sys.description('The environment type (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
@sys.description('The user alias to add to the deployment name')
param userAlias string = 'safebank'
@sys.description('The Azure location where the resources will be deployed')
param location string = 'northeurope'

// Log Analytics Workspace
@sys.description('The name of the Log Analytics Workspace')
param logAnalyticsWorkspaceName string


module logAnalyticsWorkspace 'modules/log-analytics-workspace.bicep' = {
  name: 'logAnalyticsWorkspace-${userAlias}'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    sku: 'PerGB2018'
    tags: {
      environment: environmentType
      owner: userAlias
    }
  }
}


// App Insights
@sys.description('The name of the Application Insights instance')
param appInsightsName string
@sys.description('The name of the Key Vault secret for the App Insights Instrumentation Key')
param appInsightsKeyName string
@sys.description('The name of the Key Vault secret for the App Insights Connection String')
param appInsightsConnectionName string

module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights-${userAlias}'
  params: {
    name: appInsightsName
    type: 'web' 
    location: location 
    keyVaultResourceId: keyVault.outputs.keyVaultId
    appInsightsKeyName: appInsightsKeyName
    appInsightsConnectionName: appInsightsConnectionName
    tagsArray: {
      environment: environmentType
      owner: userAlias
    }
    workspaceResourceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId // Link to the Log Analytics Workspace
  }
}

@description('The name of the Workbook')
param workbookName string

@description('The JSON template')
@secure()
param workbookJson string

module workbook 'modules/workbook.bicep' = {
  name: 'workbookDeployment'
  params: {
    workbookName: workbookName
    location: resourceGroup().location
    workbookJson: workbookJson
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [logAnalyticsWorkspace]
}

// Key Vault
@sys.description('The name of the Key Vault')
param keyVaultName string
@sys.description('Role assignments for the Key Vault')
param keyVaultRoleAssignments array = []

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault-${userAlias}'
  params: {
    name: keyVaultName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
    enableRbacAuthorization: true
    enableVaultForTemplateDeployment: true
    enableVaultForDeployment: true 
    enableSoftDelete: true
    roleAssignments: keyVaultRoleAssignments
  }
}

// Container Registry
@description('The name of the container registry')
param registryName string
@description('The location of the container registry')
param registryLocation string
param containerRegistryUsernameSecretName string 
param containerRegistryPassword0SecretName string 
param containerRegistryPassword1SecretName string 

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry-${userAlias}'
  params: {
    name: registryName
    location: registryLocation
    keyVaultResourceId: keyVault.outputs.keyVaultId
    usernameSecretName: containerRegistryUsernameSecretName
    password0SecretName: containerRegistryPassword0SecretName
    password1SecretName: containerRegistryPassword1SecretName
    workspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    keyVault
  ]
}


// App Service Plan
@sys.description('The name of the App Service Plan')
param appServicePlanName string

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan-${userAlias}'
  params: {
    location: location
    name: appServicePlanName
    sku: 'B1'
  }
}

// Container App Service
param containerName string
param dockerRegistryImageName string
param dockerRegistryImageVersion string
param containerAppSettings array
@secure()
param adminUsername string = '' // Default to empty string which will be filled with the values in the key vault
@secure()
param adminPassword string = ''

resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01'existing = {
  name: keyVaultName
}

module containerAppService 'modules/container-appservice.bicep' = {
  name: 'containerAppService-${userAlias}'
  params: {
    workspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
    location: location
    name: containerName
    appServicePlanId: appServicePlan.outputs.id
    registryName: registryName
    registryServerUserName: keyVaultReference.getSecret(containerRegistryUsernameSecretName)
    registryServerPassword: keyVaultReference.getSecret(containerRegistryPassword0SecretName)
    registryImageName: dockerRegistryImageName
    registryImageVersion: dockerRegistryImageVersion
    connectionStrings: appInsights.outputs.appInsightsConnectionString
    instrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    adminUsername: adminUsername
    adminPassword: adminPassword
    appSettings: containerAppSettings
    appCommandLine: ''
  }
  dependsOn: [
    appServicePlan
    containerRegistry
    keyVault
  ]
}

// PostgreSQL Server
@sys.description('The name of the PostgreSQL Server')
param postgreSQLServerName string

@secure()
param adminLogin string
@secure()
param adminLoginPass string

module postgreSQLServer 'modules/postgre-sql-server.bicep' = {
  name: 'postgreSQLServer-${userAlias}'
  params: {
    name: postgreSQLServerName
    location: location
    adminLogin: adminLogin
    adminPassword: adminLoginPass
    WorkspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
    postgresSQLAdminServicePrincipalObjectId: containerAppService.outputs.systemAssignedIdentityPrincipalId
    postgresSQLAdminServicePrincipalName: containerName
  }
  dependsOn: [
    containerAppService
  ]
}


// PostgreSQL Database
@sys.description('The name of the PostgreSQL Database')
param postgreSQLDatabaseName string

module postgreSQLDatabase 'modules/postgre-sql-db.bicep' = {
  name: postgreSQLDatabaseName
  params: {
    serverName: postgreSQLServerName
    name: postgreSQLDatabaseName
  }
  dependsOn: [
    postgreSQLServer
  ]
}

// Static Web App
@sys.description('The name of the Static Web App')
param staticWebAppName string
@sys.description('The location of the Static Web App')
param staticWebAppLocation string
param staticWebAppTokenName string

module staticWebApp 'modules/static-webapp.bicep' = {
  name: 'staticWebApp-${userAlias}'
  params: {
    name: staticWebAppName
    location: staticWebAppLocation
    keyVaultResourceId: keyVault.outputs.keyVaultId
    tokenName: staticWebAppTokenName
  }
}

// Logic App

@description('The name of the Logic App')
param logicAppName string

@description('Slack Webhook URL for sending alerts')
@secure()
param slackWebhookUrl string

module logicApp 'modules/slack-logicapp.bicep' = {
  name: logicAppName
  params: {
    location: location
    logicAppName: logicAppName
    slackWebhookUrl: slackWebhookUrl
  }
  dependsOn: [
    staticWebApp
  ]
}
