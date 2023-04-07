Get-ChildItem -Path $env:LOCALAPPDATA\Microsoft\PowerShell\secretmanagement

Get-Secret -Name Password1 -AsPlainText
Set-Secret -Name Password1 -Secret "N3wPa55w0rd"

Set-Secret -Name AzTenantID -Secret 'f6631820-e272-4579-85a4-227fce070261'
Get-Secret -Name AzTenantID -AsPlainText

Get-Secret -Name q_TMHCC_Azure

Get-SecretInfo -Vault SecretStore

