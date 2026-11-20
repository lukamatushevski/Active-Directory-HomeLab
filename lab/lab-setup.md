# Lab setup

Building a two-machine Active Directory lab on VMware Workstation Pro.

## Requirements

- Host: 16 GB RAM or more recommended (built on 32 GB, Intel i7, Windows 11 Pro).
- VMware Workstation Pro 17 or later (vTPM support for Windows 11). Hyper-V also works but needs manual NAT setup.
- ISOs from the [Microsoft Evaluation Center](https://www.microsoft.com/evalcenter):
  - Windows Server 2025, ISO, 64-bit (180-day evaluation; activate online within 10 days).
  - Windows 11 Enterprise, ISO, 64-bit (90-day evaluation). Not the LTSC one.
- Clients must be Pro, Enterprise or Education. **Windows Home cannot join a domain.**

## 1. DC01: Windows Server 2025

**VM:** New Virtual Machine → Typical → *I will install the operating system later* → Windows Server 2025 → name `DC01` → 60 GB → Customize Hardware: 4 GB RAM, 2 CPUs, ISO attached, network **NAT**.

**Install:**

- Press a key at *Press any key to boot from CD or DVD*. If missed, the EFI Boot Manager appears: choose *EFI VMware Virtual SATA CDROM Drive* and press a key quickly.
- Choose **Windows Server 2025 Standard Evaluation (Desktop Experience)**. Without "Desktop Experience" you get Server Core (no GUI).
- Set the Administrator password. In VMware, `Ctrl+Alt+Insert` sends Ctrl+Alt+Del to the VM.
- Install VMware Tools (VM → Install VMware Tools).
- Snapshot: `Clean install`.

**Name, IP, time:**

```powershell
Rename-Computer -NewName "DC01" -Restart
Set-TimeZone -Id "Azerbaijan Standard Time"
```

Static IP via `ncpa.cpl` → Ethernet0 → IPv4:

| Field | Value |
|---|---|
| IP address | `192.168.25.10` (outside VMware's DHCP range) |
| Subnet mask | `255.255.255.0` |
| Default gateway | `192.168.25.2` (VMware NAT) |
| Preferred DNS | `192.168.25.10` (the DC will be its own DNS server) |

Verify with `hostname` and `Get-NetIPConfiguration`. Snapshot: `Before DC promotion`.

## 2. Promote DC01 to Domain Controller

Server Manager → Manage → Add Roles and Features → **Active Directory Domain Services** → Install → *Promote this server to a domain controller*:

- **Add a new forest**, root domain `lab.local`.
- DNS server and Global Catalog ticked; set the **DSRM** password (Directory Services Restore Mode, used to repair or restore the AD database).
- The *DNS delegation cannot be created* warning is expected: there is no parent `.local` zone. Leave *Create DNS delegation* unticked.
- NetBIOS name `LAB`. *View script* shows the equivalent PowerShell.

Equivalent PowerShell:

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "lab.local" -DomainNetbiosName "LAB" -InstallDns
```

After the reboot, log on as `LAB\Administrator` and verify:

```powershell
whoami                                                        # lab\administrator
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DomainMode # lab.local, LAB, Windows2025Domain
Get-ADDomainController | Select-Object Name, IPv4Address, IsGlobalCatalog
nslookup lab.local                                            # 192.168.25.10
```

Snapshot: `DC promoted`.

## 3. CLIENT01: Windows 11 Enterprise

**VM:** Windows 11 x64, name `CLIENT01`, 64 GB, 4 GB RAM, 2 CPUs, NAT. VMware asks for an encryption password because the virtual TPM (required by Windows 11) needs encrypted VM files; keep that password safe.

**Setup:** during OOBE choose *Set up for work or school* → *Sign-in options* → *Domain join instead* to create a local account (`localadmin`). Install VMware Tools. Snapshot: `Clean install`.

**Point DNS to the DC:** `ncpa.cpl` → IPv4 → IP automatic, Preferred DNS `192.168.25.10`.

**Check the clock:** VMs restored from suspend can drift. Kerberos fails if the client and DC differ by more than 5 minutes.

```powershell
Set-TimeZone -Id "Azerbaijan Standard Time"
Start-Service w32time
w32tm /config /manualpeerlist:"192.168.25.10" /syncfromflags:manual /update
w32tm /resync
Get-Date
```

**Test before joining:**

```powershell
nslookup lab.local
ping dc01.lab.local
```

## 4. Join the domain

`sysdm.cpl` → Change... → computer name `CLIENT01`, Member of Domain `lab.local` → credentials `LAB\Administrator` → *Welcome to the lab.local domain* → restart.

Equivalent PowerShell:

```powershell
Add-Computer -DomainName lab.local -NewName CLIENT01 -Credential LAB\Administrator -Restart
```

Log on with **Other user** → `LAB\Administrator` (backslash, not slash) or `administrator@lab.local`. Snapshot: `Domain joined`.

## Accounts in the lab

| Account | Stored on | Admin on |
|---|---|---|
| `.\localadmin` | CLIENT01 only | CLIENT01 only |
| `LAB\Administrator` | DC01 (AD) | Every domain computer, the DC, AD itself |

Use the least powerful account that does the job; in real companies Domain Admin credentials are not typed into users' PCs.
