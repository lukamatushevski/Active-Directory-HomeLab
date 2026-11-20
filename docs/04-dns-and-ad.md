# Module 04: DNS and Active Directory

## Why AD depends on DNS

DNS in AD stores more than "name → IP". It also stores **service locations** in **SRV records**: where the DC is, where Kerberos is, where LDAP is. A client doesn't know which server is the DC; it asks DNS.

If DNS is wrong, the client can't find a DC, and logon, Group Policy, domain join and app authentication all fail.

Two rules follow:

- The **DC needs a static IP**. Clients find it through the address in DNS; if a DHCP address changed, DNS would point to the old one.
- **Clients must use the DC as their DNS server**, not the router or a public resolver.

## Record types

| Record | Question | Example |
|---|---|---|
| **A** | Name → IP | `dc01.lab.local` → `192.168.25.10` |
| **PTR** | IP → name (reverse) | `192.168.25.10` → `DC01.lab.local` |
| **SRV** | Where is a service? | `_ldap._tcp.dc._msdcs.lab.local` → `dc01.lab.local:389` |

**Dynamic DNS:** domain computers register their own A records at startup, on IP change and periodically. To force it: `ipconfig /registerdns` (admin).

## Lab

### Looking up the DC

```powershell
nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.local
```

Returned `svr hostname = dc01.lab.local`, `port = 389`, `192.168.25.10`.

DNS Manager (`dnsmgmt.msc`) → Forward Lookup Zones → `lab.local` shows A records for DC01 and CLIENT01 (which CLIENT01 created itself) plus the `_tcp` and `_msdcs` SRV folders.

### Reverse lookup zone

`nslookup` first tries to resolve the DNS server's own IP to a name. With no reverse zone it prints `Server: UnKnown` and a timeout before answering.

Fix: DNS Manager → Reverse Lookup Zones → New Zone → Primary, AD-integrated, IPv4, network ID `192.168.25`, secure dynamic updates only. Then `ipconfig /registerdns` on both machines.

After: `Server: DC01.lab.local`, and `nslookup 192.168.25.10` returns `DC01.lab.local`.

### Breaking DNS on purpose

On CLIENT01, the preferred DNS server was changed from `192.168.25.10` to the VMware gateway `192.168.25.2`:

| Command | Result | Why |
|---|---|---|
| `ipconfig /flushdns` | OK | Clears the client's DNS cache |
| `nslookup lab.local` | Non-existent domain | The gateway knows nothing about `lab.local` |
| `nltest /dsgetdc:lab.local` | Still succeeded | Served from the cached DC location; `/force` makes it look again |
| `ping dc01.lab.local` | Could not find host | Name not resolved |
| `ping 192.168.25.10` | Replies | The network itself is fine |
| `gpupdate /force` | Failed: could not resolve the computer name | GPO processing can't find the DC |

> **Golden rule:** ping by IP works, ping by name doesn't → it's DNS.
> A cache can hide a problem, so flush or force when testing.

Restoring the DNS server and running `ipconfig /flushdns` and `gpupdate /force` fixed everything.

## Interview notes

- *Why does AD depend on DNS?* Clients find Domain Controllers through DNS SRV records.
- *Why does a DC need a static IP?*
- `ipconfig /flushdns`, `ipconfig /registerdns`, `nslookup`.
