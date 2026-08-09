# 2026-08-10 — the hardlink seed is unsafe through exactly one `idevicebackup2` call, and a class list cannot bound it

**Gate 12c's matrix run on real ext4, then the question the matrix cannot answer read out of the
pinned source: three of `idevicebackup2`'s four write paths already unlink before creating, and the
fourth does not — and its destination is chosen by the DEVICE at runtime.**

quince#518 names three mutually exclusive ways out and declines to choose. So does this. Evidence
only.

## The matrix

A hardlink seed built the way `clonetree.Hardlink` builds one, then each writer behaviour applied:

| what the writer does to `working/<f>` | `latest/<f>` |
| --- | --- |
| in-place write, no truncate | **CORRUPTED** |
| truncate + rewrite (`O_TRUNC`) | **CORRUPTED** |
| write temp, `rename()` over | intact |
| `unlink()`, then create | intact |
| in-place write to a `MutatesInPlace` class | intact — it was copied |

Nothing surprising, and that is the point: the safety property reduces entirely to *does the writer
reach an aliased inode through the first two rows*. Amendment A says so; this is it measured.

## So which does the writer do? `LIBIMOBILEDEVICE_REF=1.4.0`, read

| line | path | destination opened as | aliased? |
| --- | --- | --- | --- |
| 1095 | `DLMessageDownloadFiles` — **the bulk of every backup** | `remove_file(); fopen("wb")` | **safe** |
| 2027 | `Info.plist` regeneration | `remove_file(); plist_write_to_file()` | **safe** |
| 2366 | `DLMessageMoveItems` | `remove_file(); rename()` | **safe** |
| 1289 | `mb2_copy_file_by_path`, from **`DLMessageCopyItem`** | `fopen(dst,"wb")` — no remove | **UNSAFE** |

The in-tree patches touch none of it: `0001` is a receive timeout, `0002`'s hunks are at 75 / 1440 /
1512 / 1532 / 1605 / 2062, `0003` is `ideviceinfo`.

**Three of four already use the unlink-first idiom**, which is more encouraging than amendment A's
caution implies — the bulk of a backup would survive a hardlink seed untouched.

**The fourth is worse than a missing list entry.** `DLMessageCopyItem` carries a source and
destination the *device* chooses, as arbitrary paths inside the backup directory. `MutatesInPlace`
is a static basename-suffix list; it **cannot** be complete against a destination named at runtime
by the other end of the protocol. So quince#518's option 1 — *"run gate 12c and enable the hardlink
seed"* — is not "prove the list is complete". The list cannot be complete for that path, and
enabling the seed would need a different mechanism.

## The number quince#518 says was never measured

A hardlink seed of a 220 MiB / 41-file tree on ext4 cost **8,192 bytes**. The copy seed of the
identical tree cost **230,694,912**. Filesystem free-space delta either side of the seed.

**No timing number.** The issue's *"seconds"* stays inference; the rig cannot honestly produce a
seconds-vs-thirty-minutes claim. What is measured is that the seed writes essentially nothing, which
is the mechanism that inference rests on.

## Two honest limits

**The `DLMessageCopyItem` finding is a source read, not an observation.** Nobody has seen a device
send it. The source says it is reachable and says nothing about frequency — so the owed leg is one
verbose incremental on the staging stand, grepping for it, with the confirming and refuting outcomes
written down before the run.

**Not a replay fixture, and saying so rather than skipping it.** The hard rule sends every bug found
to `core/internal/backup/testdata/transcripts/`. Those are `idevicebackup2` **stdout**, replayed to
prove the state machine. This defect is filesystem aliasing and emits nothing on stdout; a transcript
cannot carry it. The artifact that would is a matrix harness in `clonetree`, which is a fix-shaped
thing this issue asks nobody to build yet.

Refs quince#518.
