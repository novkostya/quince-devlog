# 2026-08-19 — the muxer reshape is built, and the last slice was decided by the config WRITER rather than the reader

**quince#1219 is complete: D and E merged, A+B+C approved and waiting on the code owner. The slice
that looked like a schema change turned out to be decided by something else entirely — how
`config.yml` is WRITTEN, not how it is read.**

## The ladder

| | | |
| --- | --- | --- |
| **D** | device ops route to the muxer that REPORTED the device | quince#1232, merged |
| **E** | a health entry is an `address` and what it is SERVING | quince#1242, merged |
| **A+B+C** | `muxers:` replaces `devices:` | quince#1246, approved, code owner |
| **F** | applying a `muxers:` change without a restart | filed, unscheduled, NOT a v0.1 gate |

## What the last slice actually turned on

The schema was the easy half and was fully ruled before a line was written. What was not ruled, and
could not have been foreseen from the issue, is that **`muxers:` is the first section in this config
whose DEFAULT is a non-empty list** — and `MarshalDeclared` keeps a non-empty sequence even when
nothing declared it.

That rule is deliberate and its comment says why: without it, a fresh install's first save deletes
the storage list it was just given. But it means a default entry in `Default()` is **written into
every `config.yml` as a key nobody set**, which is precisely what D12's headline forbids. The
measured symptom was quince warning that it had had to write the **long form** of the file.

The fix is the shape `storage:` already had — a pointer, so absent and `[]` stay distinguishable —
plus the half `storage:` never needed: **the default must not live in `Default()` at all.** It lives
in `ResolvedMuxers()`, at the point of use. `storage:` never faced this because its default list is
empty, so nothing was ever there to be written.

**A second one from the same machinery.** Declared paths key list entries by `name`, else `path`.
A muxer has neither, so every entry keyed as `muxers[].`, they all collided, and the pruner could
not tell which entry had declared what. `entryKey` gained `address` as a third identity — the same
ruling item E applied to health, arriving in a completely different file.

## The near-miss

The first draft replaced `dialerLookup` — a NAMED function — with an inline closure in `live.go`.
It compiled, and it would have silently deleted the guard the architect required in quince#1060: a
nil `*muxd.Client` in a non-nil interface slips past muxsup's `dialer == nil` check and turns a
wiring bug that `status()` is careful to REPORT into a panic, at the moment somebody opens
`/api/health` to find out what is wrong. **The test would have gone with it**, because it takes the
function by name.

Caught by reading the file being edited rather than by any gate. Worth recording because "inline the
one-line closure" reads as cleanup in a diff, and the comment above it said exactly why it must not
be — which is the argument for writing that comment in the first place.

## What was deleted, and the sentence that justified it

`plannedMuxers`' managed arm is gone **because it can no longer be written down**: a supervised
daemon needs a NAME to know whether it is `usbmuxd -f -S` or `netmuxd --host/--port --disable-usb`,
and the ruled schema has `address` and `type` and no `daemon:`. It got that name from *which config
key the address came out of* — the same assumption item E deleted from health, discovered a second
time one layer down. The supervision itself, and its hardware-proven tests, are untouched.

## Three PRs, three Operator approvals, and the prediction that was wrong

Every slice needed the code owner, because each changed something `docs/quince.design.md` asserts.
**I predicted A+B+C would not** — the ruling deliberately put its canon in `docs/contracts.md`,
which is not in `CODEOWNERS` — and it did, because design.md named `devices.manage_muxer` in two
places and leaving canon asserting a key that no longer exists is worse than avoiding a gate.

The prediction was reasonable and the outcome was better; recording both, because the useful lesson
is that *which file carries the ruling* does not decide *which files the change makes false*.
