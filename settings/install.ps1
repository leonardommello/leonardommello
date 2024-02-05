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
    "Microsoft.Teams"
    "Microsoft.VisualStudioCode.Insiders"
    "Microsoft.VisualStudio.2022.Community"
    "Google.Chrome"
    "Foxit.FoxitReader"
    "7zip.7zip"
    "JetBrains.IntelliJIDEA.Ultimate"
    "JetBrains.DataGrip"
    "Kitware.CMake"
    "Fork.Fork"
    "Git.Git"
    "GitHub.GitLFS"
    "Python.Python.3.11"
    "EclipseAdoptium.Temurin.17.JDK"
    "Canonical.Ubuntu.2204"
    "Microsoft.VCRedist.2013.x64"
    "Microsoft.VCRedist.2012.x64"
    "Microsoft.VCRedist.2010.x64"
    "Microsoft.VCRedist.2008.x64"
    "Microsoft.DotNet.Runtime.8"
    "JanDeDobbeleer.OhMyPosh"
    )

    foreach ($pkg in $pkgList) {
        Write-Host "Installing $pkg"
        winget install -e -q $pkg
    }
}

# if winget is not installed, install it
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
    InstallPackages
} else {
    InstallPackages
}