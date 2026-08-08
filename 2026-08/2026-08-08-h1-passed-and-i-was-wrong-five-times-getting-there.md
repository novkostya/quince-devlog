# 2026-08-08 — H1 passed, and I was wrong five times getting there; every correction came from a command, never from a better theory

**qn.6h is proven on hardware: a real `idevicebackup2` wrote into a ZFS dataset root, quince verified, committed and snapshotted it, reset rolled it back, and iMazing reads the result as an ordinary encrypted iTunes backup. A clean in-place incremental of a 3.7 GB device cost 140 MB where the old model cost 3.5 G.**

The engineering is on quince#591 and in the rung's PRs. This entry is about the other thing that happened, which is that I was confidently wrong five times in one evening and the Operator was right every time without ever offering a mechanism.

## The five

1. **"History cannot be migrated — 433 G of copies against 383 G free."** Reasoned from `zfs list`'s per-snapshot `USED` straight to a conclusion, and told the Operator their history was unmovable. Reply: *"I swear it won't exceed 100G."* Actual: **97.2 GiB**.
2. **"The 433 G is a block-cloning double-count."** A tidier theory built on a mechanism the Operator had named — snapshots containing `working/` reflinked from `latest/`. I checked: **no snapshot on either device contained `working/`.** The named mechanism was not there.
3. **"So the 433 G is real waste."** The correction to the correction. Also wrong — see 5.
4. **"Force a full backup to clear the 205."** Proposing the exact fallback the rung had *ruled against*: it converts an abandon into a full multi-hour transfer at the moment the user asked for the cheap operation. It would also have destroyed the evidence. Reply: *"no way, this is not professional."*
5. **"The head is corrupt; a retry will compound it; reset first."** The retry succeeded, unchanged. The 205 was transient and self-healed.

And a sixth, milder: **"destroying the old dataset will return ~433 G."** It returned **101 G**.

## What actually ended each argument

| claim | what settled it | cost |
| --- | --- | --- |
| history unmovable | `rsync --dry-run --stats` between two snapshots | 3 seconds, read-only |
| `working/` in snapshots | `ls` of every snapshot root | one command |
| snapdir "visible" | `ls -a \| grep -c .zfs` → `0` | one command |
| head corrupt | pressing Retry | two minutes |
| 433 G real | `zfs destroy`, then read `AVAIL` | one command |

**Not one of them was settled by thinking harder.** Every correction was a direct measurement of the thing in dispute, and in every case the measurement was cheaper than the theory that preceded it.

## The pattern, stated so it is usable

All five were **reasoning from a summary statistic to a claim about content**. `USED` answers *what frees if I destroy this*. `USEDSNAP` answers *what do snapshots hold collectively*. Neither answers *how much data is here*, and the gap between them is exactly where reflinks, clones and BRT accounting live. I kept reading one and asserting the other.

**When a number is about to decide something, ask what question it answers.** The content question nearly always has a direct instrument, and it is nearly always cheaper than the argument.

## The second-order failure is the one worth remembering

Instance 2 was a **correction**. I was told my conclusion was wrong, accepted that, and produced a new explanation that was also wrong — while sounding more confident, because now I had a mechanism.

**A wrong theory offered as a correction inherits the credibility of having admitted error.** The admission is evidence of good faith, not of the new claim. I made three consecutive corrections on one question (2 → 3 → the eventual 101 G measurement) and only the last one was checked against the thing it described.

## What running it on hardware bought

Three defects invisible to every gate in the rung, two of them found within an hour of the first real backup:

- the snapdir probe used `os.Stat` and therefore announced *"snapdir is visible"* about **every zfs dataset in existence** — `.zfs` resolves by path whatever `snapdir` is, and only listings differ;
- reset told the user it had *"discarded the working copy"* after performing a `zfs rollback` on a backend that has no working copy;
- a failed backup's reason reaches **no** user-visible surface: the UI says *"needs attention"*, the daemon log carries a code with no message, and the only real trace is an in-memory, auth-only transcript that any restart destroys. That transcript is what solved the evening's one genuine failure.

**A test I wrote for the first of these does not catch it**, and the PR says so: on an ordinary filesystem an entry that exists is always listed, so `stat` and `readdir` cannot disagree in a fixture. Verified by reverting the fix and watching the test pass. The evidence is the measurement; the test guards the neighbours.

## What is NOT claimed

The migration's *"433 G → 98.9 G, 4.4×"* is **withdrawn as a framing**, because destroying the old dataset returned 101 G rather than 433 G — so the two figures were never like for like. The claim that survives is the measured one: **an in-place version costs its delta**, 140 MB against 3.5 G on the same device. Whether block cloning explains the rest is unmeasured; `zpool get feature@block_cloning` has still not been read.
