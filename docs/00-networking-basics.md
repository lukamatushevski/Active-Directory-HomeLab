# Module 00: Networking basics

Active Directory sits on top of a few networking ideas. Without them, nothing else in AD makes sense.

## Concepts

| Concept | Analogy | What it is |
|---|---|---|
| **Network** | Streets connecting houses | Devices connected so they can exchange data |
| **IP address** | A house address | A device's unique address on the network, e.g. `192.168.25.10` |
| **IPv4 / IPv6** | Old and new address formats | `142.250.x.x` vs `2a00:1450:...`. Both are IP addresses |
| **MAC address** | The house's serial number | Physical address of the network card, e.g. `00-0C-29-0D-44-FD`. Only used on the local network |
| **DNS** | Phone contacts | Translates a name (`google.com`, `dc01.lab.local`) into an IP address |
| **Client / server** | Diner / kitchen | Roles of devices or programs: the client requests, the server provides. Not the same as user/admin, which are roles of *people* |
| **Private IP ranges** | Internal office numbers | `192.168.x.x`, `10.x.x.x` are used inside home/office networks, not on the public internet |
| **Virtual machine** | A sealed room inside your house | A computer inside your computer. Isolated, can be snapshotted and restored |

> AD cannot work without DNS: computers find the Domain Controller through DNS. See [Module 04](04-dns-and-ad.md).

## Commands

```cmd
hostname                 :: name of this computer
whoami                   :: current account, COMPUTER\user or DOMAIN\user
ipconfig                 :: IPv4 address, subnet mask, gateway
ipconfig /all            :: adds DNS servers, MAC (Physical Address), DHCP info
nslookup google.com      :: ask DNS for the IP of a name
ping google.com          :: check that a host answers
```

## Why a VM lab

- Isolated from the host: breaking the lab doesn't break the laptop.
- **Snapshots** allow rolling back in a minute.
- Several machines (DC + client) on one laptop simulate a small company network.
- Free: Microsoft provides 180-day (Server) and 90-day (Windows 11 Enterprise) evaluation ISOs.

## Lessons

- Always know which machine you're on: run `hostname` before anything else. With several VMs and a host open, it's easy to run a command in the wrong place.
