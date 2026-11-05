# 1. Hardware and installation

## The machine

| Part | Detail |
|---|---|
| Model | `MacBookPro7,1`, MacBook Pro 13" mid-2010, `A1278` |
| CPU | Core 2 Duo P8800, 2 cores, 2.66 GHz |
| RAM | 16 GB |
| GPU | NVIDIA GeForce 320M (MCP89), integrated |
| Disk | SATA SSD (any 2.5" SSD works) |
| Network | Ethernet `tg3`, 1 Gbps. The BCM4322 Wi-Fi is not used |
| Battery | `A1322` replacement (the original was swollen) |
| OS | Ubuntu Server 24.04.5 LTS, kernel 6.8, no desktop |

### CPU limits

The P8800 has no SSE4.2, POPCNT, AES-NI or AVX (it is below `x86-64-v2`). Ubuntu
24.04, systemd, Docker, Node 18/22, Python and most server software run fine.
Some recent binaries do not: anything compiled for `x86-64-v2` or newer dies with
`Illegal instruction`. Check before relying on a prebuilt binary.

### The battery matters for performance

**Without a battery, the CPU is locked at 1.59 GHz** (about 60 % of its 2.66 GHz).
With a healthy battery it reaches full speed. Measured with `scripts/bench`
(`stress-ng --cpu 2`, 60 s):

| Setup | bogo ops/s |
|---|---|
| No battery | 978 |
| New battery | 1,116 |
| New battery + `mbpfan` | 1,677 |

The jump with `mbpfan` comes from avoiding thermal throttling: the stock SMC fan
curve reacts late, the CPU reaches 98 °C and drops back to 1.59 GHz.
See [02-thermal-and-fan.md](02-thermal-and-fan.md).

## Installation notes

### Slow boot: 5 to 7 minutes (TSC)

The TSC (CPU time-stamp counter) stops when this CPU enters deep idle (C3). During
boot the kernel lost 3 to 6 minutes without noticing, because it measured time with
that same clock.

- **Misleading:** `systemd-analyze` showed ~30 s, and NTP fixed the clock later, so
  the boot looked fast in the logs. Time boots on this machine with an external clock.
- **Clue:** `clocksource: Long readout interval` in the kernel log, and on 6.8
  `tsc: Marking TSC unstable due to TSC halts in idle`.
- **Fix:** add `tsc=unstable` to the kernel command line. Boot went to ~50 s.

### `nouveau` and `b43`

Headless and on Ethernet, neither is needed, and both log errors at boot:
`modprobe.blacklist=nouveau,b43`. The console uses the firmware framebuffer.
Consequence: no `/sys/class/backlight`; see [05-display-and-backlight.md](05-display-and-backlight.md).

GRUB settings used ([config/grub.snippet](../config/grub.snippet)):

```text
GRUB_DEFAULT=saved
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
GRUB_RECORDFAIL_TIMEOUT=0
GRUB_CMDLINE_LINUX_DEFAULT="tsc=unstable modprobe.blacklist=nouveau,b43"
```

### GRUB asked for commands by hand

`EFI/ubuntu/grub.cfg` on the EFI partition pointed to a disk UUID that no longer
existed, and `grub-install /dev/sda` installed the BIOS variant without touching the
EFI partition. Check that file if you reinstall over an older system.

### Installing without a USB stick

The SD slot did not see the microSD and the USB stick was failing. The installer
was booted from the existing GRUB, with the ISO kernel and initrd copied to `/boot`
and `grub-reboot` so the entry is used only once:

```text
linux /boot/noble-installer/vmlinuz root=/dev/ram0 ramdisk_size=1500000 cloud-config-url=/dev/null ip=dhcp url=http://releases.ubuntu.com/24.04/ubuntu-24.04.5-live-server-amd64.iso tsc=unstable modprobe.blacklist=nouveau ---
initrd /boot/noble-installer/initrd
```

The ISO is loaded into RAM, so the installer can wipe the disk it booted from.
Keep a backup boot medium: a failure after confirming the wipe leaves the machine
unbootable.

### Server basics

- Boot to console: `systemctl set-default multi-user.target`.
- Closing the lid must not suspend: [config/logind-server.conf](../config/logind-server.conf).
- Static IP with netplan, and `99-disable-network-config.cfg` so cloud-init does not
  rewrite it. Some routers (AT&T BGW320) do not list hosts with a static IP and
  cannot reserve them; they avoided handing out that address anyway.

---

Terms and acronyms: [glossary](glossary.md).
