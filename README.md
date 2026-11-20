# Active Directory Home Lab for Application Support

A hands-on Active Directory lab built from scratch on VMware Workstation, documenting what I learned while preparing for an **Application Support Engineer** role.

The focus is the work support teams do every day: users, groups and access problems, Group Policy, DNS, and how applications authenticate against AD. Every module pairs the concept with a lab exercise done both in the GUI and in PowerShell, and the course ends with realistic troubleshooting tickets I diagnosed and resolved in the lab.

## Lab environment

| Machine | OS | Role | IP |
|---|---|---|---|
| `DC01` | Windows Server 2025 (Desktop Experience) | Domain Controller, DNS, Global Catalog | `192.168.25.10` (static) |
| `CLIENT01` | Windows 11 Enterprise | Domain-joined workstation | DHCP, DNS → `192.168.25.10` |

- **Domain:** `lab.local` (NetBIOS `LAB`)
- **Hypervisor:** VMware Workstation Pro, NAT network `192.168.25.0/24`
- **OUs:** `IT`, `HR`, `Finance`, `Workstations`, `Service Accounts`

```
lab.local (forest / domain)
├── DC01                Domain Controller + DNS
├── OU=Workstations     CLIENT01
├── OU=HR               Nino Beridze, HR-Users
├── OU=Finance          Giorgi Kapanadze, Luka Mamaladze, Finance-Users, Finance-Reports-RW
├── OU=IT               IT-Support
└── OU=Service Accounts svc_crm (LDAP bind account for a "CRM" app)
```

All names in the lab are fictional.

## What's in this repo

| Path | Contents |
|---|---|
| [`lab/lab-setup.md`](lab/lab-setup.md) | Step-by-step build: VMs, Windows Server install, static IP, DC promotion, domain join |
| [`docs/`](docs/) | 13 modules of notes, from networking basics to security auditing |
| [`tickets/`](tickets/) | Four simulated support tickets with diagnosis, fix and ticket notes |
| [`lab/scripts/`](lab/scripts/) | PowerShell scripts that set up the ticket scenarios in the lab |
| [`cheatsheet.md`](cheatsheet.md) | Tools, commands, Event IDs and troubleshooting rules on one page |
| [`interview-questions.md`](interview-questions.md) | Common AD interview questions with short answers |

## Modules

| # | Topic | Lab highlights |
|---|---|---|
| [00](docs/00-networking-basics.md) | Networking basics: IP, DNS, client/server, VMs | `ipconfig`, `nslookup`, `ping` |
| [01](docs/01-what-is-active-directory.md) | What Active Directory is and why organisations need it | Workgroup vs domain, building the lab |
| [02](docs/02-ad-structure.md) | Domain, tree, forest, OU, DCs, sites, replication | Creating OUs, `nltest /dsgetdc` |
| [03](docs/03-users-groups-computers.md) | Users, groups, computers; group types and scopes | Access tokens, moving computers to OUs |
| [04](docs/04-dns-and-ad.md) | How AD depends on DNS | SRV records, reverse lookup zone, breaking DNS on purpose |
| [05](docs/05-authentication.md) | Kerberos, NTLM, LDAP | `klist`, Kerberos vs NTLM by name vs IP, LDAP queries |
| [06](docs/06-group-policy.md) | Group Policy | Creating/linking GPOs, LSDOU, `gpresult`, user vs computer scope |
| [07](docs/07-daily-tasks.md) | Daily support tasks | Lockout, Event 4740, password reset, onboarding, offboarding |
| [08](docs/08-tools-and-powershell.md) | ADUC, ADAC, GPMC and the AD PowerShell module | ADAC PowerShell History |
| [09](docs/09-service-accounts-and-apps.md) | Service accounts, LDAP bind, SSO | Testing binds with `ldp.exe`, LDAP error 49 |
| [10](docs/10-entra-id-and-hybrid.md) | Microsoft Entra ID, hybrid identity, MFA | Concepts |
| [11](docs/11-troubleshooting.md) | Troubleshooting | Breaking and repairing the trust relationship |
| [12](docs/12-security-and-auditing.md) | Least privilege, privileged groups, audit logs | Enabling directory change auditing, Event 5139 |

## Tickets

| # | Symptom | Root cause |
|---|---|---|
| [01](tickets/ticket-01-access-denied-payroll.md) | "Access Denied" on a payroll share | Wrong user (same name) added to the access group |
| [02](tickets/ticket-02-disabled-account.md) | "Your account has been disabled", then "Access is denied" | Account disabled and removed from groups by mistake |
| [03](tickets/ticket-03-control-panel-blocked.md) | Control Panel suddenly blocked | User moved into the wrong OU, picking up another department's GPO |
| [04](tickets/ticket-04-crm-ldap-lockout.md) | Nobody can log in to the CRM | App service account locked out by a stale password in the app config |

## Key takeaways

- **Authentication vs authorization.** "I can log in but get Access Denied" is a permissions (group) problem, not a password problem.
- **DNS first.** If pinging the IP works but the name doesn't, the problem is DNS.
- **Group changes need a new logon.** Group membership lives in the access token built at logon.
- **GPOs apply by location.** User settings follow the user's OU, computer settings follow the computer's OU.
- **Fix the cause, not the symptom.** Unlocking a service account is pointless if the app keeps sending the wrong password.
- **Audit before you need it.** Directory change auditing that wasn't enabled before an incident can't tell you who did it.
- **Verify, then document.** Diagnose, fix, confirm the fix, and write the ticket note as cause, actions, result.

## Tools and technologies

Windows Server 2025 · Active Directory Domain Services · DNS · Group Policy · Kerberos · NTLM · LDAP · PowerShell ActiveDirectory module · ADUC · ADAC · GPMC · Event Viewer · ldp.exe · VMware Workstation Pro · Microsoft Entra ID (concepts)
