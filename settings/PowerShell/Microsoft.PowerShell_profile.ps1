$modules = @(
    @{Name = 'PowerShellGet'; AllowPrerelease = $true},
    @{Name = 'posh-git'; AllowPrerelease = $true},
    @{Name = 'oh-my-posh'; AllowPrerelease = $true},
    @{Name = 'Terminal-Icons'; AllowPrerelease = $true},
    @{Name = 'PSReadLine'; AllowPrerelease = $true}
)

foreach ($module in $modules) {
    if (!(Get-Module -ListAvailable -Name $module.Name)) {
        Install-Module @module -Force
    }
}

Import-Module -Name Terminal-Icons, posh-git

if ($host.Name -eq 'ConsoleHost') {
    Import-Module -Name PSReadLine
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -EditMode Emacs
}

Set-Alias -Name vim -Value code
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1
oh-my-posh init pwsh --config "~\Documents\PowerShell\mydracula.omp.json" | Invoke-Expression
Clear-Host
