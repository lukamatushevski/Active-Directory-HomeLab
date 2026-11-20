# Module 12: Security and auditing

## Privileged groups

| Group | Power |
|---|---|
| **Domain Admins** | Everything in the domain: every computer, server and DC |
| **Enterprise Admins** | Everything in the forest |
| **Schema Admins** | Change the AD schema |

Rules:

- **Few members** (2–5 people, not 50). In the lab: only `Administrator`.
- **Separate admin accounts:** `jdoe` for email and browsing, `adm-jdoe` for admin work. A phishing click then compromises the normal account, not a Domain Admin.
- **Least privilege:** support doesn't need Domain Admin to reset passwords. **Delegation** grants specific rights, e.g. reset password and unlock in the Finance and HR OUs only.

Why reading email as a Domain Admin is dangerous: one phishing link runs malware with domain-wide rights, and ransomware can reach every server at once.

## Audit logs

| Event ID | Meaning |
|---|---|
| 4624 / 4625 | Logon succeeded / failed |
| 4740 | Account locked out (Caller Computer Name = source) |
| 4767 | Account unlocked |
| 4720 | User account created |
| 4722 / 4725 | Account enabled / disabled |
| 4724 | Password reset by an admin |
| 4728 | Member added to a global security group |
| 5136 / 5139 | Directory object modified / moved |

## Lab: who moved Giorgi into HR? (Ticket 03 follow-up)

```cmd
auditpol /get /subcategory:"Directory Service Changes"
```

Result: **No Auditing**. Nobody can ever find out who moved Giorgi, because the change was never recorded.

> Auditing has to be enabled **before** an incident.

### Enabling it

1. **Audit policy** (the camera is switched on): GPMC → Domain Controllers OU → *Default Domain Controllers Policy* → Edit →
   `Computer Configuration → Policies → Windows Settings → Security Settings → Advanced Audit Policy Configuration → Audit Policies → DS Access → Audit Directory Service Changes` → Success. Then `gpupdate /force` on the DC; `auditpol` now shows **Success**.
2. **SACL** (the camera is pointed at the room): ADUC → View → Advanced Features → `lab.local` → Properties → Security → Advanced → **Auditing** → Add → Principal `Everyone`, Type Success, *This object and all descendant objects*, permissions *Write all properties*, *Create all child objects*, *Delete all child objects*.

Moving a user with only step 1 done produced no event. After step 2, moving Luka produced **Event 5139**:

| Field | Value |
|---|---|
| Subject | `LAB\Administrator` |
| Old DN | `CN=Luka Mamaladze,OU=Finance,DC=lab,DC=local` |
| New DN | `CN=Luka Mamaladze,OU=HR,DC=lab,DC=local` |
| Time | 20.11.2026 20:23:48 |

**Final lesson:** the subject is `Administrator`. If five people share that account, the log still can't say which of them did it. Auditing is only useful when **one account = one person**.

## Sources

- [Advanced audit policy configuration](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/security-best-practices/advanced-audit-policy-configuration)
- [Monitoring Active Directory for signs of compromise](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/security-best-practices/monitoring-active-directory-for-signs-of-compromise)
