# 2026-07-22 — (cg) `PROPOSED (gap)`: the `latest` swap is NOT atomic — the D5a offsite promise is broken today. `qn.5b` inserted (Operator-found)

(cg) **`PROPOSED (gap)`: the `latest` swap is NOT atomic — the D5a offsite promise is
broken today. `qn.5b` inserted (Operator-found).** The Operator re-derived the requirement from
first principles — *a `zfs snapshot` at ANY instant captures a solid `latest/`; the directory
`idevicebackup2` writes into is rclone-excluded; changes to `latest/` are ATOMIC* — and asked the
architect to check it rather than accept the prose. **Constraint 3 fails.** Both paths do
`mv latest → latest.old; mv latest.new → latest` — the in-container Go path
(`storage/zfs.go:203`) and the host-side hook `mirror` verb (`deploy/storage.md`) — **each
commented "atomic swap," neither atomic.** Between the renames `latest/` **does not exist**, so
(1) an `rclone sync` crossing the window sees it missing and **DELETES the remote B2 copy** (sync
mirrors deletions — a wipe + 33 GB re-upload, not the "briefly mixes two valid versions" stack D5
claimed), and (2) a `zfs snapshot` there captures a version with no `latest/`. Canon had *named*
the window but **understated it**, and the fix it already gestured at (exchange-rename) was never
built. **Architect correction owed:** the earlier claim that `working/` must persist "for
incrementals" was **wrong** — MobileBackup2 increments from a reflink clone of `latest/` exactly
as from a persistent directory; the "Seed is a no-op" elegance predates knowing block cloning was
cheap, which gate 11 has since measured (`bclonesaved` +33.6 GiB). **So the Operator's proposal is
adopted:** per-job `working/`, seeded as a clone at job start, so between backups the dataset holds
**only `latest/`** and every snapshot structurally contains exactly one complete backup — the
requirement satisfied by construction instead of by careful sequencing. **Preserved: resume** —
on FAILURE the dirty `working/` is KEPT so a retry resumes (a 33 GB Wi-Fi backup dying at 90% must
not restart); on success it *becomes* `latest/`. **Also folded in (Operator):** the
`<target>/<UDID>` **symlink dance is dropped** — it exists only because `idevicebackup2` writes to
`<target>/<UDID>/`, and it *caused* the gate-blocking free-space bug (28b97de) by putting the stub
on the wrong filesystem; choosing the staging path so the tool's own convention lands correctly
makes that bug class structurally impossible. **Post-failure UX** (Retry / Reset / possibly
Retry-clean) is **delegated to the qn.5b implementer** — 2-vs-3 actions, landed as a **contract
proposal reviewed here** (`Reset` is the landed `RepairWorkingCopy`, CLI-only today, so a UI
surface is a REST addition). **Interface fact to verify live, never assumed: does ZFS implement
`RENAME_EXCHANGE`** (a VFS flag); the symlink workaround stays forbidden (D5a). Privilege split
favours us — only FICLONE needs the host, so the hook keeps the reflink and quince does the
exchange in-container. Commit reorders to verify → exchange → snapshot, making the version
`latest/` and `browse_root` point at the real latest backup. Bonus: D5's **two version models
collapse toward one** (namespace backends already seed-from-latest and rotate).
**Alternative considered + REJECTED (same day, recorded in the qn.5b roadmap entry so the
implementer doesn't re-explore it):** an all-ZFS-primitives design — `zfs clone` the working
area into its own dataset, back it up there, then `zfs send workdir@ready | zfs receive -F
…/latest`. The clone half is genuinely clever (instant, zero-space, and it would sidestep the
FICLONE-`EPERM` problem entirely, being a `zfs` command rather than a syscall) but loses on
three counts: the seed is already cheap and measured, a clone **pins its origin snapshot**
(retention entanglement), and making `working` a *dataset* is exactly what forces the fatal
half. The `send | receive -F` publish step is a **full 33 GB copy** (no block sharing) and,
because the destination is rolled back and applied progressively (typically unmounted for the
operation), it turns a **microsecond** missing-`latest/` window into a **minutes-long** one —
strictly worse than the bug being fixed. **Generalizable principle recorded:** the requirement
is that a *filesystem path stay continuously valid for a walker*, and every dataset-level
operation (send/receive/rename/promote) involves a **mount transition**, so none can satisfy
it — only a directory-level atomic exchange can. send/receive remains exactly right for what
it already does here: **replication** (syncoid offsite, proven at gate 11).
