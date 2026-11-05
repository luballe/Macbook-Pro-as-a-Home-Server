# 2. Thermal and fan

## Symptoms

With full CPU load and the stock SMC fan control:

- `TC0D` (CPU die) reaches **98 °C** in about 10 s.
- The fan ramps up slowly (3,800 → 5,700 rpm over a minute).
- The CPU throttles from 2.66 GHz down to 1.59 GHz.

## Fix: `mbpfan`

```bash
sudo apt install mbpfan
sudo cp config/mbpfan.conf /etc/mbpfan.conf
sudo systemctl enable --now mbpfan
```

[config/mbpfan.conf](../config/mbpfan.conf):

| Setting | Value | Why |
|---|---|---|
| `min_fan1_speed` | 2000 | SMC minimum (`fan1_min`) |
| `max_fan1_speed` | 6200 | SMC maximum (`fan1_max`) |
| `low_temp` | 60 | Typical idle is 55-62 °C |
| `high_temp` | 66 | Start ramping early |
| `max_temp` | 82 | Full speed well before 98 °C |
| `polling_interval` | 1 | React within a second |

Result: dual-core throughput went from 1,116 to 1,677 bogo ops/s
([01-hardware-and-install.md](01-hardware-and-install.md)).

## Notes

- `mbpfan` must be stopped while `smc-key` writes to the SMC (both talk to it).
  `smc-settings.service` runs before `mbpfan`, and the scripts stop and start it.
- Some SMC sensors are not real readings: `TN1G` is stuck at 90, and `TB0T`-`TB2T`
  read -127 without a battery.
- After 10+ years, **replacing the CPU thermal paste** is the next improvement.

---

Terms and acronyms: [glossary](glossary.md).
