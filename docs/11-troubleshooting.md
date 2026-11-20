# Module 11: Troubleshooting

## Method

1. Confirm the user's report: reproduce it, get the exact error text.
2. Check the simple things first: logon format (`LAB\user`, not `LAB/user`), Caps Lock, keyboard layout.
3. Authentication or authorization?
4. Collect data and compare (Member Of vs folder Security, `gpresult`, event logs, timestamps).
5. **Isolate:** test one component on its own (another account, `ldp.exe`, IP vs name).
6. If unsure, don't fix blind. Escalate with facts.
7. **Diagnose → fix → verify.** Then document cause, actions, result.

## Lab: "The trust relationship between this workstation and the primary domain failed"

**Breaking it:** DC01 → ADUC → Workstations → CLIENT01 → right-click → **Reset Account**. This changes the computer's password in AD; CLIENT01 still has the old one.

**What happened:**

1. After a restart, Nino's logon said *"The user name or password is incorrect."* Not the expected error.
2. Isolation: logging on as Giorgi (known password) **worked**. So the failure for Nino was most likely her password (reset it in ADUC), and Giorgi's logon was probably served from **cached credentials**, which is why trust failures don't show up for everyone at once.
3. Next attempt: **"The trust relationship between this workstation and the primary domain failed."**

**Fixing it:**

Domain accounts can't log on, but a **local** account doesn't need the DC: log on as `.\localadmin`, open PowerShell as administrator, and first run `hostname` (see below).

```powershell
hostname                                                          # CLIENT01, not the host laptop
Test-ComputerSecureChannel                                        # False: trust broken
Test-ComputerSecureChannel -Repair -Credential LAB\Administrator  # True: new machine password set
Test-ComputerSecureChannel                                        # True: verified
```

Domain admin credentials are needed because the DC no longer trusts the computer to change its own password.

GUI alternative (slower, two restarts): `sysdm.cpl` → move to a workgroup → restart → rejoin `lab.local` → restart.

**Mistake worth remembering:** the first `-Repair` attempt was run on the host laptop, not the VM. The error mentioned the host's computer name and *"not currently part of a domain"*. Always check `hostname`.

**Real-world causes:** restoring a VM snapshot older than the last machine password change, a computer offline for a long time, someone resetting or recreating the computer object.

## Ticket simulations

See [`tickets/`](../tickets/). Patterns they cover:

| Symptom | Where to look |
|---|---|
| Access Denied after login | Group membership vs folder permissions |
| "Your account has been disabled" | Account tab; Event 4725; ask before enabling |
| A policy suddenly applies to one user | User's OU (DN) and `gpresult /r /scope user` |
| An app fails for everyone | The app's service account; app log codes; Event 4740 |
