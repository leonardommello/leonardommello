$modules = @(
    @{Name = 'PowerShellGet'; AllowPrerelease = $true },
    @{Name = 'posh-git'; AllowPrerelease = $true },
    @{Name = 'oh-my-posh'; AllowPrerelease = $true },
    @{Name = 'Terminal-Icons'; AllowPrerelease = $true },
    @{Name = 'PSReadLine'; AllowPrerelease = $true }
)

foreach ($module in $modules) {
    if (!(Get-Module -ListAvailable -Name $module.Name)) {
        Install-Module @module -Force
    }
}

Import-Module -Name Terminal-Icons, posh-git, PSReadLine, PowerShellGet

if ($host.Name -eq 'ConsoleHost') {
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
Clear-Host
