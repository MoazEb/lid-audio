# lid-audio

Keep music playing when you close the lid — but only while something is
actually playing.

On most Linux laptops, closing the lid suspends the machine through
`systemd-logind`. `lid-audio` keeps it awake **only** while audio is audible on
the default output, locks the session, and turns the panel off through Mutter's
DPMS control. Close the lid with nothing playing and the laptop suspends as
usual.

Tested on Ubuntu 24.04 with GNOME/Wayland, PipeWire and systemd 255.

## How it works

`lid-audio` runs as a systemd **user** service:

- It tracks the lid switch and holds a low-level `handle-lid-switch` inhibitor
  only while a playback stream exists (or an external monitor is attached).
  Without streams the lock is released, so logind stays in charge.
- When the lid closes it measures the actual output of the default sink
  (`<sink>.monitor`) for 0.4 s with `ffmpeg` and computes the RMS level in
  dBFS:
  - above `MIN_DBFS` → lock the session, set Mutter `PowerSaveMode` to 3
    (panel off), keep playing;
  - at or below it → release the inhibitor and `systemctl suspend`.
- While the lid is shut it re-probes every 5 s and suspends after 30 s of
  continuous silence, so a finished playlist does not keep the laptop awake.
- A connected external monitor keeps the machine awake (docked behaviour).

## Requirements

- systemd with `systemd-logind`
- PipeWire (`pipewire`, `pipewire-pulse`, `wireplumber`, `pipewire-bin` for
  `pw-cli` and `wpctl`)
- GNOME (Mutter `DisplayConfig` for DPMS, `org.gnome.ScreenSaver` for locking)
- `ffmpeg`, `python3`, `gdbus` (GLib)

## Install

```bash
git clone https://github.com/MoazEb/lid-audio.git
cd lid-audio
./install.sh
```

The installer copies `lid-audio` to `~/.local/bin/`, installs the user unit to
`~/.config/systemd/user/`, enables it and restarts the service.

Verify:

```bash
systemctl --user status lid-audio.service
systemd-inhibit --list | grep lid-audio
```

## Configuration

Defaults live at the top of `lid-audio` and can be overridden with
`Environment=` in the unit:

| Variable | Default | Meaning |
| --- | --- | --- |
| `MIN_DBFS` | `-55` | Levels quieter than this count as silence |
| `SILENCE_GRACE` | `30` | Seconds of silence (lid shut) before suspending |
| `PROBE_EVERY` | `5` | Seconds between level probes while shut |
| `PROBE_SECS` | `0.4` | Duration of one level probe |
| `POLL` | `1` | Lid/stream poll interval |

Example:

```ini
[Service]
Environment=MIN_DBFS=-50 SILENCE_GRACE=60
```

## Uninstall

```bash
./uninstall.sh
```

## Caveats

- Only the **default sink** is probed. Audio routed to another sink is not
  measured.
- Playback that is quieter than `MIN_DBFS` is treated as silence.
- "Docked" is approximated by any connected DRM connector other than the
  internal panel.
- The DPMS and lock calls are GNOME-specific. On another desktop, adapt
  `set_dpms()` and `lock_session()`.
- If no playback stream exists at lid close, logind handles the event directly
  and suspends immediately.

## License

MIT — see [LICENSE](LICENSE).
