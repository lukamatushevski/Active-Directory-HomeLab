# Ticket 01: "Access Denied" on the payroll folder

**Type:** role-play (the file server was simulated)
**Priority:** Medium
**Reporter:** Nino Beridze, HR

> My manager says IT gave me access to the HR payroll folder, but `\\fileserver\HR-Payroll` says "You don't have permission to access...". I can log in normally and email works. I need to submit the payroll sheet tomorrow.

## Diagnosis

| Step | Finding |
|---|---|
| Restart and retry (refresh the access token) | Still Access Denied |
| "Does it ask for a password?" | No. Identity is fine: **authorization**, not authentication |
| ADUC → Nino → Member Of | `Domain Users`, `HR-Users` |
| Folder → Properties → Security | Access via `LAB\HR-Payroll-Access` (Modify) |
| `HR-Payroll-Access` → Members | Includes "Nino Beridze" from **lab.local/Finance** |

The ticket's Nino lives in the **HR** OU. There are two employees named Nino Beridze, and IT added the Finance one.

## Fix

- Added the correct user by **logon name** (`nberidze`) to `HR-Payroll-Access`, not directly to the folder.
- Removed the wrong Nino from the group.
- Told the HR manager that a Finance employee had access to payroll, so they could decide whether to review it.
- Asked the user to sign out and back in. Access confirmed.

## Ticket note

> **Cause:** a Finance employee with the same name was added to `HR-Payroll-Access` instead of `nberidze` (HR).
> **Actions:** added `nberidze` to the group; removed the wrong user; informed the HR manager about the unintended access.
> **Result:** user confirmed access after signing in again.

## Lessons

- Search for users by logon name (sAMAccountName), never by display name.
- Grant access through groups, never directly on the folder.
- Unintended access to sensitive data is worth reporting, not just silently fixing.
