# Ticket 03 scenario setup. Run on DC01 in an elevated PowerShell.
# LAB USE ONLY: the password below is a throwaway value for an isolated lab.
# Adds some unrelated changes as noise, then moves gkapanadze into the HR OU,
# where the WS-Block-ControlPanel GPO (user settings) is linked.

New-ADUser -Name "Mariam Kvaratskhelia" -SamAccountName "mkvaratskhelia" -UserPrincipalName "mkvaratskhelia@lab.local" `
    -Path "OU=IT,DC=lab,DC=local" `
    -AccountPassword (ConvertTo-SecureString "LabPass123!" -AsPlainText -Force) -Enabled $true
New-ADGroup -Name "IT-Support" -GroupScope Global -GroupCategory Security -Path "OU=IT,DC=lab,DC=local"
Add-ADGroupMember -Identity "IT-Support" -Members "mkvaratskhelia"

# --- The fault ---
Get-ADUser gkapanadze | Move-ADObject -TargetPath "OU=HR,DC=lab,DC=local"

Set-ADUser -Identity "mkvaratskhelia" -Description "IT Support - Helpdesk"
Write-Host "Scenario ready!" -ForegroundColor Green
