# 2026-08-02 — The schema change had a behaviour change inside it, and the tests would have passed either way

**`retention` moved from a global key to a per-storage one. That is a config-shape edit — and it
silently redefines what `keep_recent: 10` MEANS.** Under one global policy, ten versions per
*device*. Per storage, ten *on that disk*. Adding a second disk would have quietly changed what the
first one keeps, and the way a user finds that out is by losing versions.

Found while building quince#473 (quince#506). Recorded because nothing in the change announces it:
the flattening was directed as *"make it per-storage"*, and the consequence is two layers down in
`Prune`.

## Why no test would have caught it

`Prune(udid)` took a device's versions and applied `m.policy`. After the schema change it still
compiles, still passes, and is still wrong — because the *policy* is now per-storage while the
*application* is per-device. Every existing test uses one storage, where the two are
indistinguishable. A suite that is green on a single-storage fixture cannot see a bug whose
precondition is a second storage.

**So the failure would not have been a test failure. It would have been a support question a year
later**, from someone who added a shuttle disk and noticed their pool had stopped keeping thirty
dailies.

## What it forced, which is the part worth keeping

Grouping `Prune` by storage is obvious once stated. The two cases underneath it were not, and both
had to be *decided* rather than defaulted:

- **A version with no `storage_id`** — unattributed, transitional, reconciliation has not yet placed
  the artifact. Pruned under the DEFAULT storage's policy, because pruning under nobody's policy
  means never pruning, and "never pruning" is a silent unbounded keep dressed as safety.
- **A version attributed to a storage this process does not declare** — the entry was removed from
  `config.yml`. **Skipped and logged**, never pruned under another storage's number: deleting
  versions using a number the user never wrote for them is the same class of wrong the whole change
  exists to remove.

Neither is clever. Both are invisible unless someone goes looking, and the reason to write them down
is that the *next* schema change will have its own pair.

## The generalisable shape

**A schema is a description of what can be written. Semantics is what the values mean. Moving a key
changes the first and can silently change the second** — and the review that approves the schema is
looking at the first.

The tell is a scoping word: `retention` went from applying to *a deployment* to applying to *a
storage*. Any key whose SCOPE changes has this hazard, and "scope changed" is a cheap thing to grep
a diff for. `backend` and `zfs` moved in the same change and were safe, because they were already
per-storage in effect — the global was only ever a default. `retention` was the one that was
genuinely global, and it was the one that bit.

## And the deletion list was wrong, which cost nothing because it was checked first

quince#473 listed `CheckStorageBackends` among what the flattening deletes. It does not: its
duplicate-`parent_dataset` collision is not caused by inheritance, and two fully-specified entries
can still produce it. Deleting it would have reintroduced quince#458 by another route, in the change
whose purpose was to make quince#458 unconstructible.

**That was caught by reading the function before writing the diff, not by review** — and it had
already been approved into canon in my own words on quince#500, which I amended before it merged.
Three of that issue's six scope lines came from reading rather than from the issue. Two of the three
would have shipped as defects.

Refs: quince#473, quince#506, quince#500, quince#458, quince#504, quince#378.
