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

	Write-Host "Downloading and installing divertor"
	$divertorVersion = Get-Arg $arguments "-divertor"
	$divertorUrl = "https://thunderstore.io/package/download/Evaisa/HookGenPatcher/$divertorVersion/"
	$divertorStream = Request-Stream $divertorUrl
	$divertorPath = Join-Path $lethalCompanyPath "BepInEx"
	Expand-Stream $divertorStream $divertorPath
	Write-Host "Installed divertor"
	Write-Host ""

	Write-Host "Downloading and installing glt"
	$gltVersion = Get-Arg $arguments "-glt"
	$gltUrl = "https://thunderstore.io/package/download/Evaisa/LethalLib/$gltVersion/"
	$gltStream = Request-Stream $gltUrl
	$gltPath = Join-Path $lethalCompanyPath "BepInEx"
	Expand-Stream $gltStream $gltPath
	Write-Host "Installed glt"
	Write-Host ""

	Write-Host "Downloading and installing shorefront"
	$shorefrontVersion = Get-Arg $arguments "-shorefront"
	$shorefrontUrl = "https://thunderstore.io/package/download/2018/LC_API/$shorefrontVersion/"
	$shorefrontStream = Request-Stream $shorefrontUrl
	$shorefrontPath = Join-Path $lethalCompanyPath "BepInEx/plugins/2018-LC_API"
	Expand-Stream $shorefrontStream $shorefrontPath
	Write-Host "Installed shorefront"
	Write-Host ""

	Write-Host "Downloading and installing naturalia"
	$naturaliaVersion = Get-Arg $arguments "-naturalia"
	$naturaliaUrl = "https://thunderstore.io/package/download/Winfi4/winfi4YoutubeBoombox/$naturaliaVersion/"
	$naturaliaStream = Request-Stream $naturaliaUrl
	$naturaliaPath = Join-Path $lethalCompanyPath "BepInEx/plugins/2018-LC_API"
	Expand-Stream $naturaliaStream $naturaliaPath
	Write-Host "Installed naturalia"
	Write-Host ""

	Write-Host "Downloading and installing denied"
	$deniedVersion = Get-Arg $arguments "-denied"
	$deniedUrl = "https://thunderstore.io/package/download/notnotnotswipez/MoreCompany/$deniedVersion/"
	$deniedStream = Request-Stream $deniedUrl
	$deniedPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $deniedStream $deniedPath
	Write-Host "Installed denied"
	Write-Host ""

	Write-Host "Downloading and installing uletic"
	$uleticVersion = Get-Arg $arguments "-uletic"
	$uleticUrl = "https://thunderstore.io/package/download/anormaltwig/LateCompany/$uleticVersion/"
	$uleticStream = Request-Stream $uleticUrl
	$uleticPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $uleticStream $uleticPath
	Write-Host "Installed uletic"
	Write-Host ""

	Write-Host "Downloading and installing probableness"
	$probablenessVersion = Get-Arg $arguments "-probableness"
	$probablenessUrl = "https://thunderstore.io/package/download/FlipMods/TooManyEmotes/$probablenessVersion/"
	$probablenessStream = Request-Stream $probablenessUrl
	$probablenessPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $probablenessStream $probablenessPath
	Write-Host "Installed probableness"
	Write-Host ""

	Write-Host "Downloading and installing menorah"
	$menorahVersion = Get-Arg $arguments "-menorah"
	$menorahUrl = "https://thunderstore.io/package/download/RickArg/Helmet_Cameras/$menorahVersion/"
	$menorahStream = Request-Stream $menorahUrl
	$menorahPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $menorahStream $menorahPath
	Write-Host "Installed menorah"
	Write-Host ""

	Write-Host "Downloading and installing accessors"
	$accessorsVersion = Get-Arg $arguments "-accessors"
	$accessorsUrl = "https://thunderstore.io/package/download/x753/More_Suits/$accessorsVersion/"
	$accessorsStream = Request-Stream $accessorsUrl
	$accessorsPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $accessorsStream $accessorsPath
	Write-Host "Installed accessors"
	Write-Host ""

	Write-Host "Downloading and installing metageitnion"
	$metageitnionVersion = Get-Arg $arguments "-metageitnion"
	$metageitnionUrl = "https://thunderstore.io/package/download/Verity/TooManySuits/$metageitnionVersion/"
	$metageitnionStream = Request-Stream $metageitnionUrl
	$metageitnionPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $metageitnionStream $metageitnionPath
	Write-Host "Installed metageitnion"
	Write-Host ""

	Write-Host "Downloading and installing woundworth"
	$woundworthVersion = Get-Arg $arguments "-woundworth"
	$woundworthUrl = "https://thunderstore.io/package/download/GothKin/KinSuits/$woundworthVersion/"
	$woundworthStream = Request-Stream $woundworthUrl
	$woundworthPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $woundworthStream $woundworthPath
	Write-Host "Installed woundworth"
	Write-Host ""

	Write-Host "Downloading and installing fused"
	$fusedVersion = Get-Arg $arguments "-fused"
	$fusedUrl = "https://thunderstore.io/package/download/GhostbustingTrio/CustomFunSuits/$fusedVersion/"
	$fusedStream = Request-Stream $fusedUrl
	$fusedPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $fusedStream $fusedPath
	Write-Host "Installed fused"
	Write-Host ""

	Write-Host "Downloading and installing curdles"
	$curdlesVersion = Get-Arg $arguments "-curdles"
	$curdlesUrl = "https://thunderstore.io/package/download/NiaNation/AbsasCosmetics/$curdlesVersion/"
	$curdlesStream = Request-Stream $curdlesUrl
	$curdlesPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $curdlesStream $curdlesPath
	Write-Host "Installed curdles"
	Write-Host ""

	Write-Host "Downloading and installing uncoupling"
	$uncouplingVersion = Get-Arg $arguments "-uncoupling"
	$uncouplingUrl = "https://thunderstore.io/package/download/ZTK/ZTKCosmetics/$uncouplingVersion/"
	$uncouplingStream = Request-Stream $uncouplingUrl
	$uncouplingPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $uncouplingStream $uncouplingPath
	Write-Host "Installed uncoupling"
	Write-Host ""

	Write-Host "Downloading and installing hemiageustia"
	$hemiageustiaVersion = Get-Arg $arguments "-hemiageustia"
	$hemiageustiaUrl = "https://thunderstore.io/package/download/EliteMasterEric/WackyCosmetics/$hemiageustiaVersion/"
	$hemiageustiaStream = Request-Stream $hemiageustiaUrl
	$hemiageustiaPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $hemiageustiaStream $hemiageustiaPath
	Write-Host "Installed hemiageustia"
	Write-Host ""

	Write-Host "Downloading and installing dottel"
	$dottelVersion = Get-Arg $arguments "-dottel"
	$dottelUrl = "https://thunderstore.io/package/download/HGG/JoJo_Menacing_Cosmetic/$dottelVersion/"
	$dottelStream = Request-Stream $dottelUrl
	$dottelPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $dottelStream $dottelPath
	Write-Host "Installed dottel"
	Write-Host ""

	Write-Host "Downloading and installing uneasily"
	$uneasilyVersion = Get-Arg $arguments "-uneasily"
	$uneasilyUrl = "https://thunderstore.io/package/download/HolographicWings/LethalExpansion/$uneasilyVersion/"
	$uneasilyStream = Request-Stream $uneasilyUrl
	$uneasilyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $uneasilyStream $uneasilyPath
	Write-Host "Installed uneasily"
	Write-Host ""

	Write-Host "Downloading and installing inderivative"
	$inderivativeVersion = Get-Arg $arguments "-inderivative"
	$inderivativeUrl = "https://thunderstore.io/package/download/silhygames/FumoCompany/$inderivativeVersion/"
	$inderivativeStream = Request-Stream $inderivativeUrl
	$inderivativePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $inderivativeStream $inderivativePath
	Write-Host "Installed inderivative"
	Write-Host ""

	Write-Host "Downloading and installing dipteros"
	$dipterosVersion = Get-Arg $arguments "-dipteros"
	$dipterosUrl = "https://thunderstore.io/package/download/Caigan/Tokucade_Scrap/$dipterosVersion/"
	$dipterosStream = Request-Stream $dipterosUrl
	$dipterosPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $dipterosStream $dipterosPath
	Write-Host "Installed dipteros"
	Write-Host ""

	Write-Host "Downloading and installing multitask"
	$multitaskVersion = Get-Arg $arguments "-multitask"
	$multitaskUrl = "https://thunderstore.io/package/download/ArticFox_Monix/Blahaj/$multitaskVersion/"
	$multitaskStream = Request-Stream $multitaskUrl
	$multitaskPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $multitaskStream $multitaskPath
	Write-Host "Installed multitask"
	Write-Host ""

	Write-Host "Downloading and installing nonrelativistic"
	$nonrelativisticVersion = Get-Arg $arguments "-nonrelativistic"
	$nonrelativisticUrl = "https://thunderstore.io/package/download/Nuts/LethalPlushies/$nonrelativisticVersion/"
	$nonrelativisticStream = Request-Stream $nonrelativisticUrl
	$nonrelativisticPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $nonrelativisticStream $nonrelativisticPath
	Write-Host "Installed nonrelativistic"
	Write-Host ""

	Write-Host "Downloading and installing tomming"
	$tommingVersion = Get-Arg $arguments "-tomming"
	$tommingUrl = "https://thunderstore.io/package/download/Shambi/LC_Shitgun/$tommingVersion/"
	$tommingStream = Request-Stream $tommingUrl
	$tommingPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $tommingStream $tommingPath
	Write-Host "Installed tomming"
	Write-Host ""

	Write-Host "Downloading and installing dobbies"
	$dobbiesVersion = Get-Arg $arguments "-dobbies"
	$dobbiesUrl = "https://thunderstore.io/package/download/Nips/Brutal_Company_Plus/$dobbiesVersion/"
	$dobbiesStream = Request-Stream $dobbiesUrl
	$dobbiesPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $dobbiesStream $dobbiesPath
	Write-Host "Installed dobbies"
	Write-Host ""

	Write-Host "Downloading and installing nondelicately"
	$nondelicatelyVersion = Get-Arg $arguments "-nondelicately"
	$nondelicatelyUrl = "https://thunderstore.io/package/download/MrHydralisk/EnhancedRadarBooster/$nondelicatelyVersion/"
	$nondelicatelyStream = Request-Stream $nondelicatelyUrl
	$nondelicatelyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $nondelicatelyStream $nondelicatelyPath
	Write-Host "Installed nondelicately"
	Write-Host ""

	Write-Host "Downloading and installing haematologist"
	$haematologistVersion = Get-Arg $arguments "-haematologist"
	$haematologistUrl = "https://thunderstore.io/package/download/JunLethalCompany/GamblingMachineAtTheCompany/$haematologistVersion/"
	$haematologistStream = Request-Stream $haematologistUrl
	$haematologistPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $haematologistStream $haematologistPath
	Write-Host "Installed haematologist"
	Write-Host ""

	Write-Host "Downloading and installing tsarists"
	$tsaristsVersion = Get-Arg $arguments "-tsarists"
	$tsaristsUrl = "https://thunderstore.io/package/download/Rattenbonkers/TVLoader/$tsaristsVersion/"
	$tsaristsStream = Request-Stream $tsaristsUrl
	$tsaristsPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $tsaristsStream $tsaristsPath
	Write-Host "Installed tsarists"
	Write-Host ""

	Write-Host "Downloading and installing injection"
	$injectionVersion = Get-Arg $arguments "-injection"
	$injectionUrl = "https://thunderstore.io/package/download/Preservation/Family_Guy_TV_113/$injectionVersion/"
	$injectionStream = Request-Stream $injectionUrl
	$injectionPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $injectionStream $injectionPath
	Write-Host "Installed injection"
	Write-Host ""}

try {
    Install $args
    Write-Host "Install successful"
} catch {
    Write-Host "Install failed: $_"
}

Read-Host "Press Enter To Exit"
Exit