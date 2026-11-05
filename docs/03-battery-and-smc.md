# 3. Battery and SMC

## Talking to the SMC

[`scripts/smc-key`](../scripts/smc-key) reads and writes 1-byte SMC keys through
`/dev/port`, using the protocol from Linux `drivers/hwmon/applesmc.c`. The
`applesmc` module must be unloaded while it writes, and `mbpfan` stopped.

```bash
sudo systemctl stop mbpfan; sudo modprobe -r applesmc
sudo smc-key read BCLM
sudo smc-key write BCLM 80
sudo modprobe applesmc; sudo systemctl start mbpfan
```

`smc-settings.service` applies [`/etc/default/smc-settings`](../config/smc-settings)
at every boot, before `mbpfan`:

| Key | Value | Effect |
|---|---|---|
| `BCLM` | `80` | **Charge limit.** Works on this model: tested with 42, it stopped at 43 % and reported `Full` |
| `AUPO` | `1` | Power on automatically when power returns. Read the side effect below |

`CH0B` and `CH0I` (used on other Macs) do not exist on this model.

## Calibration

The battery maker (iFixit) recommends: charge to 100 %, keep it there 2 hours, then
discharge completely. Do it with `BCLM=100`, then set `BCLM=80`.

Measured during the calibration, server idle (Docker, a few agents, VPN tunnels):

| Metric | Value |
|---|---|
| Runtime from 100 % | **4 h 01 min** |
| Average draw | 15.7 W (1.45 A) |
| Charge delivered | 6,127 of 6,265 mAh |
| Voltage | 12.24 V → 9.63 V |
| Slope | very even, ~12 percentage points every 30 min |

With `BCLM=80` the estimate is about 3 h 15 min. Raw data, one sample per minute:
[data/discharge-2026-11-05.csv](../data/discharge-2026-11-05.csv).

## The AUPO side effect

**With `AUPO=1`, every poweroff becomes a reboot.** About 20 s after any clean
`poweroff`, the SMC powers the machine back on, **with or without the charger**
(tested 3 times). With `AUPO=0` it stays off.

For a headless server that is mostly good: it recovers by itself from hangs and
unexpected shutdowns. To really power it off, use
[`scripts/real-poweroff`](../scripts/real-poweroff): it sets `AUPO=0` in the SMC
only, checks it, and powers off. `smc-settings.service` restores `AUPO=1` on the
next boot.

```bash
sudo real-poweroff
```

## What AUPO does NOT cover

After the battery runs down and the system shuts down cleanly (UPower at 1 %),
reconnecting the charger does **not** power the machine on, even with `AUPO=1`.
That case is handled by the battery guard: [04-power-management.md](04-power-management.md).
