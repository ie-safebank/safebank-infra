@sys.description('The environment type (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
@sys.description('The user alias to add to the deployment name')
param userAlias string = 'rorosaga'
@sys.description('The App Service Plan name')
@minLength(3)
@maxLength(24)
param appServicePlanName string = 'ie-bank-app-sp-dev'
@sys.description('The Web App name (frontend)')
@minLength(3)
@maxLength(24)
param appServiceAppName string = 'ie-bank-dev'
@sys.description('The API App name (backend)')
@minLength(3)
@maxLength(24)
param appServiceAPIAppName string = 'ie-bank-api-dev'
@sys.description('The Azure location where the resources will be deployed')
param location string = resourceGroup().location
@sys.description('The value for the environment variable ENV')
param appServiceAPIEnvVarENV string
@sys.description('The value for the environment variable DBHOST')
param appServiceAPIEnvVarDBHOST string
@sys.description('The value for the environment variable DBNAME')
param appServiceAPIEnvVarDBNAME string
@sys.description('The value for the environment variable DBPASS')
@secure()
param appServiceAPIEnvVarDBPASS string
@sys.description('The value for the environment variable DBUSER')
param appServiceAPIDBHostDBUSER string
@sys.description('The value for the environment variable FLASK_APP')
param appServiceAPIDBHostFLASK_APP string
@sys.description('The value for the environment variable FLASK_DEBUG')
param appServiceAPIDBHostFLASK_DEBUG string

// Static Web App
@sys.description('The name of the Static Web App')
param staticWebAppName string
@sys.description('The Azure location where the Static Web App should be deployed')
param staticWebAppLocation string
@sys.description('The pricing tier for the Static Web App')
@allowed([
  'Free'
  'Standard'
])
param staticWebAppSkuName string = 'Free'
@sys.description('The SKU code for the pricing tier')
param staticWebAppSkuCode string = 'Free'
@sys.description('The URL of the repository where the source code is located')
param feRepositoryUrl string = 'https://github.com/rorosaga/safebank-fe'
@sys.description('The branch of the repository to use for deployments')
param feBranch string = 'main'
@sys.description('A secure token for accessing the repository if it is private')
@secure()
param feRepoToken string = ''
@sys.description('The folder containing the app code relative to the repository root')
param feAppLocation string = '/'
@sys.description('The folder containing the API code relative to the repository root')
param feApiLocation string = ''
@sys.description('The folder where the build artifacts are located')
param appArtifactLocation string = 'dist'

// Container Registry
@description('The name of the container registry')
param registryName string
@description('The Azure location where the container registry should be deployed')
param registryLocation string = 'westeurope'
@description('Zone redundancy for the container registry')
@allowed([
  'enabled'
  'disabled'
])
param zoneRedundancy string = 'disabled'
@description('The SKU for the container registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param registrySku string = 'Basic'
@description('Tags to apply to the container registry')
param tags object = {}
@description('Public network access for the container registry')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

// Key Vault
@description('The name of the Key Vault')
param keyVaultName string = 'safebank-kv-dev'
@sys.description('The role assignments for the Key Vault')
param keyVaultRoleAssignments array = []

module keyVault 'modules/key-vault.bicep' = {
  name: 'kv-${userAlias}'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: keyVaultRoleAssignments
  }
}


resource postgresSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: postgreSQLServerName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    // administratorLogin: 'iebankdbadmin'
    // administratorLoginPassword: 'IE.Bank.DB.Admin.Pa$$'
    createMode: 'Default'
    highAvailability: {
      mode: 'Disabled'
      standbyAvailabilityZone: ''
    }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    version: '15'
    authConfig: { activeDirectoryAuth: 'Enabled', passwordAuth: 'Enabled', tenantId: subscription().tenantId }
  }

  resource postgresSQLServerFirewallRules 'firewallRules@2022-12-01' = {
    name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
    properties: {
      endIpAddress: '0.0.0.0'
      startIpAddress: '0.0.0.0'
    }
  }
}

resource postgresSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: postgreSQLDatabaseName
  parent: postgresSQLServer
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}

resource postgreSQLAdministrators 'administrators@2022-12-01' = {
  name: postgreSQLAdminServicePrincipalObjectId
  properties: {
    principalName: postgreSQLAdminServicePrincipalName
    principalType: 'ServicePrincipal'
    tenantId: subscription().tenantId
  }
  dependsOn: [
    postgresSQLServerFirewallRules
  ]
}

output id string = postgresSQLServer.id
// PostgresSQL Database
@sys.description('The PostgreSQL Server admin password')
@secure()
param postgreSQLAdminPassword string
@sys.description('The PostgreSQL Server name')
@minLength(3)
@maxLength(24)
param postgreSQLServerName string = 'ie-bank-db-server-dev'
@sys.description('The PostgreSQL Database name')
@minLength(3)
@maxLength(24)
param postgreSQLDatabaseName string = 'ie-bank-db'

// Modules

module appService 'modules/app-service.bicep' = {
  name: 'appService-${userAlias}'
  params: {
    location: location
    environmentType: environmentType
    appServiceAppName: appServiceAppName
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanName: appServicePlanName
    appServiceAPIDBHostDBUSER: appServiceAPIDBHostDBUSER
    appServiceAPIDBHostFLASK_APP: appServiceAPIDBHostFLASK_APP
    appServiceAPIDBHostFLASK_DEBUG: appServiceAPIDBHostFLASK_DEBUG
    appServiceAPIEnvVarDBHOST: appServiceAPIEnvVarDBHOST
    appServiceAPIEnvVarDBNAME: appServiceAPIEnvVarDBNAME
    appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
    appServiceAPIEnvVarENV: appServiceAPIEnvVarENV
  }
  dependsOn: [
    postgresSQLServer
  ]
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName

module staticWebApp 'modules/static-webapp.bicep' = {
  name: 'staticWebApp-${userAlias}'
  params: {
    staticWebAppName: staticWebAppName
    staticWebAppLocation: staticWebAppLocation
    staticWebAppSkuName: staticWebAppSkuName
    staticWebAppSkuCode: staticWebAppSkuCode
    feRepositoryUrl: feRepositoryUrl
    feBranch: feBranch
    feRepoToken: feRepoToken
    feAppLocation: feAppLocation
    feApiLocation: feApiLocation
    appArtifactLocation: appArtifactLocation
  }
}

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry-${userAlias}'
  params: {
    registryName: registryName
    registryLocation: registryLocation
    zoneRedundancy: zoneRedundancy
    registrySku: registrySku
    tags: tags
    publicNetworkAccess: publicNetworkAccess
  }
}

var acrUsernameSecretName = 'acr-username'
var acrPassword0SecretName = 'acr-password0'
var acrPassword1SecretName = 'acr-password1'

resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01'existing = {
  name: keyVaultName
}

