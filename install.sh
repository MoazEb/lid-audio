#!/usr/bin/env bash
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
bin_dir="$HOME/.local/bin"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

install -Dm755 "$here/lid-audio" "$bin_dir/lid-audio"
install -Dm644 "$here/lid-audio.service" "$unit_dir/lid-audio.service"

systemctl --user daemon-reload
systemctl --user enable lid-audio.service
systemctl --user restart lid-audio.service

echo "Installed lid-audio."
echo "Status: systemctl --user status lid-audio.service"
