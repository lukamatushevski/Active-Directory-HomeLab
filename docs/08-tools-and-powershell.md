# Module 08: Tools and PowerShell

## Tools

All open with `Win + R`. They are built into the DC; on a workstation install **RSAT** (Settings → System → Optional features → *RSAT: Active Directory Domain Services*).

| Tool | Command | Used for |
|---|---|---|
| ADUC | `dsa.msc` | Users, groups, computers, OUs. The one most companies use |
| ADAC | `dsac.exe` | Same, newer UI, plus Recycle Bin, fine-grained password policies and **PowerShell History** |
| GPMC | `gpmc.msc` | Group Policy |
| DNS Manager | `dnsmgmt.msc` | Zones and records |
| Sites and Services | `dssite.msc` | Sites, replication |
| Event Viewer | `eventvwr.msc` | Security log (4740, 4725, ...) |
| LDP | `ldp.exe` | Testing LDAP binds like an application |

## ADAC PowerShell History

Do something in the GUI, and ADAC shows the equivalent PowerShell at the bottom. Resetting a password produced:

- `Set-ADAccountPassword` (the reset)
- `Set-ADUser` (the *must change password at next logon* flag)

A good way to learn the cmdlets without memorising them.

## Commands for support

| Task | Command |
|---|---|
| User status | `Get-ADUser gkapanadze -Properties LockedOut, Enabled, LastLogonDate` |
| All locked-out accounts | `Search-ADAccount -LockedOut` |
| Unlock | `Unlock-ADAccount gkapanadze` |
| All disabled accounts | `Search-ADAccount -AccountDisabled` |
| Disable / enable | `Disable-ADAccount alomidze` / `Enable-ADAccount alomidze` |
| User's groups | `Get-ADPrincipalGroupMembership nberidze \| Select Name` |
| Group members | `Get-ADGroupMember "Finance-Reports-RW"` |
| Add to group | `Add-ADGroupMember "Finance-Reports-RW" -Members lmamaladze` |
| Examples for any cmdlet | `Get-Help Unlock-ADAccount -Examples` |

## Lab findings

- `Search-ADAccount -AccountDisabled` returned Ana (offboarded), plus **Guest** (built-in, disabled by default) and **krbtgt**: the Kerberos service account whose key signs every TGT. It is always disabled and must never be enabled or deleted.
- `LastLogonDate` was empty for Luka: the account had never been used. In audits, accounts with no logon for 90+ days are often leavers nobody disabled, and a favourite target for attackers.
