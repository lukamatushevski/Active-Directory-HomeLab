# Module 09: Service accounts and application integration

## Who is who

```
 User (nberidze)  →  Application (CRM)  →  Domain Controller (DC01)
                      using svc_crm
```

| Term | What it is | Analogy |
|---|---|---|
| Domain user | A person's account (`nberidze`) | Employee |
| Application | e.g. a CRM (customer relationship management system) | A robot employee |
| **Service account** | The application's own AD account (`svc_crm`) | The robot's badge |
| Domain Controller | Verifies credentials | Security desk |

When Nino logs in to the CRM, the CRM can't check her password itself. It first authenticates to AD with its own account (an **LDAP bind**), then asks AD whether Nino's credentials are valid and whether she's in the right group.

## Good practice

| Rule | Why |
|---|---|
| Dedicated account, named `svc_...` | Clearly not a person |
| Least privilege | Limits damage if stolen |
| Description with app and owner | Someone will need to know tomorrow |
| Nobody logs on interactively with it | Only the application uses it |
| Never use a personal account | The app breaks when that person leaves |

**"Password never expires"** is usually set because the password lives in the app's configuration and no human will notice the expiry; the app would just stop. The risk: a stolen password stays valid indefinitely, so the account needs minimal rights and a long, strong password. (Group Managed Service Accounts, gMSAs, solve this by rotating the password automatically.)

## Lab: being the application with ldp.exe

`ldp.exe` → Connection → Connect (`DC01`, 389) → Connection → Bind → *Bind with credentials* (`svc_crm`, password, domain `lab`).

| Account state | Result |
|---|---|
| Enabled | `Authenticated as: 'LAB\svc_crm'` |
| Disabled (fresh connection) | `Error 49: Ldap_bind_s() failed: Invalid credentials` |

Lesson: the first bind after disabling still succeeded because ldp reused the existing connection. Disconnect and reconnect to test properly.

**LDAP error 49** covers wrong password, disabled, locked and expired. AD hides the exact reason on purpose, so an attacker can't learn whether an account exists or why it failed. Applications often log a sub-code:

| Sub-code | Meaning |
|---|---|
| `data 52e` | Wrong password |
| `data 533` | Account disabled |
| `data 532` | Password expired |
| `data 775` | Account locked out |

ldp isolates the problem: if the bind works with the same account, AD is fine and the issue is in the app's configuration; if it fails, it's the account.

## SSO

**Single sign-on:** log on once, every app recognises you. Inside the domain this is Kerberos: the browser or app presents a service ticket instead of asking for a password.

| | LDAP bind | Kerberos SSO |
|---|---|---|
| User types password in the app | Yes | No |
| Needs a service account | Yes | Yes |

Cloud apps use SAML / OpenID Connect through Entra ID instead (Module 10).

"SSO works for colleagues but the app keeps asking me for a password": look at what is different for this user: a personal (non-domain) laptop, a local account, the app opened by IP (no Kerberos ticket), wrong clock, a different browser.
