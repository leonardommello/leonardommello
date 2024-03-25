$listPlugins = @(
    "PowerShellGet"
    "posh-git"
    "oh-my-posh"
    "Terminal-Icons"
    "PSReadLine"
    "psInlineProgress"
)

foreach ($modules in $listPlugins) {
    if (!(Get-Module -ListAvailable -Name $modules)) {
        Install-Module $modules -Force
    }
}

Import-Module -Name Terminal-Icons, posh-git, PSReadLine, PowerShellGet, psInlineProgress, PSWindowsUpdate

if ($host.Name -eq "ConsoleHost") {
    Import-Module -Name PSReadLine
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -EditMode Emacs
}

Set-Alias -Name vim -Value code
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1
$env:POSH_GIT_ENABLED = $true
oh-my-posh init pwsh --config "~\Documents\PowerShell\bubbles.omp.json" | Invoke-Expression

#34de4b3d-13a8-4540-b76d-b9e8d3851756 PowerToys CommandNotFound module

Import-Module "C:\Program Files\PowerToys\WinUI3Apps\..\WinGetCommandNotFound.psd1"
#34de4b3d-13a8-4540-b76d-b9e8d3851756
