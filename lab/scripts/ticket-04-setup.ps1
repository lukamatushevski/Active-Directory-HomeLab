# Ticket 04 scenario setup. Run on DC01 in an elevated PowerShell.
# LAB USE ONLY: the passwords below are throwaway values for an isolated lab.
# Simulates a CRM server retrying an LDAP bind with a stale password for svc_crm,
# which locks the account (requires the lab's lockout threshold of 3).

New-ADUser -Name "Davit Beridze" -SamAccountName "dberidze" -UserPrincipalName "dberidze@lab.local" `
    -Path "OU=Finance,DC=lab,DC=local" `
    -AccountPassword (ConvertTo-SecureString "LabPass123!" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Finance-Users" -Members "dberidze"

# --- The fault: 4 failed LDAP binds with an old password ---
1..4 | ForEach-Object {
    try {
        (New-Object System.DirectoryServices.DirectoryEntry("LDAP://DC01.lab.local", "LAB\svc_crm", "Crm2026!old")).RefreshCache()
    } catch {}
}

Set-ADUser -Identity "dberidze" -Description "Finance - Accountant"
Write-Host "Scenario ready!" -ForegroundColor Green
