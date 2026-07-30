# 2026-07-22 — (cl) Post-freeze EPIC captured: storage as a first-class entity (multi-storage)

(cl) **Post-freeze EPIC captured: storage as a first-class entity (multi-storage).**
Operator direction, recorded so it lives in the docs not just their head; full write-up in the
roadmap ("Post-freeze EPIC — Storage as a first-class entity"). **The core insight is correct and
names a real modeling error:** a backend (`zfs`/`reflink`/…) is a property of a **storage**, not a
backup — and today's per-version `Version.backend` (contracts §2) is the *symptom*. Target: storage
as a first-class UI entity (created in onboarding Plex-style, on the dashboard with space/count
stats), one immutable backend per storage selected at creation, a device backing up to multiple
storages, **incremental scoped to (device, storage)** (so `latest/`/`working/` becomes per-storage
and the first backup to a NEW storage is always full), and offline storages shown-not-errored.
**Architect endorsed the direction and challenged six points** (all in the roadmap): storage
identity must be a UUID written *into* the storage (not path-based, for the removable/offline case);
the "pre-backup probe" reframed as a reachability/sanity health-check while backend *selection*
stays at creation; **offsite/B2 is probably a REPLICATION of a storage, not a storage** (open fork);
the iMazing case splits into **external-readonly** (browse foreign backups in place — a natural fit
for the sibling libraries, which read *any* backup) vs **import/migration** (copy in); offline
storage does NOT queue unattended backups (fights D13); and a storage `mode` (`managed` |
`external-readonly`). **Near-term:** qn.5b's mechanics are storage-agnostic (only the path prefix
changes), so it is safe to build now provided it doesn't hard-bake single-storage assumptions —
paths storage-scopeable, `last_backup` derivation tolerant of going per-storage. **Not a rung — an
epic, scoped into rungs post-freeze under the revamped process** (exactly the large, contract-
touching, multi-surface work the revamp should improve).
