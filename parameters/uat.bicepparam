using '../main.bicep'

// SQL Server
param postgreSQLServerName = 'safebank-dbsrv-uat'
param adminLogin = ''
param adminLoginPass = ''

// SQL DB
param postgreSQLDatabaseName = 'safebank-db-uat'

// Satic Website (frontend)
param staticWebAppName = 'safebank-swa-uat'
param staticWebAppLocation = 'westeurope'
// param feRepositoryUrl = 'https://github.com/ie-safebank/safebank-fe'
param staticWebAppTokenName = 'swa-token'

// Container Instance (backend)
param containerName = 'safebank-be-uat'
param dockerRegistryImageName = 'safebank-be'
param dockerRegistryImageVersion = 'latest'
param containerAppSettings = [
  { name: 'ENV', value: 'uat' }
  { name: 'DBHOST', value: 'safebank-dbsrv-uat.postgres.database.azure.com' }
  { name: 'DBNAME', value: 'safebank-db-uat' }
  { name: 'DBUSER', value: 'safebank-be-uat' }
  { name: 'FLASK_DEBUG', value: '1' }
  { name: 'SCM_DO_BUILD_DURING_DEPLOYMENT', value:'true' }
]

// Container Registry
param registryName = 'safebankcruat'
param registryLocation = 'westeurope'
param containerRegistryUsernameSecretName = 'acr-username'
param containerRegistryPassword0SecretName = 'acr-password0'
param containerRegistryPassword1SecretName = 'acr-password1'

// Key Vault
param keyVaultName = 'safebank-kv-uat'
param keyVaultRoleAssignments= [
  {
    principalId: '25d8d697-c4a2-479f-96e0-15593a830ae5' // BCSAI2024-DEVOPS-STUDENTS-A-SP
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

// Log Analytics Workspace
param logAnalyticsWorkspaceName = 'safebank-law-uat'

// Application Insights
param appInsightsName = 'safebank-ai-uat'

// App Service Plan
param appServicePlanName = 'safebank-asp-uat'

// Workbook Parameters
param workbookName = 'safebank-workbook-uat'
param workbookJson = loadTextContent('../templates/safe-bank-workbook.workbook')

param logicAppName = 'safebank-la-uat'

param slackWebhookUrl = ''
