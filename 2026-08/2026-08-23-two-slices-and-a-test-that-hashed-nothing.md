# 2026-08-23 — Two slices, a test that hashed nothing, and a question answered by measuring instead of ruling

**`qn.10` slices 2a and 2b landed the night the rung opened. The most useful thing either produced
was not code: it was a test asserting the project's hardest invariant that was passing without
checking anything, and a design question that looked like it needed a ruling and turned out to need
a measurement.**

## What landed

**2a — `msgfixture`** (quince#1496). Fixtures built at test time rather than committed as `.sms.db`
binaries. That is the house pattern already, and on this rung it buys something specific: the domain
models personal message content, so generating fixtures means **there is no blob in git to inspect
for leakage at all.** The privacy obligation becomes *read this code*. The reviewer did exactly
that, and noted the invented cast uses the reserved 555-0100 block and an RFC 2606 `.invalid` TLD.

**2b — the domain reader** (quince#1497). One scan into a session-scoped SQLite projection, because
the parser has no per-chat filter and no cursor, so a thread page costs the whole table per page.
Measured through the shipped code on the real backup:

| | | |
| --- | --- | --- |
| `Available` | 808 ms | projection **absent** |
| `Chats` | 23 ms, 390 conversations | projection **absent** |
| first `Thread` | 15.5 s — builds it, 57.5 MiB | |
| full thread walk | 55 ms | 37 pages, 7,256 messages |

The two absences are the lazy ruling holding on real data, and the trigger came out finer than the
spec had it: `Chats()` is answerable live, so the **first** Messages screen costs nothing and the
build waits for someone to open an actual conversation.

## The test that hashed nothing

2a's G5 asserts the project's hardest invariant mechanically: hash every file in the backup tree,
open the domain through the real `parserfs` (which replays a live `-wal`, a write), hash again. Any
difference is *never mutate a committed version* being broken.

It was written as `sha256.New().Sum(b)[:8]`. **`Sum` appends to its argument**, so that expression
returns the empty hash appended to `b` — and `[:8]` takes **`b`'s own first eight bytes**. It
compared file prefixes. It would have missed any mutation past byte 8 of any file.

**It passed.** It was caught by re-reading, not by the suite.

The fix was `sha256.Sum256(b)`, and then the part worth recording: the test was **deliberately made
to fail**, twice — append one byte to a backup file after the read, and add a stray file — before
the probe was removed. Both branches reported correctly; the no-probe control stayed green.

**A test that has never failed is a claim, not a check**, and this one asserted the invariant the
whole storage design rests on. The same session had written three separate paragraphs about
measuring the wrong thing before making the mistake in its own assertion.

## The question that wanted a measurement, not a ruling

Slice 3 wires the reader behind an HTTP route, and the house pattern for per-session derived state
wraps the build in `registry.With` — which is **exclusive and non-blocking**: `TryLock`, else
`ErrSessionBusy`. Following it literally would make the session busy for the whole 15.5 s build:
a concurrent browse, a file download, and the user's own second click, all refused.

That reads like a trade-off needing an Operator: honest refusal on a shipped surface versus a
longer wait. It was parked as one.

**It was not a trade-off.** Holding the vault only for `Materialize` and scanning outside it makes
the busy window ~1.1 s instead of ~16 s, and buys up nothing in exchange:

| arm | build | concurrent vault calls |
| --- | --- | --- |
| build inside `With` | 16.331 s | **ok=0, BUSY=808** |
| materialize only inside `With` | 1.118 s + 12.144 s | **ok=531**, BUSY=56 |

The first arm is the control, and it is what makes the second a result rather than a probe that was
never testing anything.

**The safety of the second arm rested on an inference**, and that is the part that needed checking
rather than the speed. `parserfs` memoises materialized paths; if the memo missed, the build would
reach the vault *outside* the lock while another goroutine used it — a race, and **a race need not
produce an error**, so "it ran without failing" would not have been evidence. Measured directly:
`Materialize` #1 806 ms, #2 **1 µs**, identical path. A miss would re-decrypt 446 MiB and, because
each copy carries its own sequence number, return a different path.

**One of the three checks in that probe was broken.** The count of "materialized copies in scratch"
used a filter that matched the decrypted `Manifest.db` and never looked at the materialized `sms.db`
at all. It printed a reassuring `1`. Named rather than quietly dropped, because a check that
measures the wrong object while reading as confirmation is the exact defect the rest of this entry
is about — and it appeared inside the probe written to avoid it.

## The shape, stated once

Three times in one session the same error: **measuring a component and reporting it as the whole.**
A row count extrapolated from synthetic rows a quarter the real size. A build cost that counted the
scan and not the write. A hash that hashed nothing. Each was a real measurement of a real thing, and
each answered a narrower question than the one being claimed — and in every case the narrower answer
flattered the design.

The habit that caught all three was the same and it is cheap: **make the check fail on purpose
before trusting it green.**
