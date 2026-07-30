# 2026-07-20 — (bs) qn.4a LAB GATE 15 — the engine legs PASSED on real hardware (iPad15,7, iOS 26.5)

(bs) **qn.4a LAB GATE 15 — the engine legs PASSED on real hardware (iPad15,7, iOS 26.5).**
The CLI-USB + kill-matrix half of gate 15 (the UI-driven both-transports backup moved to qn.4b
gate 11 per (br); the mirror/iMazing/syncoid zfs legs deferred, below). Driven on the qn.2b/qn.3
staging CT (managed usbmuxd, live `/dev/bus/usb`, `hardlink` `/backups`); the qn.4a image
re-pushed as `quince:staging` + redeployed. **Proven end-to-end, both encryption variants:** (1)
an UNENCRYPTED `quince backup` → committed structure-verified version — qn.5's **unencrypted
`Verify` branch ran on a real 102 MB plaintext `Manifest.db`** (opened read-only, tables + sampled
records → blobs), which CI had only faked; (2) after enabling encryption via the pty CLI, an
ENCRYPTED backup → **A1's encrypted `Verify` branch on real encrypted data** (`Manifest.db` header
is NOT SQLite-magic + 256 blob shards, verified WITHOUT opening the DB), `encrypted:true`;
**version rotation** proven (encrypted → `latest/`, unencrypted → `versions/<ts>/`). **Interface
fact 1 CONFIRMED live** — the real `idevicebackup2` follows the `<target>/<UDID>` **symlink
adapter** into the qn.5 work dir (2.8 GB landed through it). **Interface fact 5 CONFIRMED** — the
`backup` child argv/env carries NO password; the device's keybag encrypts (the password set once
over the `encryption on` pty stayed masked — never in argv/env/logs/context; secrets discipline
held). **Kill-matrix (backing_up) PASSED:** a hard `SIGKILL` of quince mid-`backing_up` left the
committed versions **untouched** (never-mutate invariant held under a real crash); on restart,
reconciliation **swept the orphaned 3.1 GB work dir + flipped the job → `connection_lost`, no
phantom version** (storage `Scan` → engine job-row, the two-reconciler order). `verifying` is
equivalent (pre-commit); the `committing` **roll-forward** is CI-proven (story 13) and impractical
to time on the sub-second hardlink commit — declared, not hardware-run.
**DEFERRED (named, not dropped) — the zfs legs** (host `mirror` verb / `bclonesaved` moving /
iMazing-opens / syncoid mid-write): they need the rpool **hook-mode** topology (a forced-command
SSH credential + a CT mount reconfig with `rbind,rslave`) — disproportionate production-host setup
for incremental value, since the core zfs facts (reflink/EPERM/EXDEV, `bclonesaved` sharing) are
already hardware-proven on this exact rpool in gate-12 ((bf)→(bk)). Operator ruling: wind down +
record; run the zfs legs in a later dedicated session. The **syncoid receive target is prepped**
on the offsite PVE host (specifics in `local/environment.md`; reachable from the workstation + the
lab host over the existing inter-host path — no new key needed). (Aside: that host currently runs
its pools DEGRADED on a known-dropped NVMe — Operator-accepted, to be fixed in person.)
**FOUR lab findings surfaced + filed as tasks** (invisible to the CI fakes — the gate did its
job): (i) `deviceops.willEncrypt` maps an ABSENT `WillEncrypt` key (exit-0, empty — a device that
never set a backup password) to `"unknown"` not `"off"`, so the Manage-encryption UI asks for a
*current* password on an unencrypted device + the off-warning banner never shows; (ii) **[FIXED 2026-07-20]** `quince
backup <udid> --transport usb` failed — Go's `flag` stopped at the positional udid, so `--transport`
was dropped → usage error (CI called `StartBackup()` directly, bypassing arg parsing). Fixed:
extracted a pure `parseBackupArgs` with a multi-parse loop that honours flags before OR after the
positional; red→green `TestParseBackupArgs` in `cmd/quince` (coverage 8.5%→14.9%); (iii) the
version card's `Unlock` button (`ui/src/features/versions/VersionList.tsx:31-33` — a `disabled` qn.8
placeholder) renders on EVERY version incl. unencrypted ones, implying a password gate an
unencrypted backup doesn't have; fix = encryption-aware on `version.encrypted` (already used for the
`unencrypted` badge, contracts §2 / `ui/src/lib/types.ts`): encrypted → `Unlock` (password → browse),
unencrypted → `Browse` (direct read, no password), per design §7 (unlock is encrypted-only) — inert
today so UI-polish / qn.8-area, not a functional defect; (iv) the device card lingers on "Backing up 100%" through verify+commit and doesn't
reflect `device.last_backup` (check the engine sets it on success). (iii)/(iv) may be subsumed by
qn.4b's landed job-history/backup UI (br) — dedup at fix time. **(v) CONFIRMED + root-caused
(2026-07-20 zfs session):** `device.last_backup` is populated **only in the `demo` provider**
(`internal/demo/{script,jobcontrol,fixtures}.go` `refreshLastBackup`) — the REAL path (engine
`Commit` success + `wire.Device` serialization from the live registry/store) never writes it, so a
paired device with committed versions shows **"No backups yet"** on the card while the version list
right below shows them (Operator screenshot: 5 versions — 3 `zfs incremental · structure verified`,
2 `hardlink` — under a "No backups yet" card). This proves (iv)'s hypothesis; fix = the engine sets
`device.last_backup {at,job,status}` on commit success (or the device DTO derives it from the latest
committed version) — dedup with qn.4b's backup UI (br). **(vi) GitHub Actions CI RED on `main` —
root-caused + fixed (2026-07-20).** Only the `e2e` job failed (`gates`+`image` green), on bu+bv+a
re-run: the two qn.4b **story4** Playwright tests time out waiting for the demo devices
`spare-iphone` + `new-iphone` to appear. Root cause: `demo.deviceChurn` reset `p.order` to a
hardcoded `[phone]`/`[phone,pad]` every 20 s, wiping the on-demand devices `seedOnDemandDevice`
had appended at `Run()` — so story4 passed only if it ran inside the first 20 s (green at bq on a
fast runner; reliably red once the runner scheduled story4 later). NOT a code regression (main
unchanged since bq) — a latent demo bug CI timing finally exposed. **Fix:** churn toggles only the
pad in `p.order` (new `removeUDID` helper), preserving phone + on-demand devices; stories 1–3 only
assert phone/pad so they're unaffected. Verified by reading (no local Go toolchain) — CI confirms on
the next push. **Observations (not bugs):** both
runs came out `kind:incremental` — `idevicebackup2` did device-relative differentials, and the
encryption change did NOT force a full backup on this iPad (unlike the lab-log iPhone) → a real
product question (should the engine pass `--full` on the first backup / after an encryption
change?); an unencrypted backup on an already-paired, unlocked device needed **no on-device
passcode** (a D13 nuance — the "every backup" claim looks encryption/Trust-specific); startup
reconciliation took **~7 s** (storage `Scan` walks `/backups`) — a scaling note for large stores.
**qn.4a's engine goal — the M3 engine half — is hardware-proven.**
