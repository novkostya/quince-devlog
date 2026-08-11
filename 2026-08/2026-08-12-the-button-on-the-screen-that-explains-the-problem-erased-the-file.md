# 2026-08-12 — the button on the screen that explains the problem erased the file

**Scoping a copy fix, I measured what happens if the operator does what the screen tells them. One
`POST /api/config/storage` — the button on the first-run page — returned `200` and replaced their
`config.yml`. The zfs storage, its parent dataset and its hook command were gone, there was no undo,
and `warnings` came back `[]` so every surface afterwards reported health.**

## How it was reached, because the route matters more than the bug

Three steps, none of which was the work as handed over:

1. [quince#817](https://github.com/novkostya/quince/issues/817) asked whether a daemon meeting an
   invalid config behaves as the source reads like. **It does — every step.** A clean pass.
2. The architect's review had added one line to the confirms: *check the warning is **surfaced**, not
   merely present.* That question came back **no**, and became
   [quince#849](https://github.com/novkostya/quince/issues/849) — the operator is told they have no
   storage while their file declares one.
3. Scoping *that* meant asking what the screen's button does. **Which is when the file went.**

Each step was a question about the previous answer rather than about the code. The bug lives one
layer above where anybody was looking, and no step of it was suspected.

## What it is

`Load` cannot validate the file, so it returns `OK: false` with `Config: Default()`. `AddStorage`
splices into `Current()` — which is therefore *defaults, with no storage*. The operator's declaration
was **never in the document being written**; it only ever existed in the file that got replaced.

`NewService` had `Loaded.OK` in hand, logged it, and kept neither it nor the errors. So the
distinction [quince#508](https://github.com/novkostya/quince/issues/508) built — *parse failure*
versus *declared nothing* — reached the log and stopped there, and the one path that needed it to
decide whether a write was safe could not ask.

## The ruling, and the argument that carried it

Operator, 2026-08-12: **refuse the write.** Not a preserve-through-splice, not a UI confirmation.

**The deciding argument is about callers that do not exist yet.** A confirmation dialog is a guard on
the browser; `curl` walks around it and the destructive path stays reachable by everything that is
not the UI. Preserving the unparseable entries would have quince write back keys its own loader could
not validate — and produce a file that can be rewritten while containing something the daemon refuses
to start on.

[quince#857](https://github.com/novkostya/quince/pull/857) is that refusal: a `422` naming the
offending config path, its message, the file, and a remedy that includes the restart — because there
is no reload path, so *"edit the file"* alone would leave the operator pressing the same button again.

**`DISCARDED` is not `HAS WARNINGS`, and that was the one place I read the ruling narrowly.** A file
that parses with warnings keeps its `Storage`, so a splice over it loses nothing; refusing on any
warning would decline safe writes on a config quince is happy to run. Both sides are pinned by a test.

## The part worth keeping

**Every existing `config.AddStorage` unit test seeds a valid config.** Not one was ever in this state
— so the endpoint was thoroughly covered and the hazard was structurally invisible to all of it. That
is `qn.6e`'s lesson arriving again on the same endpoint: *"six green unit tests covered that endpoint;
every one of them seeded a storage first, so none added the first."*

The fix is gated end to end for that reason, in the smoke arm
[quince#850](https://github.com/novkostya/quince/pull/850) added hours earlier — a real container, a
real discarded config, and the exact `POST` that destroyed the file.

## What it changes beyond itself

[quince#818](https://github.com/novkostya/quince/issues/818) retires `hook_cmd` with the same refusal
shape, so **every existing zfs install's config becomes invalid on upgrade** and its operator meets
this screen. Today the state takes a hand-edit to reach; after that rung it is what a working install
does when it is updated — and the population is exactly the one with a zfs storage, which is the only
kind this destroyed. The rung is in `v0.1` and is now parked on this fix.

## And it is not finished

quince#849 — the screen itself — is stopped, one question short: **the client cannot tell a discarded
config from one that merely carries warnings**, because `configResponse` serves `warnings` and not
`Errors`. The ruled copy has to invert between those two states, and the bit that decides it is not on
the wire. Asked rather than hedged; a headline saying *"there may be a problem"* is the state-honesty
defect the issue exists to remove.
