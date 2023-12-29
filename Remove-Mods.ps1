# Base script from KrystilizeNevaDies at https://github.com/KrystilizeNevaDies/Lethalize

function Uninstall {
    $lethalCompanyPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1966720").InstallLocation
    if ($null -eq $lethalCompanyPath) {
        throw "Steam Lethal Company install not found"
    }
    
    $bepInExPath = Join-Path $lethalCompanyPath "BepInEx"
    $chnglogPath = Join-Path $lethalCompanyPath "changelog.txt"
    $doorstpPath = Join-Path $lethalCompanyPath "doorstop_config.ini"
    $winhttpPath = Join-Path $lethalCompanyPath "winhttp.dll"

    Write-Host "Lethal Company path: $lethalCompanyPath"
    Write-Host ""

    # Delete old files
    if (Test-Path $bepInExPath) {
        Write-Host "Deleting old files"
        Remove-Item $bepInExPath -Recurse -Force
        Remove-Item $chnglogPath
        Remove-Item $doorstpPath
        Remove-Item $winhttpPath
        Write-Host "Deleted old files"
        Write-Host ""
    }
}

try {
    Uninstall
    Write-Host "Uninstalled mods"
} catch {
    Write-Host "Uninstall failed: $_"
}