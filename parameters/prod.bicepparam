using '../main.bicep'

param environmentType = 'prod'
param postgreSQLServerName = 'safebank-dbsrv-prod'
param postgreSQLDatabaseName = 'safebank-db-prod'
param appServicePlanName = 'safebank-asp-prod'
param appServiceAPIAppName = 'safebank-be-prod'
param appServiceAppName = 'safebank-fe-prod'
param location = 'North Europe'
param appServiceAPIDBHostFLASK_APP =  'iebank_api\\__init__.py'
param appServiceAPIDBHostFLASK_DEBUG =  '1'
param appServiceAPIDBHostDBUSER = 'github-secret-replaced-in-workflow'
param appServiceAPIEnvVarDBPASS =  'github-secret-replaced-in-workflow'
param appServiceAPIEnvVarDBHOST =  'safebank-dbsrv-prod.postgres.database.azure.com'
param appServiceAPIEnvVarDBNAME =  'safebank-db-prod'
param appServiceAPIEnvVarENV =  'prod'

param staticWebAppName = 'safebank-swa-prod'
param staticWebAppLocation = 'westeurope'

param registryName = 'safebankcrprod'
