# 2026-08-20 — pairing records belong to the muxer, and three things in quince still thought otherwise

**quince#1310 and quince#1311 merged. A question about one line in a compose file — "is this
lockdown mount correct?" — turned out to be a model that moved at qn.6p and took nothing with it.
The shipped profile could not record a pairing, and the one that could was destroying records on
save.**

## What the Operator asked, and why it was the right question

*"Is `./quince/data/lockdown:/var/lib/lockdown` correct for the host-muxer file?"* It was the same
mount the sidecar file had, so the honest answer needed the model behind it — and the model was
wrong.

Then: *"check how it works on [the two stands] then."* That instruction is the reason
this entry is not a list of confident errors. **Every conclusion this seat reached by reasoning was
corrected by a measurement**, in both directions.

## The model

`libimobiledevice/common/userpref.c`: `userpref_read/save/delete_pair_record` are each a message to
the muxer, with **no filesystem fallback**. `/var/lib/lockdown` is the *daemon's* store, never
libimobiledevice's directory.

Before qn.6p quince supervised the muxer inside its own container, so the daemon's store *was*
quince's. The split moved it and the model did not follow.

The cleanest evidence was a stand nobody had thought to look at: a macOS deployment proxying the
host's usbmuxd socket, with **both lockdown directories empty and the device working.** No theory in
which quince owns pairing records can explain that.

## Three consequences, and the order they were found in is backwards from their severity

**The one that was filed first was the smallest.** `copyFile` opened `dst` with `O_TRUNC` before
reading `src`, so where a deployment bound one host directory at both `$QUINCE_DATA/lockdown` and the
system dir — as both shipped examples did — a pairing record was truncated to zero on save. Measured:
one inode through both container paths, and `32 bytes → 0` against the real `LockdownStore`.

**The one that mattered most was found last.** `Writable()` write-probes quince's own directory to
decide whether Pair is offered, while the save happens in the muxer's. So the button is offered, the
user walks to the phone and taps Trust, and the record is discarded — the exact walk qn.6p D7 exists
to prevent, with the check in the right place asking the wrong filesystem.

**And `LockdownStore` is vestigial**: restore-at-startup and backup-after-pair implement quince as
custodian of records it does not own.

## The measurement that changed the answer

The architect ruled four items and blocked the mount change on one question: **does netmuxd implement
`SavePairRecord`?** Canon had only ever claimed it *reads*.

It does — at the pinned commit, verified byte-identical to `master`. And the shipped profile still
could not record a pairing:

```
upstream configured  ->  forward the frame, return its answer
otherwise            ->  tokio::fs::write(<plist_storage>/<udid>.plist, data)
```

The shipped profile runs netmuxd alone, so every save takes the second branch and writes into a
directory mounted `:ro`. **Neither of the two worlds the ruling anticipated** — which is precisely
why it said measure before proposing.

## What shipped, and what deliberately did not

`os.SameFile` on the **open handle** (statting the path would be a TOCTOU window in a function whose
failure mode is destroying the file), quince's mount dropped from both examples, and `:ro` removed
from the muxer's.

**Both regression tests fail without the guard**, verified by removing it. Neither watches the return
value, and that is the point: `Backup()` returned success the whole time it was emptying files. A
test checking the error would have passed throughout, which is how this shipped.

Left on the issue: retiring `LockdownStore`, and moving D7's check to something that can actually
fail. Both start from a spec.

## The pattern, again

Four corrections in one thread, each to a confident claim:

- *"destroys every pairing record"* — latent; `Backup()` has one caller, a UI pair, and no stand had
  paired since;
- *"quince writes them, the muxer reads them"* — backwards, in both halves;
- *"the macvlan alternative is untested"* — it was tested, before the topology it was tested on
  stopped existing;
- *"netmuxd does not save"* — it does, and the mount was the problem.

**The reviewer's own note belongs here too**: he approved both compose files and checked links,
jargon and structure in each — *"neither checked the volume mounts against the code that reads them.
I treated a compose file as documentation, and it is configuration with a contract behind it."*

Nobody has paired a device through the shipped stack. Everything above is source plus measured
mounts, and `qn.6p` G8 is still the gate that would settle it.
