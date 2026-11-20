# Module 05: Kerberos, NTLM and LDAP

## Kerberos

**Analogy: an office building.**

1. In the morning you show your passport at reception and get a **day badge**.
2. To enter the archive, you show the badge at reception (not the passport) and get an **archive card**. The archive door only knows its own cards, but it trusts reception.
3. Same for the kitchen. The passport was shown once all day.

| Story | Kerberos | In `klist` |
|---|---|---|
| Passport | Password | |
| Reception | KDC on the Domain Controller | `nltest` flag `KDC` |
| Day badge | **TGT** (Ticket Granting Ticket), issued at logon | `krbtgt/LAB.LOCAL` |
| Archive card | **Service ticket**, one per resource | `cifs/DC01`, `LDAP/DC01...` |

- The password is checked once; everything after uses tickets. This is what makes **SSO** work inside the domain.
- Kerberos proves *who you are* (authentication). Whether you may open the folder is decided by permissions and groups (authorization).
- The ticket carries the group list, which is the real reason a new group needs a new logon.
- Tickets are time-stamped: a clock difference over **5 minutes** between client and DC breaks Kerberos.
- Port **88**.

### Lab

```powershell
klist            # TGT (krbtgt) + an LDAP ticket after logon
# open \\DC01\Finance-Reports
klist            # new service ticket: cifs/DC01
```

## NTLM

Older challenge-response protocol with no tickets: the server checks every time that you know the password. Windows falls back to it when Kerberos can't be used. The most common reason is accessing a resource **by IP instead of name**: Kerberos issues tickets for service names like `cifs/DC01`, not for an IP.

Lab: opening `\\192.168.25.10\Finance-Reports` worked, but `klist` showed no new ticket; the share opened over NTLM.

NTLM is less secure and Microsoft is phasing it out. An application configured with an IP address can silently fall back to NTLM and break where NTLM is disabled. Fix: use the name.

## LDAP

AD is a big book; **LDAP** is the language programs use to query it: does this user exist, which groups is Giorgi in, what is Nino's email? Applications (CRM, portals, VPN) use LDAP to decide whether a user may log in.

Ports: **389** (LDAP), **636** (LDAPS, encrypted).

Lab: querying AD the way an application would:

```powershell
([adsisearcher]"(sAMAccountName=gkapanadze)").FindOne().Properties.memberof
```

Returned `CN=Finance-Reports-RW,...` and `CN=Finance-Users,...`. `(sAMAccountName=gkapanadze)` is an LDAP filter. Domain Users doesn't appear because it is the primary group, stored separately.

## Summary

| Protocol | Job | Analogy |
|---|---|---|
| Kerberos | Proves identity with tickets | Badge and room cards |
| NTLM | Same job, older method | Secret question at every door |
| LDAP | Searches and reads directory data | Reading the book |

## Interview notes

- *Kerberos vs NTLM?*
- *Which port does Kerberos use?* 88.
- *Why does Kerberos fail if the time is wrong?*
