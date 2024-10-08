# az account set --subscription "36a60b19-8b19-4171-a0d6-b5686ec92329"

$template = "key-vault"
$env = "devmicro"
$resourceGroup = "space-dev-micro"

$configuration = @{
    "deploy"        = "x-deploy-$((Get-Date).ToUniversalTime().ToString('MMdd-HHmmss'))"
    "template"      = "modules/$($template).bicep"
    "resourceGroup" = $resourceGroup
    "parameters"    = "environment=devmicro"
}

az deployment group create `
    --name $configuration.deploy `
    --resource-group $configuration.resourceGroup `
    --template-file $configuration.template `
    --parameters $configuration.parameters
