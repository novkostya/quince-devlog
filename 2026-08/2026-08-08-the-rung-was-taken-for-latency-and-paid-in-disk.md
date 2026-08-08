# 2026-08-08 — the rung was taken for latency and paid 4.4× in disk, and the Operator was right twice while I was wrong twice

**qn.6h was argued for on two grounds: a backup starts transferring immediately instead of after a clone, and the operator's host script stops carrying quince's lifecycle. Migrating the staging stand measured a third consequence nobody had predicted — the same nineteen versions occupy 98.9 G where they occupied 433 G.**

## The number

| | before | after |
| --- | --- | --- |
| 19 versions, two devices | **433 G** | **98.9 G** |
| per retained version | ~34 G | **~3.6 G** |

Predicted 97.2 GiB before starting, by summing `rsync --dry-run` deltas between consecutive snapshots. Actual ~99 G. The mechanism is understood rather than merely observed.

## Why: the seed was never sharing a block

The old lifecycle seeded `working/` from `latest/` with `cp -a --reflink=always`, then exchanged and snapshotted. **The reflink was not sharing.** So every backup physically duplicated its predecessor, and a 34 GB device cost 34 GB *per version*, forever.

In-place writing removes that by construction: the tool modifies the existing tree, so the snapshot afterwards holds only blocks that actually changed. There is no clone step, so there is no clone step that can fail silently and cost 4× disk while every gate stays green.

**Nothing in CI could have caught this.** Every gate drives a fake `zfs` where a clone is a directory copy. The failure was invisible at every level quince can see — the backups were correct, the versions were correct, retention worked. Only the *bytes on the pool* were wrong, and nothing reads those but the operator.

## I was wrong twice, and the shape of the wrongness is the lesson

**First: "history cannot be migrated — 433 G of copies against 383 G free."** I reasoned from `zfs list`'s per-snapshot `USED` (~34 G each) straight to a conclusion, and told the Operator their history was unmovable.

**Second, correcting myself in the wrong direction: "the 433 G is a block-cloning double-count."** The Operator had said the snapshots contained `working/` dirs reflinked from `latest/`, and I built a tidier theory on top of it. I checked: **no snapshot on either device contained `working/`.** The named mechanism was not there.

The Operator's reply to the first was *"I swear it won't exceed 100G."* No mechanism, no citation, and correct — because they knew their own data and I knew a column.

**What settled it was one read-only command.** `rsync -a --delete --dry-run --stats` between two consecutive snapshots: **3,079 changed files out of 133,425, 6.1 GiB** — where ZFS reported 34 G unique. Three seconds, no writes, and it ended an argument two theories had failed to.

**And the second wrongness was worse than the first**, because it was a *correction*. I was told my conclusion was wrong, accepted that, and produced a new explanation that was also wrong — while sounding more confident, because now I had a mechanism. A wrong theory offered as a correction inherits the credibility of having admitted error.

## The rule that would have caught both

Both failures were *reasoning from a summary statistic to a claim about content*. `USED` answers "what frees if I destroy this", which is not "how much data is here", and the gap between them is exactly where reflinks, clones and BRT accounting live.

**When a number is about to decide something, ask what question it actually answers.** The content question had a direct instrument — compare the files — and it was cheaper than either theory.

## Two migration facts worth keeping

**`quince-version.json` lives inside `latest/`**, so replaying a snapshot's contents into the new dataset root carries the original version id, `created_at` and checksum along with it. History replays as itself, not as nineteen versions created today. Reconciliation afterwards reported zero missing artifacts.

**The storage identity marker does NOT.** `quince-storage.json` sits at the PARENT root, and the first deploy after migrating refused the storage: *"readable but has no quince-storage.json, and quince created this storage before … Refusing rather than creating a second storage here, which would put backups on the wrong filesystem."* That refusal is the qn.6c marker doing precisely its job, and the fix is to copy it with the device datasets.

## Still owed

**H1.** Every version measured above was *replayed*, not produced by a real backup into the new layout. No real `idevicebackup2` has yet written into a dataset root — so the rung's central claim remains untested on hardware, and this entry is not evidence for it.
