# Module 03: Users, groups and computers

## Users

A **user object** is an employee's entry in AD.

| Attribute | Example | Meaning |
|---|---|---|
| Name | Nino Beridze | Display name |
| **sAMAccountName** | `nberidze` | Classic logon name: `LAB\nberidze`. Unique |
| **UPN** | `nberidze@lab.local` | Email-style logon; usually matches email, used in the cloud (Entra ID, Microsoft 365) |
| **SID** | `S-1-5-21-...-1107` | Unique security ID. Permissions are granted to the SID, not the name |
| **ObjectGUID** | `41e87ee4-...` | Unique AD ID; survives renames and moves |
| Enabled | True / False | Active or disabled |
| LockedOut | True / False | Locked by too many bad passwords |

**"User must change password at next logon"** on a new or reset account means only the user ends up knowing the password. The admin who set a temporary one can't be blamed for later activity (accountability).

**Don't delete and recreate an account:** the new one gets a new SID and loses every permission.

## Groups

A group lets you grant access once to many people. Add the user to the group; never grant permissions to individuals directly.

| Type | Use |
|---|---|
| **Security** | Permissions on files, folders, apps. Most support work |
| **Distribution** | Email list only; cannot be used for permissions |

| Scope | Typical use |
|---|---|
| **Global** | Group *people* (e.g. "HR staff") |
| **Domain Local** | Grant access to a *resource* (e.g. "HR share: read") |
| **Universal** | Multi-domain forests |

The classic pattern is AGDLP: **A**ccounts go into **G**lobal groups, which go into **D**omain **L**ocal groups, which get **P**ermissions.

### The access token (support's golden rule)

When a user logs on, Windows builds an **access token** containing their group list. Adding them to a group later does nothing until they get a new token.

> After adding someone to a group: *"Please sign out and sign back in (or restart)."*

Lab proof: Nino was added to `HR-Users` while logged on. `whoami /groups | findstr "LAB"` showed nothing; after sign out / sign in, `LAB\HR-Users` appeared.

`whoami /groups` also shows integrity level: **Medium** for a standard user, **High** for an elevated admin.

## Computers

A computer joined to the domain gets a **computer object** with its own account and password, used to prove to the DC that it is a trusted member (the **secure channel**). Windows changes this password automatically, about every 30 days.

If the computer's copy and AD's copy of that password stop matching (restoring an old snapshot, a long time offline, someone resetting the account), you get **"The trust relationship between this workstation and the primary domain failed"**. See [Module 11](11-troubleshooting.md).

## Lab

GUI: `dsa.msc` → HR → New → User (Nino Beridze, `nberidze`), then New → Group `HR-Users` (Global, Security) → Members → Add.

PowerShell:

```powershell
New-ADUser -Name "Giorgi Kapanadze" -GivenName "Giorgi" -Surname "Kapanadze" `
  -SamAccountName "gkapanadze" -UserPrincipalName "gkapanadze@lab.local" `
  -Path "OU=Finance,DC=lab,DC=local" `
  -AccountPassword (Read-Host -AsSecureString "Password") `
  -Enabled $true -ChangePasswordAtLogon $true

New-ADGroup -Name "Finance-Users" -GroupScope Global -GroupCategory Security -Path "OU=Finance,DC=lab,DC=local"
Add-ADGroupMember -Identity "Finance-Users" -Members "gkapanadze"
Get-ADGroupMember "Finance-Users"
```

Move the computer out of the default container into an OU so GPOs can apply:

```powershell
Get-ADComputer CLIENT01 | Move-ADObject -TargetPath "OU=Workstations,DC=lab,DC=local"
```

DN before: `CN=CLIENT01,CN=Computers,DC=lab,DC=local`. After: `CN=CLIENT01,OU=Workstations,DC=lab,DC=local`.
