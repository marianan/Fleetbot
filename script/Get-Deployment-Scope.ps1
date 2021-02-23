function Get-Deployment-Scope
{
    # TODO:
    # - We need to assume where the entry point of the folder directory is going to be. "deploy"?

    # Go to root directory -- can make this configurable depending on the keyword of the heirachy
    Set-Location "$(git rev-parse --show-toplevel)\deploy"

    # Get all file location
    $deploymentFiles = $(Get-ChildItem -Recurse -Filter "*deployment*.json")

    # Iterate the path and associate them with directory
    # Format: 
    #    Key:    Scope
    #    Value1: Scope
    #    Value2: DeploymentfileObject
    #    Value3: Depth from root directory
    #    Value4: Type {scope, hub}
    $scopeDeploymentDict = @{}

    foreach ($file in $deploymentFiles)
    {
        $keyType = $file.Directory.Name.Split(".")

        $eachValue = New-Object PSObject -Property @{ Scope=""; Type=""; DeploymentFile=""; Depth="" }
        $eachValue.Scope = $keyType[0]
        $eachValue.Type = $keyType[1]
        $eachValue.DeploymentFile = $file
        # Starting at root depth = 1 (.\global.scope)
        # i)  because the .\ count as an extra line
        # ii) because the root is .\deploy not 
        $eachValue.Depth = $($file | Resolve-Path -Relative).Split('\').Count - 2

        $scopeDeploymentDict.$($keyType[0]) = $eachValue
    }

    $scopeDeploymentDict
}


function Get-Deployment-Scope
{
    # Go to root directory -- can make this configurable depending on the keyword of the heirachy
    Set-Location "$(git rev-parse --show-toplevel)\deploy"
    $scopeDeployments = [System.Collections.ArrayList]@()
    # Get all file location
    $deploymentFiles = $(Get-ChildItem -Recurse -Filter "*.deployment.json")
    foreach($directory in ($deploymentFiles.Directory | Get-Unique))
    {
        $priority = 1
        $deployments = $directory | Get-ChildItem -Filter "*.deployment.json"
        $deploymentsWithoutBase = $deployments | Where-Object {$_.name -NotMatch "base.deployment.json"}
        foreach ($deploymentWithoutBase in $deploymentsWithoutBase)
        {
            $keyType = $directory.Name.Split(".")
            $eachValue = New-Object PSObject -Property @{ Scope=""; Type=""; DeploymentFile=""; Priority="" }
            $eachValue.Scope = $keyType[0]
            $eachValue.Type = $keyType[1]
            $eachValue.DeploymentFile = $deploymentWithoutBase
            $eachValue.Priority = $priority
            $priority = $priority + 1
            $scopeDeployments.Add($eachValue)
        }
        $baseDeployment = $deployments | Where-Object {$_.name -Match "base.deployment.json"}
        foreach ($deployment in $baseDeployment)
        {
            $keyType = $directory.Name.Split(".")
            $eachValue = New-Object PSObject -Property @{ Scope=""; Type=""; DeploymentFile=""; Priority="" }
            $eachValue.Scope = $keyType[0]
            $eachValue.Type = $keyType[1]
            $eachValue.DeploymentFile = $deployment
            $eachValue.Priority = $priority
            $priority = $priority + 1
            $scopeDeployments.Add($eachValue)
        }
    }
}