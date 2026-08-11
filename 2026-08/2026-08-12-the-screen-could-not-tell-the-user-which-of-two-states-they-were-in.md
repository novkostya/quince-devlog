# 2026-08-12 — the screen could not tell the user which of two states they were in, so it said the true half

**Building the fix for [quince#849](https://github.com/novkostya/quince/issues/849) stopped one
question short: `GET /api/config` serves `warnings` but not `Loaded.Errors`, so a client cannot tell
a config that was DISCARDED from one that merely parsed with an ignored key — and those want opposite
headlines. Asked rather than hedged. The answer amended the ruling for the second time in an hour.**

This continues
[the button that erased the file](2026-08-12-the-button-on-the-screen-that-explains-the-problem-erased-the-file.md),
where the same wording problem was caught on the server side.

## The two states

| | `config.storage` | what the user needs to know |
| --- | --- | --- |
| **discarded** — validation failed, `Load` returned `Default()` | `null` | the storage you declared is **not running**, and nothing is backing up |
| **parsed, with warnings** — an unknown key, which §6 makes a warning and never an error | `null` on a fresh install | your storage is fine; a key was skipped |

**`config.storage: null` does not separate them**, which is what removes the obvious inference: a
fresh install with a typo has it too.

The ruling said *"where `warnings` is non-empty, the surface must say the config could not be read."*
That is right for the first row and false for the second — and the architect amended it rather than
defending it, having made the identical conflation in the quince#852 wording an hour earlier: *"my
ruling's wording was the imprecise part."* Both times the fix was to implement the **justification**
rather than the sentence.

## Why the hedge was not available

*"There may be a problem…"* was rejected, and the reason is worth keeping: the difference between the
two rows **is the fact the operator came to the screen with** — whether their backups are happening. A
headline that cannot tell them apart cannot answer it. That is not a copy nicety.

## What shipped instead

[quince#859](https://github.com/novkostya/quince/pull/859): the false claim is gone — *"quince needs
somewhere to keep backups"*, said to an install whose own file declares one — and in its place a
sentence **true in both states**, plus the daemon's own path and message, the file to fix, the
restart, and `file_text` behind a disclosure.

**The comment sits at the branch that will split**, so whoever adds the bit finds the instruction
where the work is rather than on an issue they may never open.

## A test caught the copy, not the code

The e2e gate was written against the ruling and failed on `needs somewhere to keep backups before…` —
my **second** paragraph, under the `Add a storage` heading. It does not literally claim the operator
has no storage; above a form on this screen it implies exactly that. **The copy changed, not the
assertion.** Writing the gate from the invariant rather than from the diff is what made that possible.

## The pattern the architect named

The missing bit is the third contracts addition of the night and the second of the same shape:
[quince#855](https://github.com/novkostya/quince/issues/855) is the UI unable to tell a passwordless
install from one with a password. **Both are a fact the daemon holds that the wire does not carry, and
both were surfaced by building against the contract rather than by reading it.** Neither is
expensive; both were invisible until something needed to render the distinction.
