# 2026-07-18 — Operator rulings

2026-07-18 (external crosscheck review, `../local/chatgpt-planning-crosscheck-feedback.md`,
adjudicated with the Operator): **Operator rulings** — (g) zfs backend is
snapshot-native (in-place `current/`, versions = quince's own snapshots, no hardlinks
under ZFS; consistency guarantee restated per-backend: on zfs it lives in the
snapshots, the head is a working buffer); (h) Wi-Fi is the PRIMARY use case —
first-class transport from qn.4, hardening rung (qn.7) moved BEFORE v0.1, experimental
flag removed (rejects the crosscheck's Wi-Fi demotion). **Crosscheck adopted** —
journaled commit + first-class startup reconciliation with on-disk
`quince-version.json` markers; two-level verification (structural at commit, content
canary at next unlock); vault RPC hardening (framed `initialize`, `materialize` with
opaque handles — no paths cross the boundary, scratch-jailed vault); web security
baseline pulled into qn.1 + audit trail + tmpfs scratch honesty; hardened deployment
profile (muxd split) as a qn.6 compose example; domain APIs envelope-frozen only,
fields after research spikes; D12 config staged (core in qn.1, live-reload/comments in
qn.6); headless CLI added to qn.4; destructive hardlink-safety matrix replaces the
single-file inode check. **Crosscheck rejected** — per-version/clone ZFS datasets
(don't propagate into container bind mounts; fragile hook chains), CLI-first roadmap
restructure (parallel tracks already decouple UI; CLI lands inside qn.4), Wi-Fi
demotion (see h).
