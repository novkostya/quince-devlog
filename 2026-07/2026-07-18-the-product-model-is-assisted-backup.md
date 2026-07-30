# 2026-07-18 — the product model is ASSISTED backup

2026-07-18 (crosscheck v2 adjudication + Operator's passcode correction): **the
product model is ASSISTED backup** — Operator established that modern iOS demands
on-device passcode entry for every backup, so unattended backups are impossible;
auto-retry ladder deleted (failed → `user action required` + one-tap manual retry
with `retry_of`; run/attempt grouping thereby unnecessary); Shortcut becomes a dumb
opportunity signal with ALL policy server-side (`/api/automation/backup-opportunity`,
staleness + cooldown config); v0.1 gate rewritten to a week of real UI-driven Wi-Fi
backups, qn.12 gate = the assisted acceptance list. Crosscheck v2 refinements
adopted: zfs `latest/` built from the snapshot's `.zfs` path (snapshot = canonical
version, latest = materialized view; FICLONE-from-snapshot probed with lock-guarded
fallback); "self-heals" softened to candidate-plus-verification with
`repair-working-copy` escape hatch; liveness = activity sampler with staged states
(`active → silent_but_connected → suspected_stall`) + `waiting_for_passcode` pause;
**`latest/` is a real directory on all backends, never a symlink** (namespace commit
= journaled rotation, offsite filter excludes `versions/` too); roll-forward
principle — post-verify artifacts are never destroyed by recovery, reconciliation
completes commits instead of unwinding them.
