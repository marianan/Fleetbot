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

Set-Location C:\Work\Git\Fleetbot\deploy
$relativeDeviceFolders = $(Get-ChildItem -Recurse -Directory -Filter "*.device") | Resolve-Path -Relative
$dict = @{}

foreach ($devicePath in $relativeDeviceFolders) {
    $key = (Split-Path -Leaf $devicePath).Split('.')[0]
    $value = Get-Scope-Array -currentRelativePath $devicePath

    $dict.Add($key, $value)
}

$dict


