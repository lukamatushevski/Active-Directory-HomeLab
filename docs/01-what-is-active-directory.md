# Module 01: What is Active Directory

## The problem: a workgroup

In a **workgroup**, every computer keeps its own **local accounts** (`COMPUTERNAME\user`). In a company of 100 people and 100 PCs:

- A new employee who can use any PC needs an account created on every PC.
- A forgotten password has to be reset on the right machine.
- A leaver's account has to be removed everywhere. Miss one PC and they keep access.
- A setting like "lock the screen after 5 minutes" has to be applied 100 times.

## The solution: a domain

**Analogy:** a security desk at the building entrance with one book listing every employee, their department and which rooms they may enter. Everyone has one badge that opens every door they're allowed through. Disable the badge once and it stops working everywhere.

**Active Directory Domain Services (AD DS)** is Microsoft's directory service: a hierarchical database of network **objects** (users, computers, groups) and their **attributes** (name, email, department, password data). It is optimised for reads: accounts are checked constantly but change rarely.

| Term | Meaning | Analogy |
|---|---|---|
| **Object** | Anything stored in AD: user, computer, group | An entry in the book |
| **Attribute** | A property of an object | A field in the entry |
| **Domain** | All objects managed by one AD, e.g. `lab.local` | The building |
| **Domain Controller (DC)** | A Windows Server running AD DS | The security desk |
| **Domain account** | Stored on the DC, works on every domain computer | The badge |
| **Local account** | Exists on one computer only | A key to one room |

## What AD does

1. **Identity:** stores who is who.
2. **Authentication:** checks that you are who you say you are.
3. **Authorization:** decides what you may access (via group membership).
4. **Management:** central configuration through Group Policy.

### Authentication vs authorization

- **Authentication** = *who are you?* "My password is rejected" is authentication.
- **Authorization** = *what may you do?* "I logged in to the CRM but Reports says Access Denied" is authorization.

These need completely different diagnostics, so telling them apart is the first step of most tickets.

## Why it matters for application support

Many business applications (CRM, ERP, portals, VPN) don't store their own users. They ask AD: does this user exist, is the password right, are they in `CRM_Users`? So a lot of "the app is broken" tickets are really AD problems: a locked account, an expired password, a missing group.

## Lab

- Checked the host: `(Get-CimInstance Win32_ComputerSystem).PartOfDomain` → `False`; user shows as `COMPUTER\user` (a local account).
- Built the lab: see [`lab/lab-setup.md`](../lab/lab-setup.md). Note: **Windows Home editions cannot join a domain**; Pro, Enterprise or Education is required.

## Interview notes

- *What is AD?* Microsoft's directory service that centrally stores users, computers and groups, handles authentication and authorization, and manages computers through Group Policy.
- *Workgroup vs domain*, *authentication vs authorization*, *what is a DC*.
- LDAP uses port **389**, LDAPS **636**.
