# 2026-07-24 — (cp) qn.5b BUILT (CI-proven) — atomic `latest` + the `working/` lifecycle redesign landed per the (co) ruling + both amendments

(cp) **qn.5b BUILT (CI-proven) — atomic `latest` + the `working/` lifecycle redesign
landed per the (co) ruling + both amendments.** `make gates` (go + vault + ui) + `make image` green
in `quince-dev`; coverage backup **85.2%** / storage **78.9%** / httpapi **73.2%** / demo 54.9% /
cmd 20.7%. **What landed:** (1) an `exchange(a,b)` primitive over `unix.Renameat2(…, RENAME_EXCHANGE)`
(`exchange_linux.go` + a `!linux` stub for macOS tooling) — and its **primitive test doubles as the
in-CI proof that the test filesystem supports RENAME_EXCHANGE** (the "test the layer you run in"
lesson; it passes on the container tmpfs). (2) A **unified per-job lifecycle** across all four
backends: `WorkDir` returns the idevicebackup2 TARGET (the `working/` parent) after seeding
`working/<udid>` from `latest/` (**safe strategy — hardlink→copy, amendment A**) or RESUMING a dirty
one; commit does verify → **atomic exchange** working/<udid> ⇄ latest/ → snapshot (zfs) / archive to
`versions/<prev>` (namespace); `Discard` KEEPS the dirty working on every terminal (unified — the
(cj) #4/#5 namespace-deletes-work asymmetry is gone); `RepairWorkingCopy` is now **Reset** (discard).
(3) The **`<target>/<UDID>` symlink dance is deleted** (`supervisor.go` lost `prepareTarget`) — the
target is the storage `working/` parent, always on the storage fs, so **bug 28b97de is structurally
impossible**; the free-space regression test was rewritten to assert that. (4) **browse_root** moves
`…/working` → `…/latest`; **snapshot name** `quince-<YYYY-MM-DDTHH-MM>-<ULID>` (amendment B — ULID
kept, minute-widened; `snapDateLayout`). (5) **Honest internal `kind`** from a `.quince-work.json`
seed sentinel (`Verify(tree, kind)` no longer trusts `IsFullBackup`) — a first backup is now
authoritatively `full`, so the encrypted blob-shard check actually runs (finding #9(a)); a stale
engine assertion that expected `incremental` for a first Wi-Fi backup was flipped to `full` (the fix
working). (6) **Reset**: `POST /api/devices/{udid}/reset-working` → 202|404|409|503 (engine-owned for
single-flight) + `quince device reset-working` CLI + contracts §1. (7) Hook **`mirror`→`seed` verb**
(host-side reflink clone latest→working/<udid> + chown; migration note in `deploy/storage.md`);
config **`storage.zfs.mirror`→`seed`** (enum auto|reflink|copy — hardlink dropped); `MirrorReport`→
`SeedReport`; offsite filter drops the obsolete `work/**` rule. **Gate proof:** the two independent
observers are a CI concurrent-reader test (`latest/` marker is NEVER missing/torn across a running
commit, both models — the exact failure the two-rename swap caused) + the marker-guarded kill-matrix
(prepared/exchanged/archived|snapshot_created) + resume-without-re-transfer. **Docs are part of the
diff:** stack D5/D5a (the `PROPOSED (gap)` flipped to RESOLVED; the commit-mirror block marked
SUPERSEDED), design §4/§5 (layout, interface, commit phases, escape hatch), contracts §1/§2/§6, and
`deploy/storage.md` all updated; the demo fixtures show the new model. **Owed to a hardware day
(named, not silently deferred):** the real-rpool lab legs — **G-snapshot** (probe-snapshot loop
during a running backup + at commit → always a complete `latest/`), **G-rclone** (continuous sync
never deletes/tears the remote), **G-exchange-live** (the in-container `exch` probe on the deployed
dataset — the go/no-go for the in-container exchange) — plus a syncoid mid-write pass, preserved
verbatim in the qn.5b spec's Gates + the `//go:build lab` harness. **12c stays deferred** (hardlink
disabled-to-copy, now including the seed). Frontier → **qn.6a**.
