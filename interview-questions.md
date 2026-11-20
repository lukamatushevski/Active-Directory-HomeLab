# Interview questions

Short answers to questions that come up in support / sysadmin interviews about Active Directory.

## Fundamentals

**What is Active Directory?**
Microsoft's directory service. It centrally stores users, computers and groups, authenticates users, controls access through group membership, and manages computers with Group Policy.

**Workgroup vs domain?**
In a workgroup every PC has its own local accounts and is managed separately. In a domain, accounts live on a Domain Controller and work on every domain-joined computer, managed centrally.

**Authentication vs authorization?**
Authentication proves who you are (logon). Authorization decides what you may access (groups and permissions). "I can log in but get Access Denied" is authorization.

**What is a Domain Controller?**
A Windows Server running AD DS. It stores the directory database and authenticates users and computers.

**What is DSRM?**
Directory Services Restore Mode: a DC boot mode for restoring or repairing the AD database, with its own password set during promotion.

**Domain, tree, forest?**
A domain is a management unit; a tree is domains sharing a namespace; a forest is one or more trees and is the security boundary.

**OU vs group?**
An OU organises objects and is where GPOs are linked. A group is used to grant permissions.

**OU vs container?**
OUs are created by admins and can have GPOs linked. Default containers like `Users` and `Computers` can't.

**Security vs distribution group?**
Security groups grant permissions; distribution groups are only email lists.

**Global vs domain local vs universal?**
Global groups collect users; domain local groups are granted permissions on resources; universal groups span domains in a forest (AGDLP).

## DNS and authentication

**Why does AD depend on DNS?**
Clients find Domain Controllers through DNS SRV records. If DNS is wrong, logon, Group Policy and domain join fail.

**Why does a DC need a static IP?**
DNS points clients to its address; if it changed, clients would look in the wrong place.

**Kerberos vs NTLM?**
Kerberos uses tickets from the KDC on port 88 and is the default in a domain. NTLM is an older challenge-response protocol used as a fallback, for example when a resource is accessed by IP.

**Why does Kerberos fail when the clock is wrong?**
Tickets are time-stamped; a skew of more than 5 minutes is rejected.

**LDAP and LDAPS ports?**
389 and 636.

**What is a TGT?**
The Ticket Granting Ticket issued at logon; it's used to obtain service tickets for each resource without re-entering the password.

## Group Policy

**GPO processing order?**
LSDOU: Local, Site, Domain, OU. On conflict the last applied (OU) wins.

**A GPO doesn't apply. What do you check?**
That it has settings, that it's linked to the right OU, that the object is in that OU, whether the setting is under User or Computer Configuration, then run `gpresult`.

**`gpupdate /force` vs `gpresult`?**
`gpupdate /force` applies policies now; `gpresult` shows which policies applied and why others didn't.

## Support scenarios

**A user was added to a group but still has no access.**
Group membership is in the access token built at logon. They need to sign out and back in.

**A user keeps getting locked out.**
Find Event 4740 on the DC; *Caller Computer Name* shows the device sending the bad password (often a phone or another PC with an old saved password).

**How do you verify identity before a password reset?**
Call back on the official number, confirm with the manager or follow company procedure. Pressure and urgency are red flags for social engineering.

**Locked vs disabled?**
Locked happens automatically after bad passwords; unlock it. Disabled is deliberate; find out why and get approval before enabling.

**Walk me through offboarding.**
Confirm the right person by login or employee ID, disable the account (don't delete it), reset the password, add a description with date and ticket, remove group memberships, move to a disabled OU, delete after the retention period.

**Why not delete and recreate an account?**
The new account gets a new SID and loses all permissions.

**"The trust relationship between this workstation and the primary domain failed."**
The computer's machine password no longer matches AD. Log on with a local admin, run `Test-ComputerSecureChannel -Repair -Credential DOMAIN\admin` and verify, or rejoin the domain.

**An application fails for every user at once.**
Check its service account: the app's log (LDAP error 49 and its sub-code), Event 4740, and test a bind with `ldp.exe`. Fix the stored password before unlocking.

## Cloud and security

**AD vs Entra ID?**
AD is on-premises with Kerberos/LDAP, OUs and GPOs. Entra ID is cloud identity using OAuth, OpenID Connect and SAML, with Intune and Conditional Access instead of GPOs.

**What is hybrid identity?**
On-premises AD synchronised to Entra ID (Cloud Sync or Connect Sync, usually with password hash sync) so users have one identity everywhere.

**What is MFA?**
Authentication with at least two different factor types: something you know, have or are. Password + PIN is not MFA.

**A user gets MFA prompts they didn't trigger.**
Treat it as an incident: someone has the password. Approve nothing, reset the password, inform security (MFA fatigue).

**What is least privilege?**
Only the access a task needs, for only as long as it needs it.

**Why separate admin accounts?**
Daily work (email, browsing) shouldn't run with admin rights, and audit logs are only meaningful when each admin account belongs to one person.
