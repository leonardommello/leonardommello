Import-Module -Name Terminal-Icons
Import-Module -Name posh-git
Set-Alias -Name vim -Value code
if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadLine
}
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1
oh-my-posh init pwsh --config "~\Documents\PowerShell\mydracula.omp.json" | Invoke-Expression
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -EditMode Emacs
clear