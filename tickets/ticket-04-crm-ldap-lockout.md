# Ticket 04: Nobody can log in to the CRM

**Type:** reproduced in the lab ([setup script](../lab/scripts/ticket-04-setup.ps1)); DC01 played the role of the CRM server
**Priority:** High
**Reporter:** Finance team lead

> For 15 minutes nobody in Finance can log in to the CRM: "Authentication service unavailable". The CRM admin sent this log line and says he "updated something in the CRM settings" this morning:
> ```
> [ERROR] LDAP bind failed for user LAB\svc_crm: 49 Invalid Credentials (AcceptSecurityContext error, data 775)
> ```

## Diagnosis

**Two different code systems.** `49` and `data 775` come from the application's LDAP log; Event Viewer uses Event IDs. Searching Event Viewer for 49 or 775 finds nothing.

- `data 775` = **account locked out** → the matching Windows event is **4740**.
- Event Viewer (DC01) → Security → filter 4740 showed lockouts for `svc_crm`, `gkapanadze` and `nberidze`. **Timestamps** ruled the last two out: they were older lab events. Only `svc_crm` matched the 15-minute window.
- `svc_crm` event: *Caller Computer Name* = **DC01**, the CRM server in this lab.

**Chain of events:**

1. The CRM admin saved an old/wrong `svc_crm` password in the CRM configuration.
2. The CRM kept retrying its LDAP bind with it.
3. After 3 failures AD locked `svc_crm` (Event 4740).
4. With its own account locked, the CRM couldn't verify anyone, so every user's login failed. The users' accounts were fine.

## Fix

Unlocking alone would be pointless: the CRM would retry the wrong password and lock the account again within a minute. Order:

1. Contact the CRM admin; the correct password must be entered in the CRM configuration. If nobody knows it, reset `svc_crm` in AD and hand the new password over securely.
2. **Then** unlock `svc_crm` (in the lab it had already auto-unlocked after the 10-minute lockout duration; the Account tab showed it unlocked).
3. Verify: `ldp.exe` → disconnect, connect, bind as `svc_crm` → `Authenticated as: 'LAB\svc_crm'`; team lead confirmed users can log in.

## Ticket note

> **Cause:** a stale `svc_crm` password was saved during a CRM configuration update; repeated LDAP binds locked the account (Event 4740, caller DC01; CRM log: 49 / data 775).
> **Actions:** correct password entered in the CRM configuration together with the CRM admin; account unlocked.
> **Result:** bind successful in ldp; team lead confirmed the CRM works.
> **Recommendation:** coordinate service account changes with IT (change management).

## Lessons

- App log codes and Windows Event IDs are different "languages".
- Use timestamps to rule out unrelated events.
- Fix the cause, not the symptom.
- One service account can take down an application for everyone.
