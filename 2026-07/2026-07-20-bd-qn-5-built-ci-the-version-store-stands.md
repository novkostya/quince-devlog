# 2026-07-20 — (bd) qn.5 BUILT (CI) — the version store stands

(bd) **qn.5 BUILT (CI) — the version store stands.** Cleared the pre-build
spec-review gate: spec + Rule check → **architect APPROVED with three amendments (A1 encrypted
`Verify` branch, A2 a `RepairWorkingCopy` story, A3 name `Prune`'s trigger) + five rulings**, all
folded in. Shipped: **`internal/storage`** — the `Backend` interface with two genuinely
different models (`zfs` snapshot-native via a validated exec/hook `zfsCLI`, dataset-destroy never
issued; `reflink`/`hardlink`/`copy` namespace-versioned), the **auto-selection probe** (FICLONE
independence / `link()`+inode on the real `/backups`; `copy` degraded mode surfaced), **journaled
commit** with on-disk `quince-version.json` markers + an explicit per-device commit journal,
**first-class startup reconciliation** (roll-forward matrix: kill at every phase → defined
repair; adopt on-disk versions with no row = `job_id` null protected; row with no artifact →
`missing`, never dropped; orphaned `work/` swept only after), structural **`Verify`** branching
on `Manifest.plist.IsEncrypted` (A1), **`RepairWorkingCopy`**, and retention **`Prune`**
(post-commit + explicit, no scheduler); **`internal/storage/clonetree`** (one FICLONE/hardlink/
copy cloner; hardlink copies `MutatesInPlace` classes); a **`versions` table + registry** in
`internal/store` (the real `VersionReader`); **`DELETE /api/versions/{id}` → 202|404|503** + a
`VersionAdmin` consumer interface + audit + `version.created`/`version.deleted` events; non-demo
wiring that **reconciles before serving**; a `--demo` delete path; and **`deploy/storage.md`**
(the constrained `quince-zfs-helper` forced-command + the anchored rclone filter block).
**`make gates` + `make image` + `make gates-ui-e2e` green.** `-cover` wired into `gates-go`
(the "when first needed" moment). **Coverage declared:** storage **78.3%**, clonetree **71.4%**,
store **80.1%**, httpapi **71.8%**; **known-untested** (accepted debt, all low-risk or
environment-gated): the reflink/FICLONE leaf (`clonetree` reflink path + the zfs reflink-mirror
branch) — proven for-real in lab gate 12, skipped-with-a-log in CI (tmpfs has no FICLONE); the
zfs reflink-from-snapshot copy-fallback branch; a few reconcile/adopt error-log branches; the
`zfsCLI` list/destroy not-found guards. **Build finding fixed:** `WriteMarker` now replaces
(remove-then-write) rather than truncates, so a hardlink-seeded `work/` can't rewrite a committed
version's marker. **Lab gate 12 (real zfs on the host + iMazing-opens + syncoid-mid-write + the
destructive hardlink-safety matrix) is the remaining physical/host step** — owned by this rung,
not deferred. Not yet committed (awaiting Operator). Frontier stays **qn.5** until gate 12; then
→ **qn.4a** (engine; qn.4 split into qn.4a/qn.4b per (be)).
