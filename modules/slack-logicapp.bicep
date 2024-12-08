@description('Location of the resource')
param location string = resourceGroup().location

@description('Name of the Logic App')
param logicAppName string

@description('Slack Webhook URL to send alerts')
@secure()
param slackWebhookUrl string

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    state: 'Enabled'
    definition: json(loadTextContent('./logicAppWorflowData.json'))
    parameters: {
      slackWebhookUrl: {
        value: slackWebhookUrl
      }
    }
  }
}
