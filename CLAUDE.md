# CLAUDE.md - AI Assistant Guidelines

This file gives Claude Code and other AI agents the current operating context
for this repository.

## Current Release State

- Product: pTTY, an opinionated tmux preset for persistent AI coding terminals.
- Current milestone: v0.2 pre-release hardening.
- Release gate: follow `.plan/REVIEW.md` and `.plan/epic-v0.2-ptty/ORCHESTRATOR.md`.
- Do not tag a release while `.plan/REVIEW.md` says `NO-GO`.

## Product Contract

pTTY protects long-running terminal processes from client-side disruption:

- SSH disconnects
- WiFi/VPN/network changes
- laptop sleep
- client reboot
- accidental `exit` in the wrong tmux session

pTTY does not preserve in-memory AI context across a server reboot. The systemd
user service can recreate empty sessions after boot, but the old tmux server,
scrollback, running processes, and AI conversation state are gone.

## F-Key Model

- `Ctrl+F1`-`Ctrl+F10`: switch to `console-1` through `console-10`.
- `Ctrl+F11`: open the Manager Menu from `src/mission-control.sh`.
- `Ctrl+F12`: open the Help Reference from `src/help-reference.sh`.
- Never describe `Ctrl+F1`-`Ctrl+F12` as console switching. F11 and F12 are tools.
- v0.2 uses 10 always-created console sessions. Do not reintroduce the old
  "5 active + 5 on-demand" or "suspended console" model.

## Source of Truth

- Product/spec: `docs/SPEC.md`
- Architecture: `docs/ARCHITECTURE.md`
- Naming: `docs/NAMING.md`
- Icons: `docs/ICONS-NETWORK-SET.md`
- Release review: `.plan/REVIEW.md`
- Epic execution: `.plan/epic-v0.2-ptty/ORCHESTRATOR.md`

If these files disagree, update the release review and epic task notes before
changing behavior.

## Installer Facts

- Public install URL:
  `https://raw.githubusercontent.com/zentala/pTTY/main/install.sh`
- Default install directory remains `~/.tmux-persistent-console` for this
  release. Do not rename it to `~/.ptty` unless the rename task is explicitly in
  scope.
- `src/tmux.conf` references installed files under `~/.tmux-persistent-console`.
  Any new referenced file must be included in the remote download list in
  `install.sh`.

## Release Process

**The only supported way to cut a release is `scripts/release.sh <version>`.**
Never hand-edit `PTTY_VERSION`, `MANIFEST_SHA256`, `SHA256SUMS`, the `VERSION`
constants in `src/mission-control.sh` / `src/help-reference.sh`, or git tags —
hand-editing is how the v0.2.0 incident happened (tag cut without
`SHA256SUMS`; every fresh install died on a 404).

How releasing works:

1. Write the changes under a `## [Unreleased]` heading in `CHANGELOG.md`
   (merged to main like any other change).
2. On a clean, pushed main: `scripts/release.sh X.Y.Z --dry-run` to see the
   plan, then without `--dry-run` to release. The script bumps every embedded
   version, regenerates the manifest and its pinned hash, stamps the
   changelog, commits, tags `vX.Y.Z`, pushes, and polls
   raw.githubusercontent.com until the tag serves `SHA256SUMS`.
3. CI enforces the contract: `tag-validation.yml` rejects tags whose tree
   breaks the installer, and `pr-validation.yml` fails main whenever
   `install.sh` points at a ref that does not serve the manifest.

Mental model: the public one-liner serves `install.sh` from **main**, but the
script downloads payload files from tag `v$PTTY_VERSION` — so the version
constant on main is a promise that the tag exists and contains `SHA256SUMS`.
`release.sh` keeps that promise atomically.

## Development Rules

- Read existing scripts before editing; keep shell changes small and portable.
- Prefer tmux native formats in status bar code. Do not add periodic external
  scripts to the status bar.
- Keep user-facing docs honest about server reboot behavior.
- Keep repo docs in English.
- Use Conventional Commits if committing.
- Do not revert unrelated local changes in `.plan/BACKLOG.md` or `.plan/reports/`.

## Local Validation

Run the relevant subset before marking work complete:

```bash
bash -n install.sh
for script in src/*.sh tools/*.sh tests/scripts/*.sh; do bash -n "$script"; done
bash tools/check-tmux-references.sh
bash tools/check-markdown-links.sh README.md CLAUDE.md
```

On Linux with tmux available, also run:

```bash
tmux -f src/tmux.conf start-server \; source-file src/tmux.conf \; list-keys
tests/docker/test-local.sh test
```
