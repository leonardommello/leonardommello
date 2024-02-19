# My Personal Settings
## Windows

### Install Apps necessary to configure the environment

1. Run the script "install.ps1"

### How to Configure VSCode

#### Using profile method

1. Open VSCode
2. Open the Command Palette (Ctrl+Shift+P)
3. Type "Profiles: import profile...'
4. Select the file "settings\VSCode\default.code-profile"
    
#### Importig RawData to VSCode folder

1. Copy the folder "settings\VSCode\RawData" to the folder:
    - Windows: %APPDATA%\Code\User
    - macOS: $HOME/Library/Application Support/Code/User
    - Linux: $HOME/.config/Code/User
2. Open VSCode

### How to Configure Windows Terminal

1. Open Windows Terminal
2. Open the Settings (Ctrl+,)
3. Copy the content of "settings\WindowsTerminal\settings.json" to the file "settings.json"
4. Save the file (Ctrl+S)

### How to Configure PowerShell Core

#### Importing Profile

1. Open PowerShell Core
2. Type "notepad $PROFILE"
3. Copy the content of "settings\PowerShell\profile.ps1" to the file "Microsoft.PowerShell_profile.ps1"
4. Save the file (Ctrl+S)

## Linux
