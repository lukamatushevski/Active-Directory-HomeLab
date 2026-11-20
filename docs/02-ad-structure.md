# Module 02: AD structure

## Logical structure

| AD term | Analogy | In the lab |
|---|---|---|
| **Forest** | The whole corporation; the security boundary | The forest created at DC promotion |
| **Tree** | One company with its own name space (`lab.local`, `sales.lab.local`) | `lab.local` |
| **Domain** | One building: a management unit with its own users, computers, groups | `lab.local` |
| **OU (Organizational Unit)** | Departments inside the building | `IT`, `HR`, `Finance`, `Workstations` |

The lab is 1 forest = 1 tree = 1 domain, like most small and medium companies.

### OU vs container

| | OU | Container |
|---|---|---|
| Created by | You | AD (`Users`, `Computers`, `Builtin`) |
| GPO can be linked | Yes | **No** |
| Can hold OUs | Yes | No |
| DN prefix | `OU=` | `CN=` |

A new computer lands in the `Computers` container, where no GPO can be linked. Moving it into an OU is a common fix for "GPO doesn't apply to the new PC".

### OU vs group (classic interview question)

- **OU** organises objects and is where GPOs are linked (rules).
- **Group** grants permissions (access).

### Distinguished Name

`OU=IT,DC=lab,DC=local` reads right to left, like a path: `local` → `lab` → `IT`.

## Physical structure

- **Multiple DCs:** companies run at least two, for redundancy and load sharing.
- **Replication:** DCs continuously sync changes to each other. It is multi-master: a change can be made on any DC. Changes take time to reach every DC, which explains tickets like "the new password works in one system but not another".
- **Sites:** physical locations defined by IP subnets. Clients use the closest DC, and replication between sites is scheduled to spare WAN links.

Domain = logical (who manages what). Site = physical (where things are).

## Lab

GUI: `dsa.msc` → right-click `lab.local` → New → Organizational Unit (`IT`, `HR`).

PowerShell:

```powershell
New-ADOrganizationalUnit -Name "Finance" -Path "DC=lab,DC=local"
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
```

Which DC and site does this machine use?

```powershell
nltest /dsgetdc:lab.local
```

Output showed `DC01`, `Default-First-Site-Name`, and flags such as `KDC` (issues Kerberos tickets), `GC` (Global Catalog), `TIMESERV` (time source) and `CLOSE_SITE`.

`dssite.msc` (Active Directory Sites and Services) shows the site and the DC inside it.
