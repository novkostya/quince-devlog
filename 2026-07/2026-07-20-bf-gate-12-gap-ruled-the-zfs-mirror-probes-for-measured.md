# 2026-07-20 — (bf) gate-12 gap RULED: the zfs mirror probes for MEASURED sharing, not FICLONE success

(bf) **gate-12 gap RULED: the zfs mirror probes for MEASURED sharing, not FICLONE
success.** The gate's Operator-run core PASSED on real ZFS 2.4.3 (throwaway child dataset;
create → snapshot → mirror → registry → `RepairWorkingCopy`, twice; **A1's encrypted `Verify`
proven on the real ~34G encrypted tree** — committed without opening `Manifest.db`, exactly
the CI-blind bug the amendment predicted) and surfaced two definitive findings: (1)
reflink-from-snapshot = `EXDEV` (interface fact 2 answered; the designed clone-from-`working/`
fallback stands); (2) **FICLONE succeeds WITHOUT sharing blocks on the real pool**
(`block_cloning` active, `zfs_bclone_enabled=1`; verified three independent ways) — the
"zero extra space" reflink premise is false there. Ruling: option (c) sharpened — the mirror
strategy chain stays reflink → hardlink → copy, but the probe measures real physical-usage
sharing; ineffective reflink is demoted, the hardlink strategy is the space candidate GATED
on the 12c destructive matrix, and copy is the always-correct floor with its cost SURFACED
(no silent fallback). Option (b) — offsite sync from `.zfs` paths — REJECTED: `snapdir=hidden`
hides them from rclone, `snapdir=visible` uploads every snapshot at full size; D5a stands.
Option (d) — root cause — demoted to a non-blocking side quest; first check: `zfs get
encryption` on the pool datasets (BRT + native encryption has documented no-share
restrictions — this may be known behavior, not a 2.4.x bug), then an upstream issue if it
reproduces on an unencrypted dataset. Stack D5 amended.
