# Glossary

Acronyms and terms used in this repository, in alphabetical order.

| Term | Meaning |
|---|---|
| **ACPI** | Advanced Configuration and Power Interface. The firmware standard the OS uses to manage power: sleep states, batteries, buttons and wake sources |
| **ADP1** | The ACPI name of the MacBook's power adapter (charger). `/sys/class/power_supply/ADP1/online` is 1 when it is connected. Enabled in `/proc/acpi/wakeup`, plugging it in wakes the machine from suspend |
| **applesmc** | Linux driver that exposes the Mac's SMC (fans, temperatures, keyboard light). It is unloaded while `smc-key` writes, so they don't compete for the SMC |
| **AUPO** | SMC key "Automatic Power On". With `AUPO=1` the Mac powers on when power returns after a loss; on this model it also turns every poweroff into a reboot |
| **b43** | Linux driver for the Broadcom BCM4322 Wi-Fi chip. Blacklisted here because the server uses Ethernet |
| **BAR0** | Base Address Register 0: the first block of memory-mapped registers of a PCI device. `backlight` writes the GPU's backlight registers there |
| **BCLM** | SMC key "Battery Charge Level Max": the charge limit, in percent. `BCLM=80` stops charging at 80 % |
| **bogo ops/s** | "Bogus operations per second": the throughput unit reported by `stress-ng`. Only meaningful to compare runs on the same machine |
| **C3** | A deep CPU idle state. On the Core 2 Duo P8800 the TSC stops in C3 |
| **cloud-init** | Tool that configures Ubuntu Server on first boot. Disabled for networking here so it does not overwrite the static IP |
| **D-Bus** | Message bus between Linux system services. UPower is "D-Bus activated": it only starts when another program asks it something |
| **DMI** | Desktop Management Interface: firmware tables with the machine's identity. `/sys/class/dmi/id/product_name` returns `MacBookPro7,1` |
| **EFI / UEFI** | The firmware interface Intel Macs boot with (instead of a legacy BIOS) |
| **GRUB** | The boot loader. Kernel options such as `tsc=unstable` are set in `/etc/default/grub` |
| **initrd** | Initial RAM disk: a small filesystem loaded with the kernel during boot |
| **LTS** | Long Term Support: an Ubuntu release with 5 years of updates (24.04 is LTS) |
| **logind** | systemd service for sessions and power keys. Configured here so closing the lid does nothing |
| **MacBookPro7,1** | Apple's model identifier for the 13" MacBook Pro from mid-2010 (A1278) |
| **mbpfan** | Daemon that controls MacBook fans on Linux through `applesmc`, with a configurable temperature curve |
| **MCP89** | NVIDIA's chip name for the GeForce 320M integrated GPU (chip ID `0x0af`) |
| **MMIO** | Memory-mapped I/O: device registers accessed as memory addresses (see BAR0) |
| **netplan** | Ubuntu's network configuration tool (`/etc/netplan/*.yaml`) |
| **nouveau** | Open-source Linux driver for NVIDIA GPUs. Blacklisted at boot here; loaded only after resume to bring the screen back |
| **nv_backlight** | The backlight device nouveau creates in `/sys/class/backlight` |
| **ProxyJump** | SSH option to reach a host through another one (`ssh -J`) |
| **PWM** | Pulse-Width Modulation: how the backlight brightness is set, as the share of time the LEDs are on |
| **RTC** | Real-Time Clock: the battery-backed hardware clock. It can raise an alarm to wake the machine; `rtcwake` programs it |
| **S3** | ACPI "suspend to RAM": the machine sleeps with memory powered (~0.5 W here) and resumes in seconds |
| **S5** | ACPI "soft off": powered off, but the SMC and power circuitry still run |
| **SMC** | System Management Controller: the Mac's chip that handles power, battery charging, fans and sensors |
| **SSH** | Secure Shell: remote login to the server |
| **systemd** | Ubuntu's service manager. **Unit**: a service or timer definition. **Timer**: runs a unit on a schedule. **Sleep hook**: a script in `/usr/lib/systemd/system-sleep/` run before and after suspend |
| **TC0D** | SMC temperature sensor of the CPU die |
| **thd / triggerhappy** | Small daemon that runs commands when keys are pressed; used for the brightness keys |
| **Threshold** | Battery percentage at which the battery guard acts: `SUSPEND_AT` (every minute) and `BOOT_AT` (at boot) |
| **TSC** | Time Stamp Counter: a CPU cycle counter Linux uses as a fast clock. Unreliable on this CPU, hence `tsc=unstable` |
| **UPower** | Linux service that monitors batteries and can power off at a critical level. Used here as a backstop |
| **UPS** | Uninterruptible Power Supply: a battery that keeps equipment running during a power outage |
| **WireGuard** | Simple, fast VPN. Used to reach the server from outside home |
| **x86-64-v2** | A baseline of x86 CPU features (SSE4.2, POPCNT...). The P8800 is below it, so binaries built for v2 crash |
