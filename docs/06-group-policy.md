# Module 06: Group Policy

A **GPO (Group Policy Object)** is a set of rules applied automatically to computers and users: password length, screen lock, mapped drives and printers, blocking Control Panel.

| Section | Applies to |
|---|---|
| **Computer Configuration** | Computer objects in the linked OU |
| **User Configuration** | User objects in the linked OU |

## The three conditions

A GPO works only when all three are true ("rules written on paper, pinned to the wall, people standing in front of it"):

1. The GPO **exists and contains settings** (GPMC → Settings tab).
2. It is **linked** to an OU (or the domain/site).
3. The target object **is in that OU**.

## Processing order: LSDOU

**L**ocal → **S**ite → **D**omain → **O**U. On a conflict the last one applied (the OU) wins; non-conflicting settings from earlier levels still apply. A GPO linked to the domain is inherited by every OU.

Password and lockout policies for domain accounts only work in the **Default Domain Policy** (domain level).

Clients refresh GPOs automatically at startup and roughly every 90 minutes; `gpupdate /force` applies them now.

## Lab 1: logon banner

GPMC (`gpmc.msc`) → right-click `Workstations` → *Create a GPO in this domain, and Link it here* → `WS-Logon-Message` → Edit:

`Computer Configuration → Policies → Windows Settings → Security Settings → Local Policies → Security Options`

- *Interactive logon: Message title...* → `LAB Company`
- *Interactive logon: Message text...* → `Authorized use only!`

On CLIENT01: `gpupdate /force`, sign out: the banner appears.

**What went wrong first (and how it was found):** the GPO was accidentally linked to the domain root, so `Workstations` had no link and the banner also applied to the DC. Checked with:

```powershell
Get-GPO -Name "WS-Logon-Message" | Select DisplayName, CreationTime
(Get-GPInheritance -Target "OU=Workstations,DC=lab,DC=local").GpoLinks   # empty = not linked
```

Fixed by linking it to `Workstations` (*Link an Existing GPO*) and deleting the domain-level link. Deleting a link removes only the link, not the GPO.

## Lab 2: gpresult

```powershell
gpresult /r /scope computer
gpresult /h C:\gpreport.html    # HTML report, run elevated
```

| What you see | Meaning |
|---|---|
| GPO under **Applied GPOs** | It applies; look at the setting itself |
| GPO under **Denied GPOs** | It reached the machine but was filtered; read *Reason Denied* |
| GPO doesn't appear at all | Not linked, or the object is in a different OU |

Default Domain Policy showed as applied with *Link Location: lab.local*: domain inheritance.

## Lab 3: the trap (user settings on a computer OU)

`WS-Block-ControlPanel`: *User Configuration → Policies → Administrative Templates → Control Panel → Prohibit access to Control Panel and PC settings = Enabled*, linked to `Workstations`.

Nino (in the HR OU) logged on to CLIENT01 (in Workstations): **Control Panel still opened.**

- First finding: the GPO was empty (*User Configuration: No settings defined*). The setting had never been saved.
- Second finding, after adding it: still not applied. `gpresult /r /scope user` showed *Applied GPOs: N/A* and the user DN `CN=Nino Beridze,OU=HR,...`.

**Cause:** User Configuration applies where the **user** object lives (HR), not where the computer lives. The Workstations OU contains only computers, so the user settings hit nobody.

**Fix:** link the GPO to the HR OU. After sign out / sign in: *"This operation has been cancelled due to restrictions in effect on this computer."*

## Interview notes

- GPO processing order (LSDOU).
- "A GPO doesn't apply, what do you check?" Link, OU, User vs Computer section, then `gpresult`.
