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

	Write-Host "Downloading and installing circumsail"
	$circumsailVersion = Get-Arg $arguments "-circumsail"
	$circumsailUrl = "https://thunderstore.io/package/download/Evaisa/HookGenPatcher/$circumsailVersion/"
	$circumsailStream = Request-Stream $circumsailUrl
	$circumsailPath = Join-Path $lethalCompanyPath "BepInEx"
	Expand-Stream $circumsailStream $circumsailPath
	Write-Host "Installed circumsail"
	Write-Host ""

	Write-Host "Downloading and installing nontitled"
	$nontitledVersion = Get-Arg $arguments "-nontitled"
	$nontitledUrl = "https://thunderstore.io/package/download/Evaisa/LethalLib/$nontitledVersion/"
	$nontitledStream = Request-Stream $nontitledUrl
	$nontitledPath = Join-Path $lethalCompanyPath "BepInEx"
	Expand-Stream $nontitledStream $nontitledPath
	Write-Host "Installed nontitled"
	Write-Host ""

	Write-Host "Downloading and installing transponder"
	$transponderVersion = Get-Arg $arguments "-transponder"
	$transponderUrl = "https://thunderstore.io/package/download/notnotnotswipez/MoreCompany/$transponderVersion/"
	$transponderStream = Request-Stream $transponderUrl
	$transponderPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $transponderStream $transponderPath
	Write-Host "Installed transponder"
	Write-Host ""

	Write-Host "Downloading and installing implodes"
	$implodesVersion = Get-Arg $arguments "-implodes"
	$implodesUrl = "https://thunderstore.io/package/download/anormaltwig/LateCompany/$implodesVersion/"
	$implodesStream = Request-Stream $implodesUrl
	$implodesPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $implodesStream $implodesPath
	Write-Host "Installed implodes"
	Write-Host ""

	Write-Host "Downloading and installing unelided"
	$unelidedVersion = Get-Arg $arguments "-unelided"
	$unelidedUrl = "https://thunderstore.io/package/download/FlipMods/TooManyEmotes/$unelidedVersion/"
	$unelidedStream = Request-Stream $unelidedUrl
	$unelidedPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $unelidedStream $unelidedPath
	Write-Host "Installed unelided"
	Write-Host ""

	Write-Host "Downloading and installing rhodomontade"
	$rhodomontadeVersion = Get-Arg $arguments "-rhodomontade"
	$rhodomontadeUrl = "https://thunderstore.io/package/download/RickArg/Helmet_Cameras/$rhodomontadeVersion/"
	$rhodomontadeStream = Request-Stream $rhodomontadeUrl
	$rhodomontadePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $rhodomontadeStream $rhodomontadePath
	Write-Host "Installed rhodomontade"
	Write-Host ""

	Write-Host "Downloading and installing biophysiology"
	$biophysiologyVersion = Get-Arg $arguments "-biophysiology"
	$biophysiologyUrl = "https://thunderstore.io/package/download/x753/More_Suits/$biophysiologyVersion/"
	$biophysiologyStream = Request-Stream $biophysiologyUrl
	$biophysiologyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $biophysiologyStream $biophysiologyPath
	Write-Host "Installed biophysiology"
	Write-Host ""

	Write-Host "Downloading and installing gynandry"
	$gynandryVersion = Get-Arg $arguments "-gynandry"
	$gynandryUrl = "https://thunderstore.io/package/download/Verity/TooManySuits/$gynandryVersion/"
	$gynandryStream = Request-Stream $gynandryUrl
	$gynandryPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $gynandryStream $gynandryPath
	Write-Host "Installed gynandry"
	Write-Host ""

	Write-Host "Downloading and installing losels"
	$loselsVersion = Get-Arg $arguments "-losels"
	$loselsUrl = "https://thunderstore.io/package/download/GothKin/KinSuits/$loselsVersion/"
	$loselsStream = Request-Stream $loselsUrl
	$loselsPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $loselsStream $loselsPath
	Write-Host "Installed losels"
	Write-Host ""

	Write-Host "Downloading and installing uninventively"
	$uninventivelyVersion = Get-Arg $arguments "-uninventively"
	$uninventivelyUrl = "https://thunderstore.io/package/download/GhostbustingTrio/CustomFunSuits/$uninventivelyVersion/"
	$uninventivelyStream = Request-Stream $uninventivelyUrl
	$uninventivelyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $uninventivelyStream $uninventivelyPath
	Write-Host "Installed uninventively"
	Write-Host ""

	Write-Host "Downloading and installing equalize"
	$equalizeVersion = Get-Arg $arguments "-equalize"
	$equalizeUrl = "https://thunderstore.io/package/download/NiaNation/AbsasCosmetics/$equalizeVersion/"
	$equalizeStream = Request-Stream $equalizeUrl
	$equalizePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $equalizeStream $equalizePath
	Write-Host "Installed equalize"
	Write-Host ""

	Write-Host "Downloading and installing hepaticotomy"
	$hepaticotomyVersion = Get-Arg $arguments "-hepaticotomy"
	$hepaticotomyUrl = "https://thunderstore.io/package/download/ZTK/ZTKCosmetics/$hepaticotomyVersion/"
	$hepaticotomyStream = Request-Stream $hepaticotomyUrl
	$hepaticotomyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $hepaticotomyStream $hepaticotomyPath
	Write-Host "Installed hepaticotomy"
	Write-Host ""

	Write-Host "Downloading and installing heavyheartedly"
	$heavyheartedlyVersion = Get-Arg $arguments "-heavyheartedly"
	$heavyheartedlyUrl = "https://thunderstore.io/package/download/EliteMasterEric/WackyCosmetics/$heavyheartedlyVersion/"
	$heavyheartedlyStream = Request-Stream $heavyheartedlyUrl
	$heavyheartedlyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $heavyheartedlyStream $heavyheartedlyPath
	Write-Host "Installed heavyheartedly"
	Write-Host ""

	Write-Host "Downloading and installing vanaprastha"
	$vanaprasthaVersion = Get-Arg $arguments "-vanaprastha"
	$vanaprasthaUrl = "https://thunderstore.io/package/download/HGG/JoJo_Menacing_Cosmetic/$vanaprasthaVersion/"
	$vanaprasthaStream = Request-Stream $vanaprasthaUrl
	$vanaprasthaPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $vanaprasthaStream $vanaprasthaPath
	Write-Host "Installed vanaprastha"
	Write-Host ""

	Write-Host "Downloading and installing dropping"
	$droppingVersion = Get-Arg $arguments "-dropping"
	$droppingUrl = "https://thunderstore.io/package/download/HolographicWings/LethalExpansion/$droppingVersion/"
	$droppingStream = Request-Stream $droppingUrl
	$droppingPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $droppingStream $droppingPath
	Write-Host "Installed dropping"
	Write-Host ""

	Write-Host "Downloading and installing sithe"
	$sitheVersion = Get-Arg $arguments "-sithe"
	$sitheUrl = "https://thunderstore.io/package/download/silhygames/FumoCompany/$sitheVersion/"
	$sitheStream = Request-Stream $sitheUrl
	$sithePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $sitheStream $sithePath
	Write-Host "Installed sithe"
	Write-Host ""

	Write-Host "Downloading and installing huspil"
	$huspilVersion = Get-Arg $arguments "-huspil"
	$huspilUrl = "https://thunderstore.io/package/download/Caigan/Tokucade_Scrap/$huspilVersion/"
	$huspilStream = Request-Stream $huspilUrl
	$huspilPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $huspilStream $huspilPath
	Write-Host "Installed huspil"
	Write-Host ""

	Write-Host "Downloading and installing skiddy"
	$skiddyVersion = Get-Arg $arguments "-skiddy"
	$skiddyUrl = "https://thunderstore.io/package/download/ArticFox_Monix/Blahaj/$skiddyVersion/"
	$skiddyStream = Request-Stream $skiddyUrl
	$skiddyPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $skiddyStream $skiddyPath
	Write-Host "Installed skiddy"
	Write-Host ""

	Write-Host "Downloading and installing pulping"
	$pulpingVersion = Get-Arg $arguments "-pulping"
	$pulpingUrl = "https://thunderstore.io/package/download/Nuts/LethalPlushies/$pulpingVersion/"
	$pulpingStream = Request-Stream $pulpingUrl
	$pulpingPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $pulpingStream $pulpingPath
	Write-Host "Installed pulping"
	Write-Host ""

	Write-Host "Downloading and installing replaster"
	$replasterVersion = Get-Arg $arguments "-replaster"
	$replasterUrl = "https://thunderstore.io/package/download/Shambi/LC_Shitgun/$replasterVersion/"
	$replasterStream = Request-Stream $replasterUrl
	$replasterPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $replasterStream $replasterPath
	Write-Host "Installed replaster"
	Write-Host ""

	Write-Host "Downloading and installing bibliothecaire"
	$bibliothecaireVersion = Get-Arg $arguments "-bibliothecaire"
	$bibliothecaireUrl = "https://thunderstore.io/package/download/Nips/Brutal_Company_Plus/$bibliothecaireVersion/"
	$bibliothecaireStream = Request-Stream $bibliothecaireUrl
	$bibliothecairePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $bibliothecaireStream $bibliothecairePath
	Write-Host "Installed bibliothecaire"
	Write-Host ""

	Write-Host "Downloading and installing torporize"
	$torporizeVersion = Get-Arg $arguments "-torporize"
	$torporizeUrl = "https://thunderstore.io/package/download/MrHydralisk/EnhancedRadarBooster/$torporizeVersion/"
	$torporizeStream = Request-Stream $torporizeUrl
	$torporizePath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $torporizeStream $torporizePath
	Write-Host "Installed torporize"
	Write-Host ""

	Write-Host "Downloading and installing experrection"
	$experrectionVersion = Get-Arg $arguments "-experrection"
	$experrectionUrl = "https://thunderstore.io/package/download/JunLethalCompany/GamblingMachineAtTheCompany/$experrectionVersion/"
	$experrectionStream = Request-Stream $experrectionUrl
	$experrectionPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $experrectionStream $experrectionPath
	Write-Host "Installed experrection"
	Write-Host ""

	Write-Host "Downloading and installing alkalified"
	$alkalifiedVersion = Get-Arg $arguments "-alkalified"
	$alkalifiedUrl = "https://thunderstore.io/package/download/Rattenbonkers/TVLoader/$alkalifiedVersion/"
	$alkalifiedStream = Request-Stream $alkalifiedUrl
	$alkalifiedPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $alkalifiedStream $alkalifiedPath
	Write-Host "Installed alkalified"
	Write-Host ""

	Write-Host "Downloading and installing pneumatolitic"
	$pneumatoliticVersion = Get-Arg $arguments "-pneumatolitic"
	$pneumatoliticUrl = "https://thunderstore.io/package/download/Preservation/Family_Guy_TV_113/$pneumatoliticVersion/"
	$pneumatoliticStream = Request-Stream $pneumatoliticUrl
	$pneumatoliticPath = Join-Path $lethalCompanyPath "BepInEx/plugins"
	Expand-Stream $pneumatoliticStream $pneumatoliticPath
	Write-Host "Installed pneumatolitic"
	Write-Host ""}

try {
    Install $args
    Write-Host "Install successful"
} catch {
    Write-Host "Install failed: $_"
}

Read-Host "Press Enter To Exit"
Exit