# 2026-07-18 — (a) vault seam made explicitly swappable

2026-07-18 (Operator review): (a) vault seam made explicitly swappable — a future
all-Go vault is a drop-in behind `vault.Vault` + the conformance suite; (b) host
auto-snapshot tooling rejected — quince relies only on snapshots it creates; (c) the
never-mutate-latest layout (`versions/` + `latest` + `work/`) adopted — dataset is
crash/replication-consistent at any instant (sanoid/syncoid-safe), rollback machinery
deleted; (d) persistent backup-content indexing rejected in favor of lazy
session-scoped reads; sole exception = fingerprint-validated derived caches
(thumbnails, qn.11). Side effect of (d): no secrets at rest in v1.
