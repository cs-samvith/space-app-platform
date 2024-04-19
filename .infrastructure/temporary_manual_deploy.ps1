# az account set --subscription "36a60b19-8b19-4171-a0d6-b5686ec92329"

$template = "app-insights-availability-tests"
$env = "dev"
$resourceGroup = "kmx-dev-picsy"

$configuration = @{
    "deploy" = "x-deploy-$((Get-Date).ToUniversalTime().ToString('MMdd-HHmmss'))"
    "template" = ".infrastructure/modules/$($template).bicep"
    "resourceGroup" = $resourceGroup
    "parameters" = "environment=dev"
}

az deployment group create `
    --name $configuration.deploy `
    --resource-group $configuration.resourceGroup `
    --template-file $configuration.template `
    --parameters $configuration.parameters
