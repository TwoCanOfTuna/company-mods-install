# Base script from KrystilizeNevaDies at https://github.com/KrystilizeNevaDies/Lethalize

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

    # Download and install lcapi
    Write-Host "Downloading and installing LC_API"
    $lcapiVersion = Get-Arg $arguments "-lcapi"
    $lcapiUrl = "https://thunderstore.io/package/download/2018/LC_API/$lcapiVersion/"
    $lcapiStream = Request-Stream $lcapiUrl
    $lcapiPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
    Expand-Stream $lcapiStream $lcapiPath
    Write-Host "Installed LC_API"
    Write-Host ""

    # Download and install commandhandler
    Write-Host "Downloading and installing CommandHandler"
    $chVersion = Get-Arg $arguments "-ch"
    $chUrl = "https://thunderstore.io/package/download/steven4547466/CommandHandler/$chVersion/"
    $chStream = Request-Stream $chUrl
    $chPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
    Expand-Stream $chStream $chPath
    Write-Host "Installed CommandHandler"
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

    # Download and install mirrordecor
    Write-Host "Downloading and installing MirrorDecor"
    $mirrorDecorVersion = Get-Arg $arguments "-mirrordecor"
    $mirrorDecorUrl = "https://thunderstore.io/package/download/quackandcheese/MirrorDecor/$mirrorDecorVersion/"
    $mirrorDecorStream = Request-Stream $mirrorDecorUrl
    $mirrorDecorPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
    Expand-Stream $mirrorDecorStream $mirrorDecorPath
    Write-Host "Installed MirrorDecor"
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

    # Download and install youtubeboombox
    Write-Host "Downloading and installing YoutubeBoombox"
    $ytbbVersion = Get-Arg $arguments "-ytbb"
    $ytbbUrl = "https://thunderstore.io/package/download/steven4547466/YoutubeBoombox/$ytbbVersion/"
    $ytbbStream = Request-Stream $ytbbUrl
    $ytbbPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
    Expand-Stream $ytbbStream $ytbbPath
    Write-Host "Installed YoutubeBoombox"
    Write-Host ""
}

try {
    Install $args
    Write-Host "Install successful"
} catch {
    Write-Host "Install failed: $_"
}

Read-Host “Press ENTER to exit...”