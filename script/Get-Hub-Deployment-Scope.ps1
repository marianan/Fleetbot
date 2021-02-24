function Get-Hub-Deployment-Scope
{
    Set-Location "$(git rev-parse --show-toplevel)\deploy"
    $hubList = $(Get-ChildItem -Recurse -Filter "*.hub");

    # Sudo Code: 
    #  1. List all the hub (hubList)
    #
    #  Looking up: 
    #  2. each of the hub in hubList has the directory path
    #    2.1 Take the depth of each hub, apply all the deployment files w/ lower depth
    #
    #  Looking down: 
    #  3.

    $hubDeployments = [System.Collections.ArrayList]@();
    foreach ($hub in $hubList)
    {
        # (-1) to get rid of the '.' in the split
        # (-1) to not include self in the depth search of deployment.json
        $depth = $($hub.FullName | Resolve-Path -Relative).Split('\').Count - 2;
        $deploymentFiles = $(Get-ChildItem -Recurse -Filter "*.deployment.json" -Depth $depth );

        # For each unique directory, let's create a priority list for the deployment file
        $priority = 1;
        $scopeDeployments = [System.Collections.ArrayList]@()
        foreach($directory in ($deploymentFiles.Directory | Get-Unique))
        {
            # Assign the lowest number to the base deployment of a given directory
            $baseDeployments = $directory | Get-ChildItem -Filter "base.deployment.json";
            foreach( $baseDeployment in $baseDeployments )
            {
                #$baseDeployment.FullName
                $eachValue = New-Object PSObject -Property @{DeploymentFile=""; Priority="" };
                $eachValue.Priority = $priority;
                $eachValue.DeploymentFile = $baseDeployment;
                $priority += 1;

                $scopeDeployments.Add($eachValue);
            }

            # Assign a higher priority number to the other (non-base) deployment of a given directory
            $remainingDeployments = $directory | Get-ChildItem -Filter "*.deployment.json" | Where-Object {$_.name -NotMatch "base.deployment.json"};
            foreach( $remainingDeployment in $remainingDeployments )
            {
                #$remainingDeployment.FullName
                $eachValue = New-Object PSObject -Property @{DeploymentFile=""; Priority="" };
                $eachValue.Priority = $priority;
                $eachValue.DeploymentFile = $remainingDeployment;
                $priority += 1;

                $scopeDeployments.Add($eachValue);
            }
        }

        $eachDeployEntry = New-Object PSObject -Property @{Key=""; Value="" };
        $eachDeployEntry.Key = $hub.Name;
        $eachDeployEntry.Value = $scopeDeployments;
        $hubDeployments.Add($eachDeployEntry);
    }

    $hubDeployments
}


