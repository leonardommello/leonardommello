# Checando se o script está rodando como administrador
# EN: Checking if the script is running as an administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (!$isAdmin) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

#Variables 
$userHome = $env:USERPROFILE
$installPath = "$userHome\My Settings"
$scriptPath = $PSScriptRoot


# Função que instala a lista de pacotes que eu uso no Windows
# EN: Function that installs the list of packages I use on Windows
function InstallPackages {
    try {
        $pkgList = @(
            "Git.Git"
            "GitHub.GitLFS"
            "Docker.DockerDesktop"
            "Microsoft.WindowsTerminal"
            "Microsoft.PowerShell"
            "Microsoft.PowerToys"
            "Microsoft.VisualStudioCode"
            "TheBrowserCompany.Arc"
            "Google.Chrome"
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
            "WinSCP.WinSCP"
            "Obsidian.Obsidian"
            "Python.Launcher"
            "GoLang.Go"
            "EclipseAdoptium.Temurin.17.JDK"
        )

        foreach ($pkg in $pkgList) {
            Write-Host "Installing $pkg"
            winget install -e -q $pkg  --scope machine
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

        # Deletando a pasta PowerShell e Windows Terminal do diretório de instalação
        # EN: Deleting the PowerShell and Windows Terminal folder from the installation directory
        Write-Host "Deleting PowerShell and Windows Terminal folder from the installation directory"
        if (Test-Path "$installPath\PowerShell") {
            Remove-Item -Path "$installPath\PowerShell" -Recurse -Force
        }
        if (Test-Path "$installPath\Windows Terminal") {
            Remove-Item -Path "$installPath\Windows Terminal" -Recurse -Force
        }

        # Clona arquivos para uma pasta dentro do diretório do usuário
        # EN: Clone files to a folder inside the user directory
        Write-Host "Cloning files to a folder inside the user directory"
        Copy-Item -Path "$scriptPath\PowerShell" -Destination "$installPath\PowerShell" -Recurse -Force
        Copy-Item -Path "$scriptPath\Windows Terminal" -Destination "$installPath\Windows Terminal" -Recurse -Force

        # Cria os links simbólicos
        # EN: Creates symbolic links
        Write-Host "Creating symbolic links"
        New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\Documents\PowerShell" -Target "$installPath\PowerShell"
        New-Item -ItemType SymbolicLink -Path "$terminalPath\LocalState\settings.json" -Target "$installPath\Windows Terminal\settings.json"

        # Desbloqueando o script de configuração
        # EN: Unlocking the configuration script
        Write-Host "Unlocking the configuration script"
        Unblock-File -Path "$installPath\PowerShell\Microsoft.PowerShell_profile.ps1"

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
            Remove-Item -Path "fonts" -Recurse -Force
        }
        Write-Host "Installing Nerd Fonts"
        New-Item -ItemType Directory -Path "fonts" -Force
        $URL = "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
        $assets = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json | Select-Object -ExpandProperty "assets"
        
        foreach ($asset in $assets) {
            $fileName = $asset.name
            if ($fileName -match "CascadiaCode" -and $fileName -match "\.zip$") {
                $downloadUrl = $asset.browser_download_url
                Write-Host "Downloading $fileName"
                Invoke-WebRequest -Uri $downloadUrl -OutFile "fonts\$fileName" -UseBasicParsing
                Expand-Archive -Path "fonts\$fileName" -DestinationPath "fonts"
                Remove-Item -Path "fonts\$fileName" -Force
            }
        }

        # Installando as fontes
        # EN: Installing the fonts
        $fonts = Get-ChildItem -Path "fonts" -Recurse -Filter "*.ttf"
        foreach ($font in $fonts) {
            $fontPath = $font.FullName
            Write-Host "Installing $fontPath"
            Copy-Item -Path $fontPath -Destination "$env:windir\Fonts"
        }

        # Open Windows Explorer to the fonts directory
        explorer.exe "$PSScriptRoot\fonts"
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
        # Menu de opções
        # EN: Options menu
        Write-Host "1 - Install Packages"
        Write-Host "2 - Apply Config"
        Write-Host "3 - Install Winget"
        Write-Host "4 - Installing Nerd Fonts"
        Write-Host "5 - Install All"
        Write-Host "6 - Exit"
        $option = Read-Host "Choose an option"

        switch ($option) {
            1 {
                InstallPackages
            }
            2 {
                ApplyConfig
            }
            3 {
                WingetInstaller
            }
            4 {
                InstallingNerdFonts
            }
            5 {
                InstallPackages
                ApplyConfig
                WingetInstaller
                InstallingNerdFonts
            }
            6 {
                Write-Host "Exiting..."
                exit
            }
            default {
                Write-Host "Invalid option"
            }
        }
    }
    catch {
        Write-Host "An error occurred at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

Main