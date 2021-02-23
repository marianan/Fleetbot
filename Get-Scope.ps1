function Get-Scope-Array {
    param(
        [string] $currentRelativePath
    )

    if( $(Split-Path $currentRelativePath -Parent) -ne '.' ) {
        Get-Scope-Array -currentRelativePath $(Split-Path $currentRelativePath)        
    }

    Split-Path -Leaf $currentRelativePath  
}

Set-Location C:\Work\Git\Fleetbot\deploy
$relativeDeviceFolders = $(Get-ChildItem -Recurse -Directory -Filter "*.device") | Resolve-Path -Relative
$dict = @{}

foreach ($devicePath in $relativeDeviceFolders) {
    $key = Split-Path -Leaf $devicePath
    $value = Get-Scope-Array -currentRelativePath ".\global.scope\east.hub\africa.scope\device3.device"

    $dict.Add($key, $value)
}

$dict


