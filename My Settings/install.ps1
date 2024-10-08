# Checando se o script está rodando como administrador
# EN: Checking if the script is running as an administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (!$isAdmin) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

#Variables 
$userHome = $env:USERPROFILE
$scriptPath = $PSScriptRoot

# Função que instala a lista de pacotes que eu uso no Windows
# EN: Function that installs the list of packages I use on Windows
function InstallPackages {
    try {
        $pkgList = @(
            "Fork.Fork"
            "Git.Git"
            "GitHub.GitLFS"
            "suse.RancherDesktop"
            "Microsoft.WindowsTerminal"
            "Microsoft.PowerShell"
            "Microsoft.PowerToys"
            "Microsoft.VisualStudioCode"
            "TheBrowserCompany.Arc"
            "Foxit.FoxitReader"
            "7zip.7zip"
            "Canonical.Ubuntu.2204"
            "Microsoft.VCRedist.2013.x64"
            "Microsoft.VCRedist.2012.x64"
            "Microsoft.VCRedist.2010.x64"
            "Microsoft.VCRedist.2008.x64"
            "Microsoft.DotNet.Runtime.8"
            "JanDeDobbeleer.OhMyPosh"
            "Amazon.AWSCLI"
            "KaiKramer.KeyStoreExplorer"
            "WinSCP.WinSCP"
            "Obsidian.Obsidian"
            "Python.Launcher"
            "GoLang.Go"
            "EclipseAdoptium.Temurin.17.JDK"
        )

        foreach ($pkg in $pkgList) {
            Write-Host "Installing $pkg"
            winget install -e -q $pkg
        }
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Host "An error occurred at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        return $false
    }
    return $true
}

# Função que aplica configuração do perfil do PowerShell e Terminal do Windows usando symbolic link após fazer checkout do repositório
# EN: Function that applies PowerShell and Windows Terminal profile configuration using symbolic link after checking out the repository
function ApplyConfig {
    try {
        # Checando a pasta do Windows Terminal
        # EN: Checking the Windows Terminal folder
        Write-Host "Checking Windows Terminal folder"
        foreach ($folder in Get-ChildItem -Path "$env:USERPROFILE\AppData\Local\Packages" -Recurse -Directory) {
            if ($folder.Name -match "Microsoft.WindowsTerminal") {
                $terminalPath = $folder.FullName
                break
            }
        }
        # Deletando a pasta PowerShell do usuário
        # EN: Deleting the user's PowerShell folder
        Write-Host "Deleting user's PowerShell folder"
        if (Test-Path "$env:USERPROFILE\Documents\PowerShell") {
            Remove-Item -Path "$env:USERPROFILE\Documents\PowerShell" -Recurse -Force
        }
        # Deletando o arquivo settings.json do Windows Terminal
        # EN: Deleting the Windows Terminal settings.json file
        Write-Host "Deleting Windows Terminal settings.json file"
        if (Test-Path "$terminalPath\LocalState\settings.json") {
            Remove-Item -Path "$terminalPath\LocalState\settings.json"
        }
        # Cria os links simbólicos
        # EN: Creates symbolic links
        Write-Host "Creating symbolic links"
        New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\Documents\PowerShell" -Target "$scriptPath\PowerShell"
        New-Item -ItemType SymbolicLink -Path "$terminalPath\LocalState\settings.json" -Target "$scriptPath\Windows Terminal\settings.json"

        # Wait 
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Host "An error occurred at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        return $false
    }
    return $true
}


# Função que instala o winget caso não esteja instalado
# EN: Function that installs winget if it is not installed
function WingetInstaller {
    try {
        if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "Installing Winget"
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
            }
            catch {
                Write-Host "Winget failed to install, please install it manually"
                Write-Host "https://github.com/microsoft/winget-cli/releases/"
                return $false
            }
        }
        else {
            Write-Host "Winget is already installed"
        }
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Host "An error occurred at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        return $false
    }
    return $true
}

function InstallingNerdFonts {
    try {
        if (Test-Path "fonts") {
            Remove-Item -Path fonts -Recurse -Force
            ForEach ($font in Get-ChildItem -Path . -Filter "*.zip") {
                Remove-Item -Path $font.FullName -Force
            }
        }
        Write-Host "Installing Nerd Fonts"
        New-Item -ItemType Directory -Path fonts -Force
        $URL = "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
        $URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.zip' |
        Select-Object -ExpandProperty "browser_download_url"
        #Saving name of the file and url at for loop
        ForEach ($font in $URL) {
            $fileName = $font -split "/" | Select-Object -Last 1
            # Escolhendo somente a fonte CascadiaCode
            # EN: Choosing only the CascadiaCode font
            # DISCLAIMER: I use CascadiaCode font, you can change download all fonts or change the font name
            if ( $fileName -match "CascadiaCode" ) {
                Invoke-WebRequest -Uri $font -OutFile $fileName -UseBasicParsing
                Expand-Archive -Path $fileName -DestinationPath fonts
                
                # Installando as fontes
                # EN: Installing the fonts
                $fonts = Get-ChildItem -Path fonts -Recurse -Filter "*.ttf"
                ForEach ($font in $fonts) {
                    $fontPath = "C:\Windows\Fonts\"
                    Write-Host "Installing $($font.Name) on $($fontPath)"
                    Copy-Item -Path $font.FullName -Destination $fontPath
                }
                Remove-Item -Path fonts -Recurse -Force
            }
        }
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Host "An error occurred at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        return $false
    }
    return $true
}


function Main {
    try {
        # Set execution script path
        Set-Location $scriptPath
        # Running functions
        WingetInstaller
        ApplyConfig
        InstallPackages
        InstallingNerdFonts
    }
    catch {
        Write-Host "An error occurred at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

Main