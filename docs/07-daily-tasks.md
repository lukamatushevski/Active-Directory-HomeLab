# Module 07: Daily support tasks

## Locked vs disabled

| | Locked | Disabled |
|---|---|---|
| Who | AD, automatically after bad passwords | A person, on purpose |
| Fix | Unlock (or wait for lockout duration) | Find out why; manager approval before enabling |
| Event ID | **4740** | **4725** |

Either way the object, its SID and its groups remain.

## Lockout policy (lab)

Default Domain Policy → `Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Account Lockout Policy`:

| Setting | Value | Meaning |
|---|---|---|
| Account lockout threshold | 3 | Locked after 3 bad passwords |
| Account lockout duration | 10 min | Unlocks itself after 10 minutes |
| Reset account lockout counter after | 10 min | Bad-attempt counter resets |
| Allow Administrator account lockout | Enabled | The admin can be locked out too |

Lessons from setting it up:

- The first attempt showed `0 invalid logon attempts` in GPMC Settings: the value hadn't been saved (the *Suggested Value Changes* dialog needs OK), and GPMC's Settings view needs a refresh (F5).
- Bad passwords are counted by the **DC**, not the client, so the policy has to reach the DC (`gpupdate /force` on DC01).

## Unlock

1. ADUC (`dsa.msc`) → user → **Account** tab → *"Unlock account. This account is currently locked out..."*
2. Find the source: Event Viewer on the DC → Security → Filter → **4740** → *Caller Computer Name*. Repeated lockouts usually come from an old password saved on a phone, a mapped drive or another PC.
3. Tick **Unlock account** → OK.

Note: right-clicking a user in ADUC never shows *Unlock*; it's only on the Account tab.

## Password reset

1. **Verify identity first.** Call back on the official number, confirm with the manager or follow company procedure. Urgency and pressure ("quick, my boss is waiting!") are classic social engineering.
2. ADUC → right-click → **Reset Password...** → temporary password.
3. Tick **User must change password at next logon** (and *Unlock the user's account* if needed).

## Onboarding

**Copy** an existing account: right-click → Copy... → new name, logon, temporary password. Group memberships and OU are copied automatically.

Copying a long-serving employee also copies years of extra access (**privilege creep**). Better: copy a disabled **template account** (e.g. `_Template-Finance`) that has only the baseline groups, and grant extra access only with approval.

## Offboarding checklist

1. Confirm it's the right person: login, email or employee ID, not just a name.
2. **Disable** the account. Don't delete it.
3. **Reset** the password to a random value.
4. **Description:** `Disabled 19.11.2026 - HR ticket #1234`.
5. Screenshot **Member Of**, then remove the groups (Domain Users stays; it's the primary group).
6. Move to a *Disabled Users* OU; delete after the retention period (often 30–90 days).

## Interview notes

- *Walk me through offboarding.*
- *How do you verify identity before a password reset?*
- *Locked vs disabled?*
