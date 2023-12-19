# Base script from KrystilizeNevaDies at https://github.com/KrystilizeNevaDies/Lethalize

# MoreCompany, BuyableShells, HelmetCameras, MemeSoundboard
# powershell -nop -ExecutionPolicy Bypass -c "Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://github.com/TwoCanOfTuna/company-mods-install/releases/download/company-mods-install2/Install-Mods.ps1')))) -ArgumentList @('-lethallib','0.6.2','-hookgen','0.0.5','-morecompany','1.7.2','-buyableshells','1.0.1','-hc','2.1.5','-sb','1.1.2')"

function Get-PlatformInfo {
    $arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
    
    switch ($arch) {
        "AMD64" { return "X64" }
        "IA64" { return "X64" }
        "ARM64" { return "X64" }
        "EM64T" { return "X64" }
        "x86" { return "X86" }
        default { throw "Unknown architecture: $arch. Submit a bug report." }
    }
}

function Request-String($url) {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Lethal Mod Installer PowerShell Script")
    return $webClient.DownloadString($url)
}

function Request-Stream($url) {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Lethal Mod Installer PowerShell Script")
    return [System.IO.MemoryStream]::new($webClient.DownloadData($url))
}

function Expand-Stream($zipStream, $destination) {
    # Create a temporary file to save the stream content
    $tempFilePath = [System.IO.Path]::GetTempFileName()

    # replace the temporary file extension with .zip
    $tempFilePath = [System.IO.Path]::ChangeExtension($tempFilePath, "zip")

    # Save the stream content to the temporary file
    $zipStream.Seek(0, [System.IO.SeekOrigin]::Begin)
    $fileStream = [System.IO.File]::OpenWrite($tempFilePath)
    $zipStream.CopyTo($fileStream)
    $fileStream.Close()

    # extract the temporary file to the destination folder
    Expand-Archive -Path $tempFilePath -DestinationPath $destination -Force

    # Delete the temporary file
    Remove-Item -Path $tempFilePath -Force
}

function Get-Arg($arguments, $argName) {
    $argIndex = [Array]::IndexOf($arguments, $argName)
    if ($argIndex -eq -1) {
        # report error
        throw "Argument $argName not found"
    }
    return $arguments[$argIndex + 1]
}

