@description('Name of the availability alert rule')
param availabilityAlertName string

@description('Description of the availability alert')
param availabilityAlertDescription string

@description('Severity of the availability alert (0: Critical, 1: Error, 2: Warning, 3: Informational)')
param availabilityAlertSeverity int

@description('Scope of the resource to monitor for availability')
param availabilityResourceScope string

@description('Name of the transaction speed alert rule')
param transactionSpeedAlertName string

@description('Description of the transaction speed alert')
param transactionSpeedAlertDescription string

@description('Severity of the transaction speed alert')
param transactionSpeedAlertSeverity int

@description('Scope of the resource to monitor for transaction speed')
param transactionSpeedResourceScope string

@description('Name of the API error rate alert rule')
param apiErrorRateAlertName string

@description('Description of the API error rate alert')
param apiErrorRateAlertDescription string

@description('Severity of the API error rate alert')
param apiErrorRateAlertSeverity int

@description('Scope of the resource to monitor for API error rate')
param apiErrorRateResourceScope string

@description('Action Group Resource ID')
param actionGroupId string

// System Availability Alert Rule
resource availabilityAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: availabilityAlertName
  location: 'global'
  properties: {
    description: availabilityAlertDescription
    severity: availabilityAlertSeverity
    enabled: true
    scopes: [
      availabilityResourceScope
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'SystemAvailability'
          criterionType: 'StaticThresholdCriterion'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'Availability'
          operator: 'LessThan'
          threshold: 99
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
        webHookProperties: {
          customMessage: 'System availability dropped below 100%. Please investigate.'
        }
      }
    ]
  }
}

// Transaction Speed Alert Rule
resource transactionSpeedAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: transactionSpeedAlertName
  location: 'global'
  properties: {
    description: transactionSpeedAlertDescription
    severity: transactionSpeedAlertSeverity
    enabled: true
    scopes: [
      transactionSpeedResourceScope
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'TransactionSpeed'
          criterionType: 'StaticThresholdCriterion'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'HttpResponseTime'
          operator: 'GreaterThan'
          threshold: 2
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
        webHookProperties: {
          customMessage: 'Transaction speed exceeded 2 seconds. Please investigate.'
        }
      }
    ]
  }
}

// API Error Rate Alert Rule
resource apiErrorRateAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: apiErrorRateAlertName
  location: 'global'
  properties: {
    description: apiErrorRateAlertDescription
    severity: apiErrorRateAlertSeverity
    enabled: true
    scopes: [
      apiErrorRateResourceScope
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ApiErrorRate'
          criterionType: 'StaticThresholdCriterion'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'Http5xx'
          operator: 'GreaterThan'
          threshold: 1
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
        webHookProperties: {
          customMessage: 'API error rate exceeded 1%. Please investigate.'
        }
      }
    ]
  }
}

