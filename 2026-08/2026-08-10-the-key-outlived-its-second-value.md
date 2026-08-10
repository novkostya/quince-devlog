# 2026-08-10 — the key outlived its second value, because deleting it would have downgraded a refusal to a shrug

**Removing `storage.zfs.mode: exec` looked like a deletion and turned out to be a choice between two
diagnoses. The cleaner-looking option — take the key out of the schema — would have turned a config
that cannot work from something quince REFUSES into something quince reports as `unknown config key
… (ignored)`.** So the key stays, carrying one legal value, purely so the refusal exists
(quince#793, closing quince#697).

The Operator ruled the mode away rather than re-defaulted: it ran `zfs` inside the container, the
shipped image has no `zfs` binary, and shipping the userland was rejected because the CLI talks to
the host kernel module over a versioned ioctl interface — the image would have to track a host
version that is not ours to control. The relay (`arch1`, on quince#697) left exactly one thing to
whoever executed it: *does `zfs.mode` disappear from the schema, or become a one-value key?* It
noted that disappearing is cleaner but then needs "a refusal that says what to do".

**That caveat turned out to be the whole answer, and it is mechanical rather than a matter of
taste.** `unknownKeys` has one message template — `unknown config key %q (ignored)` — and no
per-key hook. There is nowhere to put "this was removed; here is what to write instead". So the
change that removes an unrunnable mode would, in the same diff, downgrade its diagnosis to
something explicitly labelled *ignored*. That is the silent-fallback case CLAUDE.md forbids,
arriving inside the fix for it.

Kept as a one-value enum, the existing machinery already says the right thing. Measured, not
reasoned:

```
error: storage[0].zfs.mode: invalid value "exec"; must be one of [hook]
quince: config invalid: <path>
exit status 1
```

and the same file with `hook`, **or with the `mode:` line deleted**, prints `config OK:`. Two
remedies, both correct, because an absent key now resolves to `hook`.

**The residue is honest debt rather than a loose end**: a key with one legal value is untidy against
D12, and removing it later is strictly easier than un-removing it. What it wants is a retired-key
warning that names its successor — which is quince#401, already open, and its own reviewable claim.

**One thing worth recording about the shape of the work.** For anyone already on `mode: hook`, this
changes nothing at all: `argv()`'s hook branch is untouched and `Capacity`'s hook arm is untouched,
so every verb's argv is identical before and after. That is what made a ruling about a config enum
land as a config-surface change rather than a storage-semantics one — and it is why the test that
replaced the deleted `TestZFSCapacityExecModeCallsZFSDirectly` was written across **all six** verbs
instead of `capacity` alone. The branch that was removed lived in the *method*, not in `argv()`. A
reintroduced direct call would most likely come back the same way, in one method, where a test
pinning one verb would never see it.

**Two sites the relay's scope table did not have**, found by sweeping rather than by trusting it:
`storage.Options.ZFSMode` with its `Select` call site, and `labgate_test.go`'s
`QUINCE_LAB_ZFS_MODE`. The table was careful and said so — *"confined, and I checked rather than
estimated"* — and was still two short. Not a criticism of it; an argument for sweeping anyway when
the table is someone else's.

**What is owed.** A live daemon restart on a config carrying `exec`. I read that path — quince#508
deliberately passes the load's warnings to `CheckStorages` so the refusal can tell *invalid* from
*declared nothing*, so it should land in the onboarding state naming the key — and did not run it.
Read, not measured, and said so in the PR rather than left to be assumed from the measurements
around it.
