# 2026-08-10 — the reflink probe tested independence, and a full copy passes that identically

**`ReflinkProbe` selected the backend quince chooses FOR SPACE on evidence that cannot tell a clone
from a copy. Fixed to assert sharing via `FIEMAP_EXTENT_SHARED`, and measured on six real
filesystems for the first time — a lab rig now exists that this project has never had.**

quince#747 filed it and named the question that decides whether it is live or latent: does
`reflinkFile` issue FICLONE directly, or go through `copy_file_range` where a kernel fallback can
succeed without sharing? **It issues `unix.IoctlFileClone` — the ioctl, directly.** So on every
filesystem measured it was latent. That does not rescue the probe: it chose on evidence that could
only distinguish a clone from a *hardlink*, and a network or FUSE layer implementing FICLONE as a
copy would have been accepted silently, after which every version is a full physical copy and every
gate stays green.

PR quince#787. Sharing is asked first, because the old probe's mutation step is a truncating rewrite
that destroys the sharing it would otherwise be measuring.

## The rig said three things nobody predicted

**btrfs INLINES a small file.** The probe wrote 8 bytes. An inline extent carries no sharing flag
even after a real `cp --reflink=always` — so a naive fix would have reported btrfs as *unshared* and
silently downgraded it to hardlink. The probe file is now 1 MiB, with a test asserting the floor,
because that failure mode is invisible to a green gate. This is the one that would have shipped.

**`copy_file_range` reflinks on btrfs and XFS**, so `clonetree.copyFile` — `io.Copy` between two
`*os.File`, whose `ReadFrom` issues that syscall — does not produce a full copy there. Found because
the regression test's first fixture was built with it and **failed**, reporting the copy as shared.
It genuinely was one. Filed as quince#788; the fixture became a userspace write.

**ZFS refuses FICLONE with `EAGAIN`** on a source written moments earlier — block cloning wants the
data in a synced txg — so quince reports *"reflink unsupported on this filesystem"* about a
filesystem that supports it. `ErrReflinkUnsupported` is also the wrong error for a transient
condition. Filed as quince#790.

## The regression test is hermetic, and that took a second attempt

The defect case — a FICLONE that succeeds and shares nothing — **cannot be produced on demand.** No
rig tier does it: btrfs and XFS share, ext4 and exFAT refuse the ioctl, ZFS refuses it transiently.
The first version of the test therefore skipped in CI and would have skipped forever, which is not a
regression test. The verdict is now a pure `reflinkVerdict(sharing, why, independent)` with a table
test, every row running anywhere.

The filesystem-dependent half still skips in both places this project's gates run — the toolchain
container's `/tmp` is overlayfs, the runner box is ZFS, and neither answers `FS_IOC_FIEMAP`. Run on
the rig with `TMPDIR` pointed at each tier: pass on btrfs, XFS and ext4.

## What canon already said, which is the best part

`docs/quince.stack.md` D5 has ruled this shape since 2026-07-20, Operator-challenged twice:

> The one edge: a **measured-not-sharing** reflink falls through to hardlink-under-matrix … Absent
> any measurement channel, reflink wins on the risk asymmetry — its worst case is copy COST
> (reported "unverified"), hardlink's worst case is silent `latest/` corruption.

The implementation matches it clause for clause, and I found that out **after** designing it. The
ruling names its measurement channels — hook avail-delta, `zfs list`, a `statfs` delta — and FIEMAP
is not among them; it is better than all three (exact, per-file, unaffected by a concurrent writer)
and is now the first entry.

**No tier changes backend.** Before and after select the same thing on all six. What changed is the
evidence, and the sentence an operator reads on the storage card.

Refs quince#747, quince#787, quince#788, quince#790.
