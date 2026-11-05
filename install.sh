#!/bin/bash
# Installs the scripts, systemd units and configuration of this repository.
# Usage: sudo ./install.sh [--dry-run]
#
# It does NOT change GRUB, UPower.conf or WireGuard: those are documented in docs/
# and config/ so you can review them first. It refuses to run on a model other than
# MacBookPro7,1 unless FORCE=1, because the GPU and SMC details are model specific.
set -euo pipefail
cd "$(dirname "$0")"
DRY=0; [ "${1:-}" = --dry-run ] && DRY=1
run() { echo "+ $*"; [ $DRY = 1 ] || "$@"; }

[ "$(id -u)" = 0 ] || [ $DRY = 1 ] || { echo "run as root (sudo)"; exit 1; }
model=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo unknown)
if [ "$model" != MacBookPro7,1 ] && [ "${FORCE:-0}" != 1 ]; then
  echo "This machine is '$model', not MacBookPro7,1. Read docs/ first; FORCE=1 to continue."; exit 1
fi
missing=""
for p in mbpfan triggerhappy upower python3; do command -v "$p" >/dev/null || dpkg -s "$p" >/dev/null 2>&1 || missing="$missing $p"; done
[ -z "$missing" ] || { echo "Install first: sudo apt install$missing"; exit 1; }

for s in smc-key smc-settings backlight battery-guard real-poweroff server-status bench; do
  run install -m 755 "scripts/$s" "/usr/local/sbin/$s"
done
run install -m 755 scripts/resume-display /usr/lib/systemd/system-sleep/resume-display

for c in smc-settings battery-guard; do
  [ -e "/etc/default/$c" ] && echo "keeping existing /etc/default/$c" || run install -m 644 "config/$c" "/etc/default/$c"
done
[ -e /etc/mbpfan.conf ] && run cp -n /etc/mbpfan.conf /etc/mbpfan.conf.orig
run install -m 644 config/mbpfan.conf /etc/mbpfan.conf
run install -D -m 644 config/triggerhappy/backlight.conf /etc/triggerhappy/triggers.d/backlight.conf
run install -D -m 644 config/logind-server.conf /etc/systemd/logind.conf.d/server.conf

for u in smc-settings.service battery-guard-boot.service battery-guard.service battery-guard.timer backlight-restore.service; do
  run install -m 644 "systemd/$u" "/etc/systemd/system/$u"
done
run install -D -m 644 systemd/triggerhappy.service.d/root.conf /etc/systemd/system/triggerhappy.service.d/root.conf

run systemctl daemon-reload
run systemctl enable smc-settings.service battery-guard-boot.service battery-guard.timer backlight-restore.service mbpfan.service
run systemctl add-wants multi-user.target upower.service
run systemctl restart triggerhappy.service
run systemctl stop mbpfan.service
run systemctl start smc-settings.service battery-guard-boot.service battery-guard.timer upower.service
run systemctl start mbpfan.service

cat <<'EOF'

Done. Next steps (see docs/):
  - GRUB: config/grub.snippet (tsc=unstable, blacklist nouveau and b43), then update-grub.
  - UPower backstop: config/UPower.conf.snippet.
  - Check everything: sudo server-status
  - Real power off (AUPO=1 turns poweroff into reboot): sudo real-poweroff
EOF
