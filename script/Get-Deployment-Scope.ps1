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
