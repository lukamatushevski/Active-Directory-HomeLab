# Ticket 03: Control Panel suddenly blocked

**Type:** reproduced in the lab ([setup script](../lab/scripts/ticket-03-setup.ps1))
**Priority:** Medium
**Reporter:** Giorgi Kapanadze, Finance

> I wanted to change printer settings and Control Panel says something about "restrictions". It worked yesterday. I restarted, no change. My Finance colleagues can open it.

## Diagnosis

Questions asked: when did it start (this morning), anything else restricted (no, the Finance share still works), any change of role (no, still in Finance). The user added that Nino in HR has had Control Panel blocked for a long time.

ADUC showed Giorgi in the **HR** OU. Member Of was unchanged.

The `WS-Block-ControlPanel` GPO (User Configuration) is linked to the HR OU. User settings follow the user's OU, so moving Giorgi into HR applied HR's policy to him.

## A wrong turn

The first attempt added Giorgi to the `HR-Users` group. That did nothing for the GPO (OUs carry rules, groups carry permissions) and gave him unapproved access to HR resources. It was removed immediately.

## Fix

1. Removed `gkapanadze` from `HR-Users`.
2. Moved Giorgi back to the Finance OU.
3. Sign out / sign in.
4. Verified: `gpresult /r /scope user` no longer lists `WS-Block-ControlPanel`; Control Panel opens.

## Ticket note

> **Cause:** `gkapanadze` had been moved into the HR OU, so the HR GPO `WS-Block-ControlPanel` applied to him.
> **Actions:** moved the user back to the Finance OU. During diagnosis I added him to `HR-Users` by mistake and removed him immediately.
> **Result:** Control Panel available after signing in again; confirmed with `gpresult`.
> **Recommendation:** find out who moved the object; limit who can change objects in ADUC.

## Follow-up

"Who moved him?" couldn't be answered: directory change auditing was off. See [Module 12](../docs/12-security-and-auditing.md).

## Lessons

- Adding a group isn't a universal fix. Decide first whether the problem is permissions (group) or rules (OU/GPO).
- Document your own mistakes in the ticket too.
