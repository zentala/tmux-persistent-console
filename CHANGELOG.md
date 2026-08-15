# Changelog

All notable changes to **pTTY** are documented in this file.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning is [SemVer](https://semver.org/).

## [0.2.0] — 2026-08-15

### Added
- 10 always-created console sessions (`console-1`..`console-10`), replacing
  the old 5-active + 5-on-demand model.
- `Ctrl+F11` Manager Menu (`src/mission-control.sh`) and `Ctrl+F12` Help
  Reference (`src/help-reference.sh`), both opened via `display-popup`.
- Safe-exit protection against accidental `exit` in the wrong tmux session.
- systemd user service + `loginctl` lingering so empty sessions are
  recreated after a server reboot.
- `install.sh --no-systemd` groundwork for installs without a service
  manager.
- `scripts/doctor.sh` diagnostic checks.
- CI hardening: blocking shellcheck, `tmux.conf` parse check, markdown
  link check, Docker-based assertions that all 10 sessions come up.

### Changed
- Renamed the project from tmux-persistent-console to pTTY.
- `src/uninstall.sh` (the shipped `uninstall-console` command) now also
  disables and removes the systemd service and drops `loginctl` lingering
  when no other user units need it — previously only the unused root-level
  `uninstall.sh` did this, so a real uninstall left sessions to be
  recreated on the next boot.

### Removed
- Stale root-level duplicates of `setup.sh`, `uninstall.sh`, and
  `tmux-console.service` that were never used by `install.sh`.
- Dead code: `src/status-bar-legacy.sh`, `src/status-format-v3.tmux`,
  `src/help-console.sh` (superseded by `status-format-v4.tmux` and
  `src/console-help.sh`).

## [0.1.3] — 2026-05-23

### Added
- `install.sh --version` and `--help` flags.
- `install.sh --dry-run` shows the install plan without changing anything.
- `install.sh` warns if a legacy `~/.vps/sessions` layout is still around.
- `scripts/doctor.sh` — one-shot diagnostic that checks service state,
  lingering, session presence, tmux.conf path resolution, and binary deps.
- `.github/workflows/shellcheck.yml` — lint all `*.sh` on every PR.
- `CHANGELOG.md` (this file).

### Fixed
- `install.sh` now installs the systemd user service, enables
  `loginctl --user` lingering, and verifies the service is actually
  active before reporting success. Previously the installer exited
  green even when `enable --now` had failed.
- `install.sh` skips the `cp -r src/* "$INSTALL_DIR"` step when run
  from inside `$INSTALL_DIR` itself, removing the duplicated /
  out-of-sync files at the repo root.
- `install.sh` "Remote installation" branch had a literal `YOUR_USERNAME`
  in the curl URLs — replaced with `zentala`. `curl -f` added so
  download failures abort instead of writing a 404 page to disk.
- `tmux.conf`, `src/*.sh`, and the systemd service no longer reference
  the stale `~/.vps/sessions/src/...` paths. Status bar and
  F11/F12/Ctrl+H/Ctrl+R bindings now work after a clean install.
- `src/setup.sh` creates `console-1..5` (matches README + tmux.conf
  F1-F5 / F6-F10 active/on-demand split). Was drifting toward 7.
- `uninstall.sh` now disables and removes the systemd service,
  drops `loginctl` lingering when no other user units need it, and
  uses the correct GitHub URL in its reinstall hint.

### Documentation
- README no longer warns "v0.1 install is broken" — the one-liner is
  the documented happy path again.
- Added a "Survives reboot, not state" section (explicit non-goal).
- Removed the v0.2 backport notes that the v0.1.3 fixes obsoleted.

## [0.1.0] — earlier

- Initial public release; manual install procedure documented.
