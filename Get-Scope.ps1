function Get-Scope-Array {
    param(
        [string] $currentRelativePath
    )

    if( $(Split-Path $currentRelativePath -Parent) -ne '.' ) {
        Get-Scope-Array -currentRelativePath $(Split-Path $currentRelativePath)        
    }

    $scope = $(Split-Path -Leaf $currentRelativePath).Split('.')[0]
    if(-not $scope.Contains('device')) {
        $scope
    }    
}

Set-Location "$(git rev-parse --show-toplevel)\deploy"
$relativeDeviceFolders = $(Get-ChildItem -Recurse -Filter "*.device.json") | Resolve-Path -Relative
$dict = @{}

foreach ($devicePath in $relativeDeviceFolders) {
    $key = (Split-Path -Leaf $devicePath).Split('.')[0]

    $value = New-Object PSObject -Property @{ ScopeArray=@(); Hub="" }
    $value.ScopeArray = Get-Scope-Array -currentRelativePath $devicePath
    $devicePath -match "^*\w+.hub*" > $null
    $value.Hub = $matches[0].Split('.')[0]

    $dict.Add($key, $value)
}

$dict

#subscription id will come from github secrets
az account set --subscription ""
az account show

#replace with cxn str, todo implement Get-HubCxnString $dict[$device].Hub using GitHub secrets
$westhub_cxnstr = "" 
$easthub_cxnstr = ""

foreach ($device in $dict.Keys) {        
    if( $dict[$device].Hub -eq 'east' ) {
        $hub_cxnstr = $easthub_cxnstr
    } else {
        $hub_cxnstr = $westhub_cxnstr
    }
    
    $formattedScopeArray = $($dict[$device].ScopeArray | ConvertTo-Json) -replace "`n"," " -replace "`r"," " -replace """","'"
    $tagsJson = "{ 'env': $formattedScopeArray}"
    
    az iot hub device-twin update --device-id $device --login $hub_cxnstr --tags $tagsJson
}




