# 2026-07-18 — the offsite model is whole-tree file-level sync

2026-07-18 (Operator clarification, second pass): the offsite model is **whole-tree
file-level sync** — one rclone job over the entire storage parent (e.g.
`/rpool/userdata`), walking live mounts; per-dataset `.zfs` paths don't fit it. Design
restated as D5a: each zfs device dataset holds `current/` (in-place working copy,
excluded by one static rclone filter) + `latest/` (verified mirror rebuilt at commit —
reflink clone preferred, probed fallbacks hardlink/copy — atomic swap); flow =
`zfs snapshot -r && rclone sync /rpool/userdata b2:…`, remote history via B2
versioning/`--backup-dir`. **Operator ruling: one child dataset per device**
(independent snapshot streams; snapshot list = version list), so the constrained hook
gains `zfs create` scoped to children of the parent; dataset destroy stays
human-only. PVE bind-mount propagation gotcha (new child = empty stub in a running
LXC) handled by probe + printed `pct set` instructions; Docker via `:rshared`;
single-dataset fallback mode documented.
