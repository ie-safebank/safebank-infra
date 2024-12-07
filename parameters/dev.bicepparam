using '../main.bicep'

// SQL Server
param postgreSQLServerName = 'safebank-dbsrv-dev'
param adminLogin = ''
param adminLoginPass = ''

// SQL DB
param postgreSQLDatabaseName = 'safebank-db-dev'

// Satic Website (frontend)
param staticWebAppName = 'safebank-swa-dev'
param staticWebAppLocation = 'westeurope'
// param feRepositoryUrl = 'https://github.com/ie-safebank/safebank-fe'
param staticWebAppTokenName = 'swa-token'

// Container Instance (backend)
param containerName = 'safebank-be-dev'
param dockerRegistryImageName = 'safebank-be'
param dockerRegistryImageVersion = 'latest'
param containerAppSettings = [
  { name: 'ENV', value: 'dev' }
  { name: 'DBHOST', value: 'safebank-dbsrv-dev.postgres.database.azure.com' }
  { name: 'DBNAME', value: 'safebank-db-dev' }
  { name: 'DBUSER', value: 'safebank-be-dev' }
  { name: 'FLASK_DEBUG', value: '1' }
  { name: 'SCM_DO_BUILD_DURING_DEPLOYMENT', value:'true' }
]

// Container Registry
param registryName = 'safebankcrdev'
param registryLocation = 'westeurope'
param containerRegistryUsernameSecretName = 'acr-username'
param containerRegistryPassword0SecretName = 'acr-password0'
param containerRegistryPassword1SecretName = 'acr-password1'

// Key Vault
param keyVaultName = 'safebank-kv-dev'
param keyVaultRoleAssignments= [
  {
    principalId: '25d8d697-c4a2-479f-96e0-15593a830ae5' // BCSAI2024-DEVOPS-STUDENTS-A-SP
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

// Log Analytics Workspace
param logAnalyticsWorkspaceName = 'safebank-law-dev'

// Application Insights
param appInsightsName = 'safebank-ai-dev'

// App Service Plan
param appServicePlanName = 'safebank-asp-dev'

// Workbook Parameters
param workbookName = 'safebank-workbook-dev'
param workbookJson = loadTextContent('../templates/safe-bank-workbook.workbook')

param logicAppName = 'safebank-la-dev'

param slackWebhookUrl = ''
