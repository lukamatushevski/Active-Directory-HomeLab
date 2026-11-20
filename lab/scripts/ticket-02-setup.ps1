# Ticket 02 scenario setup. Run on DC01 in an elevated PowerShell.
# LAB USE ONLY: the password below is a throwaway value for an isolated lab.
# Creates a Finance share with group-based permissions, then disables gkapanadze.

# --- Shared folder ---
$path = "C:\Shares\Finance-Reports"
New-Item -Path $path -ItemType Directory -Force | Out-Null
"Q4 Financial Report - CONFIDENTIAL" | Out-File "$path\Q4-Report.txt"

# --- Group + extra user ---
New-ADGroup -Name "Finance-Reports-RW" -GroupScope Global -GroupCategory Security -Path "OU=Finance,DC=lab,DC=local"
New-ADUser -Name "Ana Lomidze" -SamAccountName "alomidze" -UserPrincipalName "alomidze@lab.local" `
    -Path "OU=Finance,DC=lab,DC=local" `
    -AccountPassword (ConvertTo-SecureString "LabPass123!" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Finance-Reports-RW" -Members "alomidze"

# --- Permissions: share open to Domain Users, NTFS restricted to the group ---
New-SmbShare -Name "Finance-Reports" -Path $path -FullAccess "LAB\Domain Admins" -ChangeAccess "LAB\Domain Users" | Out-Null
$acl = Get-Acl $path
$acl.SetAccessRuleProtection($true, $false)
foreach ($id in "NT AUTHORITY\SYSTEM", "BUILTIN\Administrators") {
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($id, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")))
}
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("LAB\Finance-Reports-RW", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")))
Set-Acl $path $acl

# --- The fault ---
Disable-ADAccount -Identity "gkapanadze"

Write-Host "Scenario ready!" -ForegroundColor Green
