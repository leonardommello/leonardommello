#Check if software as running with admin, if not, get admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (!$isAdmin) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function InstallPackages {
    # List of packages to install
    $pkgList = @(
        "Docker.DockerDesktop"
        "GoLang.Go"
        "Microsoft.WindowsTerminal"
        "Microsoft.PowerShell"
        "Microsoft.PowerToys"
        "Microsoft.VisualStudioCode.Insiders"
        "Microsoft.VisualStudio.2022.Community"
        "Google.Chrome"
        "Foxit.FoxitReader"
        "7zip.7zip"
        "Kitware.CMake"
        "Fork.Fork"
        "Git.Git"
        "Python.Python.3.11"
        "EclipseAdoptium.Temurin.17.JDK"
        "Canonical.Ubuntu.2204"
        "Microsoft.VCRedist.2013.x64"
        "Microsoft.VCRedist.2012.x64"
        "Microsoft.VCRedist.2010.x64"
        "Microsoft.VCRedist.2008.x64"
        "Microsoft.DotNet.Runtime.8"
        "JanDeDobbeleer.OhMyPosh"
        "GitHub.GitLFS"
        "Amazon.AWSCLI"
        "KaiKramer.KeyStoreExplorer"
        "WinSCP.WinSCP"
        "Obsidian.Obsidian"
    )

    foreach ($pkg in $pkgList) {
        Write-Host "Installing $pkg"
        winget install -e -q $pkg
    }
}

# if winget is not installed, install it
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    $URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
    Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -Match '.msixbundle' |
    Select-Object -ExpandProperty "browser_download_url"
    Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing
    Add-AppxPackage -Path "Setup.msix"
    Remove-Item "Setup.msix"
    try {
        winget --version
        if ($?) {
            InstallPackages
        }
    }
    catch {
        Write-Host "Winget failed to install, please install it manually"
        Write-Host "https://github.com/microsoft/winget-cli/releases/"
        exit
    }
}
else {
    InstallPackages
}