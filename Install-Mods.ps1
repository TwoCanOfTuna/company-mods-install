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

	Write-Host "Downloading and installing 96753"
	$96753Version = Get-Arg $arguments "-96753"
	$96753Url = "-https://thunderstore.io/package/download/Evaisa/HookGenPatcher/$96753Version/"
	$96753Stream = Request-Stream $96753Url
	$96753Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $96753Stream $96753Path
	Write-Host "Installed 96753"
	Write-Host ""


	Write-Host "Downloading and installing 53760"
	$53760Version = Get-Arg $arguments "-53760"
	$53760Url = "-https://thunderstore.io/package/download/Evaisa/LethalLib/$53760Version/"
	$53760Stream = Request-Stream $53760Url
	$53760Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $53760Stream $53760Path
	Write-Host "Installed 53760"
	Write-Host ""


	Write-Host "Downloading and installing 88971"
	$88971Version = Get-Arg $arguments "-88971"
	$88971Url = "-https://thunderstore.io/package/download/notnotnotswipez/MoreCompany/$88971Version/"
	$88971Stream = Request-Stream $88971Url
	$88971Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $88971Stream $88971Path
	Write-Host "Installed 88971"
	Write-Host ""


	Write-Host "Downloading and installing 37458"
	$37458Version = Get-Arg $arguments "-37458"
	$37458Url = "-https://thunderstore.io/package/download/RickArg/Helmet_Cameras/$37458Version/"
	$37458Stream = Request-Stream $37458Url
	$37458Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $37458Stream $37458Path
	Write-Host "Installed 37458"
	Write-Host ""


	Write-Host "Downloading and installing 5853"
	$5853Version = Get-Arg $arguments "-5853"
	$5853Url = "-https://thunderstore.io/package/download/Flof/MemeSoundboard/$5853Version/"
	$5853Stream = Request-Stream $5853Url
	$5853Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $5853Stream $5853Path
	Write-Host "Installed 5853"
	Write-Host ""


	Write-Host "Downloading and installing 47965"
	$47965Version = Get-Arg $arguments "-47965"
	$47965Url = "-https://thunderstore.io/package/download/quackandcheese/MirrorDecor/$47965Version/"
	$47965Stream = Request-Stream $47965Url
	$47965Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $47965Stream $47965Path
	Write-Host "Installed 47965"
	Write-Host ""


	Write-Host "Downloading and installing 66292"
	$66292Version = Get-Arg $arguments "-66292"
	$66292Url = "-https://thunderstore.io/package/download/Electric131/OuijaBoard/$66292Version/"
	$66292Stream = Request-Stream $66292Url
	$66292Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $66292Stream $66292Path
	Write-Host "Installed 66292"
	Write-Host ""


	Write-Host "Downloading and installing 2758"
	$2758Version = Get-Arg $arguments "-2758"
	$2758Url = "-https://thunderstore.io/package/download/TheFluff/GetLootForKills/$2758Version/"
	$2758Stream = Request-Stream $2758Url
	$2758Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $2758Stream $2758Path
	Write-Host "Installed 2758"
	Write-Host ""


	Write-Host "Downloading and installing 15433"
	$15433Version = Get-Arg $arguments "-15433"
	$15433Url = "-https://thunderstore.io/package/download/amnsoft/EmployeeAssignments/$15433Version/"
	$15433Stream = Request-Stream $15433Url
	$15433Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $15433Stream $15433Path
	Write-Host "Installed 15433"
	Write-Host ""


	Write-Host "Downloading and installing 79409"
	$79409Version = Get-Arg $arguments "-79409"
	$79409Url = "-https://thunderstore.io/package/download/Nebulaetrix/ExplosiveUnboxing/$79409Version/"
	$79409Stream = Request-Stream $79409Url
	$79409Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $79409Stream $79409Path
	Write-Host "Installed 79409"
	Write-Host ""


	Write-Host "Downloading and installing 62128"
	$62128Version = Get-Arg $arguments "-62128"
	$62128Url = "-https://thunderstore.io/package/download/ZTK/ZTKCosmetics/$62128Version/"
	$62128Stream = Request-Stream $62128Url
	$62128Path = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $62128Stream $62128Path
	Write-Host "Installed 62128"
	Write-Host ""
}

try {
    Install $args
    Write-Host "Install successful"
} catch {
    Write-Host "Install failed: $_"
}

Read-Host "Press Enter To Exit"