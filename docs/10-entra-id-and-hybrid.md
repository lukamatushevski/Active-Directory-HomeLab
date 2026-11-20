# Module 10: Microsoft Entra ID, hybrid identity and MFA

## Entra ID

**Microsoft Entra ID** (formerly Azure AD) is Microsoft's cloud identity service for Microsoft 365, Salesforce and other cloud apps. Despite the old name, it is **not AD in the cloud**.

| | AD DS (on-premises) | Entra ID |
|---|---|---|
| Where | Your servers (DC01) | Microsoft's cloud |
| Protocols | Kerberos, NTLM, LDAP | OAuth 2.0, OpenID Connect, SAML |
| Organisation | OUs | No OUs; groups |
| Device management | Group Policy | Intune |
| Access rules | GPOs | Conditional Access |
| Domain Controllers | Yes | No |
| MFA, self-service password reset | Not built in | Built in |

## Hybrid identity

Most companies have both: AD for the office, Entra ID for Microsoft 365.

```
AD (DC01)  ── Entra Connect Sync / Cloud Sync ──►  Entra ID
nberidze                                           nberidze@company.com
```

- Objects are created in **AD**, and synchronisation copies them up.
- **Password Hash Synchronization (PHS)** sends a hash of the password hash, not the password, so users have one password everywhere.
- Microsoft recommends **Cloud Sync** for new deployments; Connect Sync is the older server-based tool.

Typical ticket: *"I created the user in AD but they don't appear in Microsoft 365"* or *"my new password doesn't work in Outlook yet"*. Sync takes time; check the sync status before changing anything.

## MFA

Multi-factor authentication requires at least **two different types** of factor:

| Type | Examples |
|---|---|
| Something you know | Password, PIN |
| Something you have | Phone, Microsoft Authenticator, security key |
| Something you are | Fingerprint, face (Windows Hello) |

Password + PIN is **not** MFA: both are "something you know".

**Conditional Access** applies "if → then" rules, e.g. require MFA when signing in from outside the office, always require it for admins.

## Tickets

| Ticket | Action |
|---|---|
| New or lost phone, no codes | **Verify identity first** (attackers use exactly this call), then require MFA re-registration |
| Authenticator notifications don't arrive | Phone connectivity, time, notification permissions |
| "I keep getting MFA prompts I didn't trigger" | Security incident: someone has the password. Approve nothing; reset the password; inform security |

The last one is **MFA fatigue**: the attacker spams prompts hoping for an accidental Approve. Number matching in Authenticator counters it.

## Sources

- [Compare Active Directory to Microsoft Entra ID](https://learn.microsoft.com/entra/fundamentals/compare)
- [What is password hash synchronization](https://learn.microsoft.com/entra/identity/hybrid/connect/whatis-phs)
- [Entra Cloud Sync FAQ](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/reference-cloud-sync-faq)
