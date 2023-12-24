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

	Write-Host "Downloading and installing extensionalism"
	$extensionalismVersion = Get-Arg $arguments "-extensionalism"
	$extensionalismUrl = "https://thunderstore.io/package/download/Evaisa/HookGenPatcher/$extensionalismVersion/"
	$extensionalismStream = Request-Stream $extensionalismUrl
	$extensionalismPath = Join-Path $lethalCompanyPath "BepInEx"
	Expand-Stream $extensionalismStream $extensionalismPath
	Write-Host "Installed extensionalism"
	Write-Host ""

	Write-Host "Downloading and installing legmen"
	$legmenVersion = Get-Arg $arguments "-legmen"
	$legmenUrl = "https://thunderstore.io/package/download/Evaisa/LethalLib/$legmenVersion/"
	$legmenStream = Request-Stream $legmenUrl
	$legmenPath = Join-Path $lethalCompanyPath "BepInEx"
	Expand-Stream $legmenStream $legmenPath
	Write-Host "Installed legmen"
	Write-Host ""

	Write-Host "Downloading and installing capturers"
	$capturersVersion = Get-Arg $arguments "-capturers"
	$capturersUrl = "https://thunderstore.io/package/download/notnotnotswipez/MoreCompany/$capturersVersion/"
	$capturersStream = Request-Stream $capturersUrl
	$capturersPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $capturersStream $capturersPath
	Write-Host "Installed capturers"
	Write-Host ""

	Write-Host "Downloading and installing chuckwalla"
	$chuckwallaVersion = Get-Arg $arguments "-chuckwalla"
	$chuckwallaUrl = "https://thunderstore.io/package/download/RickArg/Helmet_Cameras/$chuckwallaVersion/"
	$chuckwallaStream = Request-Stream $chuckwallaUrl
	$chuckwallaPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $chuckwallaStream $chuckwallaPath
	Write-Host "Installed chuckwalla"
	Write-Host ""

	Write-Host "Downloading and installing maloca"
	$malocaVersion = Get-Arg $arguments "-maloca"
	$malocaUrl = "https://thunderstore.io/package/download/Flof/MemeSoundboard/$malocaVersion/"
	$malocaStream = Request-Stream $malocaUrl
	$malocaPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $malocaStream $malocaPath
	Write-Host "Installed maloca"
	Write-Host ""

	Write-Host "Downloading and installing slovintzi"
	$slovintziVersion = Get-Arg $arguments "-slovintzi"
	$slovintziUrl = "https://thunderstore.io/package/download/quackandcheese/MirrorDecor/$slovintziVersion/"
	$slovintziStream = Request-Stream $slovintziUrl
	$slovintziPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $slovintziStream $slovintziPath
	Write-Host "Installed slovintzi"
	Write-Host ""

	Write-Host "Downloading and installing falseface"
	$falsefaceVersion = Get-Arg $arguments "-falseface"
	$falsefaceUrl = "https://thunderstore.io/package/download/Electric131/OuijaBoard/$falsefaceVersion/"
	$falsefaceStream = Request-Stream $falsefaceUrl
	$falsefacePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $falsefaceStream $falsefacePath
	Write-Host "Installed falseface"
	Write-Host ""

	Write-Host "Downloading and installing underrepresentation"
	$underrepresentationVersion = Get-Arg $arguments "-underrepresentation"
	$underrepresentationUrl = "https://thunderstore.io/package/download/TheFluff/GetLootForKills/$underrepresentationVersion/"
	$underrepresentationStream = Request-Stream $underrepresentationUrl
	$underrepresentationPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $underrepresentationStream $underrepresentationPath
	Write-Host "Installed underrepresentation"
	Write-Host ""

	Write-Host "Downloading and installing kannu"
	$kannuVersion = Get-Arg $arguments "-kannu"
	$kannuUrl = "https://thunderstore.io/package/download/amnsoft/EmployeeAssignments/$kannuVersion/"
	$kannuStream = Request-Stream $kannuUrl
	$kannuPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $kannuStream $kannuPath
	Write-Host "Installed kannu"
	Write-Host ""

	Write-Host "Downloading and installing idiobiology"
	$idiobiologyVersion = Get-Arg $arguments "-idiobiology"
	$idiobiologyUrl = "https://thunderstore.io/package/download/Nebulaetrix/ExplosiveUnboxing/$idiobiologyVersion/"
	$idiobiologyStream = Request-Stream $idiobiologyUrl
	$idiobiologyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $idiobiologyStream $idiobiologyPath
	Write-Host "Installed idiobiology"
	Write-Host ""

	Write-Host "Downloading and installing tendance"
	$tendanceVersion = Get-Arg $arguments "-tendance"
	$tendanceUrl = "https://thunderstore.io/package/download/ZTK/ZTKCosmetics/$tendanceVersion/"
	$tendanceStream = Request-Stream $tendanceUrl
	$tendancePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $tendanceStream $tendancePath
	Write-Host "Installed tendance"
	Write-Host ""

	Write-Host "Downloading and installing suberone"
	$suberoneVersion = Get-Arg $arguments "-suberone"
	$suberoneUrl = "https://thunderstore.io/package/download/broiiler/inacraft_cosmetics_megapack/$suberoneVersion/"
	$suberoneStream = Request-Stream $suberoneUrl
	$suberonePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $suberoneStream $suberonePath
	Write-Host "Installed suberone"
	Write-Host ""

	Write-Host "Downloading and installing abroach"
	$abroachVersion = Get-Arg $arguments "-abroach"
	$abroachUrl = "https://thunderstore.io/package/download/EliteMasterEric/WackyCosmetics/$abroachVersion/"
	$abroachStream = Request-Stream $abroachUrl
	$abroachPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $abroachStream $abroachPath
	Write-Host "Installed abroach"
	Write-Host ""

	Write-Host "Downloading and installing sterile"
	$sterileVersion = Get-Arg $arguments "-sterile"
	$sterileUrl = "https://thunderstore.io/package/download/x753/More_Suits/$sterileVersion/"
	$sterileStream = Request-Stream $sterileUrl
	$sterilePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $sterileStream $sterilePath
	Write-Host "Installed sterile"
	Write-Host ""

	Write-Host "Downloading and installing chromatogram"
	$chromatogramVersion = Get-Arg $arguments "-chromatogram"
	$chromatogramUrl = "https://thunderstore.io/package/download/Verity/TooManySuits/$chromatogramVersion/"
	$chromatogramStream = Request-Stream $chromatogramUrl
	$chromatogramPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $chromatogramStream $chromatogramPath
	Write-Host "Installed chromatogram"
	Write-Host ""

	Write-Host "Downloading and installing zaffres"
	$zaffresVersion = Get-Arg $arguments "-zaffres"
	$zaffresUrl = "https://thunderstore.io/package/download/MORT1F13R/MoreSuitColours/$zaffresVersion/"
	$zaffresStream = Request-Stream $zaffresUrl
	$zaffresPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $zaffresStream $zaffresPath
	Write-Host "Installed zaffres"
	Write-Host ""

	Write-Host "Downloading and installing unexactly"
	$unexactlyVersion = Get-Arg $arguments "-unexactly"
	$unexactlyUrl = "https://thunderstore.io/package/download/GothKin/KinSuits/$unexactlyVersion/"
	$unexactlyStream = Request-Stream $unexactlyUrl
	$unexactlyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $unexactlyStream $unexactlyPath
	Write-Host "Installed unexactly"
	Write-Host ""

	Write-Host "Downloading and installing inmprovidence"
	$inmprovidenceVersion = Get-Arg $arguments "-inmprovidence"
	$inmprovidenceUrl = "https://thunderstore.io/package/download/GhostbustingTrio/CustomFunSuits/$inmprovidenceVersion/"
	$inmprovidenceStream = Request-Stream $inmprovidenceUrl
	$inmprovidencePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $inmprovidenceStream $inmprovidencePath
	Write-Host "Installed inmprovidence"
	Write-Host ""

	Write-Host "Downloading and installing squibbing"
	$squibbingVersion = Get-Arg $arguments "-squibbing"
	$squibbingUrl = "https://thunderstore.io/package/download/shackakahn/MemeTeamSkinPack/$squibbingVersion/"
	$squibbingStream = Request-Stream $squibbingUrl
	$squibbingPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $squibbingStream $squibbingPath
	Write-Host "Installed squibbing"
	Write-Host ""

	Write-Host "Downloading and installing chirograph"
	$chirographVersion = Get-Arg $arguments "-chirograph"
	$chirographUrl = "https://thunderstore.io/package/download/anormaltwig/LateCompany/$chirographVersion/"
	$chirographStream = Request-Stream $chirographUrl
	$chirographPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $chirographStream $chirographPath
	Write-Host "Installed chirograph"
	Write-Host ""}

try {
    Install $args
    Write-Host "Install successful"
} catch {
    Write-Host "Install failed: $_"
}

Read-Host "Press Enter To Exit"
Exit