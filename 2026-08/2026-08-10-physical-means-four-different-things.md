# 2026-08-10 — "physical" means four different things, and on reflink it means nothing per-file

**`Version.physical_bytes` is the apparent tree size on every backend. Measured per tier, the
reflink row is worse than quince#442's table says: there is no per-file measure of any kind that
sees the sharing.**

One 220 MiB tree, seeded once with each tier's own strategy, everything measured inside the rig — a
guest-side reflink is invisible to the host pool, so host numbers would be meaningless.

| | btrfs | XFS | ext4 (hardlink) | copy |
| --- | --- | --- | --- | --- |
| `dirSize`, v1+v2 — what quince reports | 461,373,440 | 461,373,440 | 461,373,440 | 461,373,440 |
| `du`, **inode-deduped** | 461,373,440 | 461,381,632 | **230,703,104** | 461,389,824 |
| filesystem cost of the seed | **0** | **4,096** | **8,192** | **230,694,912** |

**hardlink** is solved by one `du`: 230 MB against 461 MB apparent. **reflink** is not solved by
anything per-file — the seed costs zero bytes and every measure still reports full size in both
versions, because `st_blocks` counts a shared extent in full in each file and the inodes genuinely
differ so there is nothing to dedup by. A `du`-based fix would report reflink storage at 2x, 3x, Nx
while the disk fills at 1x, which is the same defect with more arithmetic.

## ZFS, where the word stops being one thing

Identical trees on `compression=off` and `compression=lz4`; two snapshots, the second after
rewriting one 5 MiB blob of forty.

| | off | lz4 |
| --- | --- | --- |
| `dirSize` (reported for **every** version) | 230,686,720 | 230,686,720 |
| snapshot `referenced` | 231,178,240 | **210,190,336** |
| snapshot `used` — v1 | 5,308,416 | 5,308,416 |
| snapshot `used` — **newest** | **0** | **0** |

Twenty-one megabytes of difference for identical content — one compressible file in the fixture.
`dirSize` cannot see compression any more than it can see sharing.

**And quince#442's proposed remedy needs correcting before anyone builds it.** It proposes
`zfs list -Ho used -t snapshot`. `used` is the snapshot's **unique** bytes — what destroying it would
free — so the newest version renders as **0 on disk**, and v1 renders as the incremental delta rather
than its size. The whole-tree figure is **`referenced`**. Both are legitimate and they answer
different questions; summing `referenced` over-counts shared blocks once per snapshot, summing
`used` reports zero for the most recent backup. Neither alone is the number the demo hardcodes. Not
proposing which — that is a wire-contract decision.

## The one channel that could solve reflink

`FIEMAP_EXTENT_SHARED`, which quince now issues in-process for the storage probe (quince#747). A
per-version physical figure on reflink is *"sum the lengths of extents not marked shared"* — O(extents)
per version, and the only channel that exists. Whether it is worth the cost is a separate question
and I am not proposing it.

**No quince code produced these numbers**, and no timing number appears: the rig is a VM behind a
USB bridge that has already re-enumerated once.

Refs quince#442, quince#747.
