using '../main.bicep'

// SQL Server
param postgreSQLServerName = 'safebank-dbsrv-prod'
param adminLogin = ''
param adminLoginPass = ''

// SQL DB
param postgreSQLDatabaseName = 'safebank-db-prod'

// Satic Website (frontend)
param staticWebAppName = 'safebank-swa-prod'
param staticWebAppLocation = 'westeurope'
// param feRepositoryUrl = 'https://github.com/ie-safebank/safebank-fe'
param staticWebAppTokenName = 'swa-token'

// Container Instance (backend)
param containerName = 'safebank-be-prod'
param dockerRegistryImageName = 'safebank-be'
param dockerRegistryImageVersion = 'latest'
param containerAppSettings = [
  { name: 'ENV', value: 'prod' }
  { name: 'DBHOST', value: 'safebank-dbsrv-prod.postgres.database.azure.com' }
  { name: 'DBNAME', value: 'safebank-db-prod' }
  { name: 'DBUSER', value: 'safebank-be-prod' }
  { name: 'FLASK_DEBUG', value: '1' }
  { name: 'SCM_DO_BUILD_DURING_DEPLOYMENT', value:'true' }
]

// Container Registry
param registryName = 'safebankcrprod'
param registryLocation = 'westeurope'
param containerRegistryUsernameSecretName = 'acr-username'
param containerRegistryPassword0SecretName = 'acr-password0'
param containerRegistryPassword1SecretName = 'acr-password1'

// Key Vault
param keyVaultName = 'safebank-kv-prod'
param keyVaultRoleAssignments= [
  {
    principalId: '25d8d697-c4a2-479f-96e0-15593a830ae5' // BCSAI2024-DEVOPS-STUDENTS-A-SP
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

// Log Analytics Workspace
param logAnalyticsWorkspaceName = 'safebank-law-prod'

// Application Insights
param appInsightsName = 'safebank-ai-prod'
param appInsightsKeyName = 'appInsightsKey'
param appInsightsConnectionName = 'appInsightsConnection'

// App Service Plan
param appServicePlanName = 'safebank-asp-prod'

// Workbook Parameters
param workbookName = 'safebank-workbook-prod'
param workbookJson = loadTextContent('../templates/safe-bank-workbook-prod.workbook')

param logicAppName = 'safebank-la-prod'

param slackWebhookUrl = ''
