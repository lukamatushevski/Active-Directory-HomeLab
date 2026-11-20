# Ticket 02: "Your account has been disabled"

**Type:** reproduced in the lab ([setup script](../lab/scripts/ticket-02-setup.ps1))
**Priority:** High
**Reporter:** Giorgi Kapanadze, Finance

> I can't log in since this morning, and I'm sure my password is right. I need the Q4 report from `\\DC01\Finance-Reports` today.

## Part 1: can't log in

| Step | Finding |
|---|---|
| Restart, read the exact error | *"Your account has been disabled. Please see your system administrator."* |
| Reproduce on CLIENT01 as `LAB\gkapanadze` | Same message |
| ADUC → Finance → Giorgi | Down-arrow icon; Account tab: account is disabled |

**Decision:** don't re-enable it blindly. A disabled account can be intentional (termination, investigation). Told the user the account was disabled and the reason was being checked (without promising anything), then escalated to the team lead with the evidence.

Who disabled it and when: Event Viewer → Security → filter **4725**.

**Team lead:** HR terminated a *Giorgi Kapanidze* yesterday and disabled the wrong account. Approved re-enabling. Enabled the account; the user logged in and changed his password.

## Part 2: "Access is denied" on the share

| Step | Finding |
|---|---|
| `C:\Shares\Finance-Reports` → Security | `Finance-Reports-RW` has Modify |
| Giorgi → Member Of | `Domain Users`, `Finance-Users`. Not in `Finance-Reports-RW` |

HR's offboarding mistake also removed him from his groups.

**Option rejected:** granting `Finance-Users` on the folder would give every Finance employee access to confidential reports (against least privilege). `-RW` in a group name means Read/Write on that resource, not "the whole department".

**Fix:** after the team lead confirmed, added `gkapanadze` back to `Finance-Reports-RW`; user signed out and in; access confirmed.

## Lessons

- Disabled ≠ locked: enabling needs a reason and approval.
- One mistake (wrong account offboarded) caused two problems (disabled + groups removed).
- Don't infer permissions from group names; confirm with the owner.
