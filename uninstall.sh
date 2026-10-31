#!/usr/bin/env bash
set -euo pipefail

unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

systemctl --user disable --now lid-audio.service 2>/dev/null || true
rm -f "$HOME/.local/bin/lid-audio" "$unit_dir/lid-audio.service"
systemctl --user daemon-reload 2>/dev/null || true

echo "Removed lid-audio."
