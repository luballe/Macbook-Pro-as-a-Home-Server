# Test plan: power and display

Run after installing or changing anything in the power path. After each case,
`sudo server-status` should show the IP, `BCLM 80 AUPO 1`, wake on charger
`enabled`, all services `active` and no failed units.

Results of 2026-11-05 on MacBookPro7,1, Ubuntu 24.04.5, kernel 6.8: **all passed.**

| # | Case | How | Expected | Result |
|---|---|---|---|---|
| 1 | Reboot with charger | `sudo systemctl reboot` | Back in < 1 min, GPU without driver, backlight at the saved level | SSH back in 43 s |
| 2 | Suspend with charger | `sudo rtcwake -m no -s 40 && sudo systemctl suspend` | Wakes with the alarm, `resume-display` loads nouveau, console visible | OK |
| 3 | Poweroff with charger | `sudo systemctl poweroff` | Reboots by itself (`AUPO=1`) | Back in 51 s |
| 4 | Real power off | `sudo real-poweroff` | Stays off; power button boots it with `AUPO 1` | OK |
| 5 | Suspend on battery, then plug in | Unplug, `sudo systemctl suspend`, plug in without touching anything | Wakes on the charger (ADP1 events), console visible | OK |
| 6 | Guard, every minute | `SUSPEND_AT=100` in `/etc/default/battery-guard`, unplug | Suspends in < 1 min; wake it with a key → suspends again in < 1 min; plug in → wakes and stays on | Suspended; re-suspended 58 s after the key press; woke on the charger |
| 7 | Guard at boot | `BOOT_AT=100`, unplug, `sudo systemctl reboot` | Suspends during boot before Docker; plug in → wakes and finishes booting | OK (`systemd-networkd-wait-online` left `failed`, harmless) |

**Restore the real thresholds after cases 6 and 7.**

## Earlier experiments (same day)

| Experiment | Result |
|---|---|
| `poweroff` with `AUPO=1`, charger connected (×2) and on battery (×1) | Rebooted within 30 s each time |
| `poweroff` with `AUPO=0` | Stayed off |
| RTC alarm + poweroff, `AUPO=0`, charger connected | Woke at the alarm time |
| RTC alarm + poweroff, on battery | **Never woke**, not even after plugging in later |
| Clean shutdown at 1 % battery (UPower), then plug in | Stayed off |
| Suspend on battery for 26 min | 4,339 → 4,321 mAh, about 42 mA |

## Tips

- During suspend the network is down, so a ping loop from another machine shows
  when it sleeps and wakes.
- Touching the trackpad or keyboard also wakes it: keep hands off when testing the
  charger wake (an accidental trackpad touch invalidated one run).
- `/sys/class/wakeup/*/event_count` tells which device woke the machine.
