# Active Directory cheat sheet

## Tools (`Win + R`)

| Tool | Command | For |
|---|---|---|
| ADUC | `dsa.msc` | Users, groups, computers, OUs |
| ADAC | `dsac.exe` | Same + PowerShell History |
| GPMC | `gpmc.msc` | Group Policy |
| DNS Manager | `dnsmgmt.msc` | DNS zones and records |
| Sites and Services | `dssite.msc` | Sites, replication |
| Event Viewer | `eventvwr.msc` | Security log |
| LDP | `ldp.exe` | Test LDAP binds |
| System Properties | `sysdm.cpl` | Computer name, domain join |
| Network Connections | `ncpa.cpl` | IP and DNS settings |

## Network and DNS

| Command | Does |
|---|---|
| `hostname` / `whoami` | Which machine / which account (run first) |
| `ipconfig /all` | IP, gateway, DNS servers, MAC |
| `ping <name>` vs `ping <IP>` | IP works, name doesn't → DNS |
| `nslookup lab.local` / `nslookup <IP>` | Forward / reverse lookup |
| `nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.local` | Where is the DC? |
| `nltest /dsgetdc:lab.local [/force]` | DC and site in use |
| `ipconfig /flushdns` / `/registerdns` | Clear DNS cache / re-register (admin) |
| `Get-Date`, `w32tm /resync` | Check / sync time (Kerberos: 5 min max skew) |

## Authentication

| | Port | Notes |
|---|---|---|
| Kerberos | 88 | Tickets; default; by name. `klist`, `klist purge` |
| NTLM | | Fallback, e.g. resource accessed by IP |
| LDAP / LDAPS | 389 / 636 | Apps querying AD; error 49 = invalid credentials |

LDAP 49 sub-codes: `52e` wrong password · `533` disabled · `532` expired · `775` locked.

## Group Policy

- Works only if: **exists with settings** → **linked** → **object in that OU**.
- User settings follow the user's OU; computer settings follow the computer's OU.
- Order **LSDOU**; last applied (OU) wins on conflict.
- `gpupdate /force` · `gpresult /r /scope user|computer` · `gpresult /h C:\report.html`

## PowerShell

```powershell
Get-ADUser gkapanadze -Properties LockedOut, Enabled, LastLogonDate
Search-ADAccount -LockedOut          # / -AccountDisabled
Unlock-ADAccount gkapanadze
Enable-ADAccount alomidze            # / Disable-ADAccount
Set-ADAccountPassword gkapanadze -Reset
Set-ADUser gkapanadze -ChangePasswordAtLogon $true
Get-ADPrincipalGroupMembership nberidze | Select Name
Get-ADGroupMember "Finance-Reports-RW"
Add-ADGroupMember "Finance-Reports-RW" -Members lmamaladze
Get-ADComputer CLIENT01 | Move-ADObject -TargetPath "OU=Workstations,DC=lab,DC=local"
Test-ComputerSecureChannel [-Repair -Credential LAB\Administrator]
Get-Help <cmdlet> -Examples
```

## Event IDs (DC Security log)

| ID | Meaning |
|---|---|
| 4624 / 4625 | Logon success / failure |
| 4740 | Lockout. *Caller Computer Name* = source |
| 4767 | Unlock |
| 4722 / 4725 | Enabled / disabled |
| 4720 | User created |
| 4724 | Password reset |
| 4728 | Added to global security group |
| 5136 / 5139 | Object modified / moved (needs audit policy + SACL) |

## Symptoms → causes

| Symptom | Likely cause | Check / do |
|---|---|---|
| Ping IP ok, name fails | DNS | Client DNS = DC IP? `nslookup` |
| Added to group, still no access | Old access token | Sign out / in |
| Logged in, Access Denied | Authorization | Member Of vs Security tab |
| "Account has been disabled" | Disabled | Reason + approval; Event 4725 |
| "Account is currently locked out" | Bad passwords | Event 4740 source; unlock |
| Repeated lockouts | Stale password on another device | Event 4740 caller |
| Kerberos/logon errors, wrong clock | Time skew | `w32tm /resync` |
| GPO not applied | Link / OU / scope | `gpresult` |
| "Trust relationship failed" | Machine password mismatch | `.\localadmin` → `Test-ComputerSecureChannel -Repair` |
| App fails for everyone | Service account | App log codes; Event 4740; `ldp.exe` |
| "Not in Microsoft 365 yet" | Sync delay | Wait / check sync status |

## Daily tasks

- **Password reset:** verify identity → reset → *must change at next logon*.
- **Onboarding:** copy a template account, not a real employee.
- **Offboarding:** right person (login/ID) → disable → reset password → description with date + ticket → remove groups → Disabled Users OU → delete after retention.
- **Ticket notes:** cause + actions + result (+ recommendation).
