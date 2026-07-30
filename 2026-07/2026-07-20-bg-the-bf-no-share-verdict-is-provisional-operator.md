# 2026-07-20 — (bg) the (bf) no-share verdict is PROVISIONAL — Operator challenged it, and there is a specific accounting trap that could fully explain the evidence

(bg) **the (bf) no-share verdict is PROVISIONAL — Operator challenged it, and
there is a specific accounting trap that could fully explain the evidence.** ZFS charges
BRT-cloned blocks like dedup: full size per reference at dataset level (`zfs list used`,
`du`); the savings are visible ONLY at pool level (`zpool get
bcloneused,bclonesaved,bcloneratio` / pool ALLOC delta). All three gate-12 measurements are
consistent with WORKING clones misread through dataset accounting. Discriminator protocol
(host-side, zero container layers, ~10 min): on the PVE host — `zfs create` a throwaway,
`dd` a test file, `zpool sync`, note `bclonesaved` + pool ALLOC, GNU `cp --reflink=always`,
`zpool sync`, re-read both. `bclonesaved` grows ~file-size → cloning WORKS, reflink
reinstated, (bf)'s demotion reverses (the probe still moves to pool-level measurement —
that part of the ruling stands regardless). Flat → the no-share finding is real; then `zfs
get encryption` (BRT × native-encryption restriction) before any upstream filing. Also
eliminate stack layers while at it: the original harness ran through container/bind paths —
the re-measure runs on the host with GNU cp; note `zfs_bclone_wait_dirty=0` makes clones of
UNSYNCED data fail (a Go fallback chain could silently copy) — hence the `zpool sync`
before cloning. The EXDEV-from-snapshot finding is unaffected (cross-superblock FICLONE is
kernel behavior no mount option changes; the clone-from-`working/` fallback stands). Remaining gate-12 legs: iMazing-opens
(Operator GUI), syncoid mid-write (needs a replication target), the 12c matrix — with the
iOS-upgrade leg marked OPPORTUNISTIC (runs at the next real update; a named trigger, not a
blocker), the rest forceable now.