function Install ($arguments) {
    $response = Request-String "https://api.github.com/repos/BepInEx/BepInEx/releases/latest"
    $jsonObject = ConvertFrom-Json $response

    $platform2Asset = @{}

    foreach ($assetNode in $jsonObject.assets) {
        if ($null -eq $assetNode) { continue }
        
        $asset = $assetNode

        $name = $asset.name

        switch -Wildcard ($name) {
            "BepInEx_unix*" { $platform2Asset["Unix"] = $asset.browser_download_url; break }
            "BepInEx_x64*" { $platform2Asset["X64"] = $asset.browser_download_url; break }
            "BepInEx_x86*" { $platform2Asset["X86"] = $asset.browser_download_url; break }
        }
    }

    $platform = Get-PlatformInfo
    Write-Host "Detected platform: $platform"

    $assetUrl = $platform2Asset[$platform]

    if ($null -eq $assetUrl) {
        throw "Failed to find asset for platform $platform"
    }

    Write-Host "Downloading $assetUrl"

    $stream = Request-Stream $assetUrl
    
    Write-Host "Downloaded $assetUrl"
    Write-Host ""

    $lethalCompanyPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1966720").InstallLocation
    if ($null -eq $lethalCompanyPath) {
        throw "Steam Lethal Company install not found"
    }
    
    $bepInExPath = Join-Path $lethalCompanyPath "BepInEx"

    Write-Host "Lethal Company path: $lethalCompanyPath"
    Write-Host ""

    # Delete old files
    if (Test-Path $bepInExPath) {
        Write-Host "Deleting old files"
        Remove-Item $bepInExPath -Recurse -Force
        Write-Host "Deleted old files"
        Write-Host ""
    }

    Write-Host "Installing BepInEx"
    Expand-Stream $stream $lethalCompanyPath
    Write-Host "Installed BepInEx"
    Write-Host ""

    # Download and install lethallib library
    Write-Host "Downloading and installing LethalLib"
    $lethalLibVersion = Get-Arg $arguments "-lethallib"
    $lethalLibUrl = "https://thunderstore.io/package/download/Evaisa/LethalLib/$lethalLibVersion/"
    $lethalLibStream = Request-Stream $lethalLibUrl
    $lethalLibPath = Join-Path $lethalCompanyPath "BepInEx"
    Expand-Stream $lethalLibStream $lethalLibPath
    Write-Host "Installed LethalLib"
    Write-Host ""

    # Download and install hookgen library
    Write-Host "Downloading and installing HookGen"
    $hookGenVersion = Get-Arg $arguments "-hookgen"
    $hookGenUrl = "https://thunderstore.io/package/download/Evaisa/HookGenPatcher/$hookGenVersion/"
    $hookGenStream = Request-Stream $hookGenUrl
    $hookGenPath = Join-Path $lethalCompanyPath "BepInEx"
    Expand-Stream $hookGenStream $hookGenPath
    Write-Host "Installed HookGen"
    Write-Host ""

    # Download and install morecompany
    Write-Host "Downloading and installing MoreCompany"
    $moreCompanyVersion = Get-Arg $arguments "-morecompany"
    $moreCompanyUrl = "https://thunderstore.io/package/download/notnotnotswipez/MoreCompany/$moreCompanyVersion/"
    $moreCompanyStream = Request-Stream $moreCompanyUrl
    Expand-Stream $moreCompanyStream $lethalCompanyPath
    Write-Host "Installed MoreCompany"
    Write-Host ""

    # Download and install buyableshells
    Write-Host "Downloading and installing BuyableShells"
    $buyableShellsVersion = Get-Arg $arguments "-buyableshells"
    $buyableShellsUrl = "https://thunderstore.io/package/download/MegaPiggy/BuyableShotgunShells/$buyableShellsVersion/"
    $buyableShellsStream = Request-Stream $buyableShellsUrl
    $buyableShellsPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
    Expand-Stream $buyableShellsStream $buyableShellsPath
    Write-Host "Installed BuyableShells"
    Write-Host ""

    # Download and install helmetcamera
    Write-Host "Downloading and installing HelmetCamera"
    $hcVersion = Get-Arg $arguments "-hc"
    $hcUrl = "https://thunderstore.io/package/download/RickArg/Helmet_Cameras/$hcVersion/"
    $hcStream = Request-Stream $hcUrl
    Expand-Stream $hcStream $lethalCompanyPath
    Write-Host "Installed HelmetCamera"
    Write-Host ""

    # Download and install soundboard
    Write-Host "Downloading and installing Soundboard"
    $sbVersion = Get-Arg $arguments "-sb"
    $sbUrl = "https://thunderstore.io/package/download/Flof/MemeSoundboard/$sbVersion/"
    $sbStream = Request-Stream $sbUrl
    Expand-Stream $sbStream $lethalCompanyPath
    Write-Host "Installed Soundboard"
    Write-Host ""
    
    # Download and install gamemaster
    Write-Host "Downloading and installing GameMaster"
    $gmVersion = Get-Arg $arguments "-gm"
    $gmUrl = "https://thunderstore.io/package/download/GameMasterDevs/GameMaster/3.2.0/"
    $gmStream = Request-Stream $gmUrl
    $gmPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
    Expand-Stream $gmStream $gmPath
    Write-Host "Installed GameMaster"
    Write-Host ""

    # Download and install additionalsuits
    Write-Host "Downloading and installing AdditionalSuits"
    $asVersion = Get-Arg $arguments "-as"
    $asUrl = "https://thunderstore.io/package/download/AlexCodesGames/AdditionalSuits/$asVersion/"
    $asStream = Request-Stream $asUrl
    $asPath = Join-Path $lethalCompanyPath "BepInEx"
    Expand-Stream $asStream $asPath
    Write-Host "Installed AdditionalSuits"
    Write-Host ""

    # Download and install mirrordecor
    Write-Host "Downloading and installing MirrorDecor"
    $mirrorDecorVersion = Get-Arg $arguments "-mirrordecor"
    $mirrorDecorUrl = "https://thunderstore.io/package/download/quackandcheese/MirrorDecor/$mirrorDecorVersion/"
    $mirrorDecorStream = Request-Stream $mirrorDecorUrl
    $mirrorDecorPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
    Expand-Stream $mirrorDecorStream $mirrorDecorPath
    Write-Host "Installed MirrorDecor"
    Write-Host ""

    # Download and install mimics
    Write-Host "Downloading and installing Mimics"
    $mimicsVersion = Get-Arg $arguments "-mimics"
    $mimicsUrl = "https://thunderstore.io/package/download/x753/Mimics/$mimicsVersion/"
    $mimicsStream = Request-Stream $mimicsUrl
    Expand-Stream $mimicsStream $lethalCompanyPath
    Write-Host "Installed Mimics"
    Write-Host ""

    # Download and install coroner
    Write-Host "Downloading and installing Coroner"
    $cnVersion = Get-Arg $arguments "-cn"
    $cnUrl = "https://thunderstore.io/package/download/EliteMasterEric/Coroner/$cnVersion/"
    $cnStream = Request-Stream $cnUrl
    $cnPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
    Expand-Stream $cnStream $cnPath
    Write-Host "Installed Coroner"
    Write-Host ""

}

try {
    Install $args
    Write-Host "Install successful"
} catch {
    Write-Host "Install failed: $_"
}

Read-Host “Press ENTER to exit...”