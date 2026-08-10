# 2026-08-10 — the fixture caught the coupling the review predicted

**Two adjacent job-log defects, quince#809 and quince#810, both in one fifteen-line function. The
review asked for one replay fixture carrying all three shapes so the fixes would see each other. It
repaid that inside the first PR, against its author — and then the second PR's own comment turned out
to assert something unmeasured, in the same class it was fixing.**

## What was wrong

A real 94,034-file iPad backup's stored log was **3,758 lines with about twelve informative ones**:
2,251 empty (60%), 735 `Receiving files` and 734 `Moving 128 files` (39%). The 256 KiB ring is a
fixed budget against an input that scales with the device, so the tail a reviewer opens the log for
is evicted by the noise.

Three causes, three different mechanisms:

- **empty tokens** — `scanFrames` splits on `\r` as well as `\n`, so adjacent redraws yield EMPTY
  tokens that were appended verbatim;
- **phase headers per protocol MESSAGE**, not per phase — so the run length scales with the device;
- **`[KMGT]?B` does not match `Bytes`**, the unit the tool writes for sub-KB figures, so every
  sub-KB frame missed the redraw filter and was logged at frame rate.

## The fixture earned itself in one PR

`noisy-joblog` carries all three shapes in one transcript. The first assertion written against it
said `Receiving files` appears twice. **It appeared four times.**

quince#809's leaked frames sit *between* otherwise-identical narration lines and **break the runs**
that quince#810's collapse would otherwise join. That is the coupling the review had predicted from
reading the code — arriving as a measurement, and stronger than the prediction: the review framed it
as one predicate serving two consumers, and this showed the two issues' **effects** interact even
where the code changes do not touch each other at all.

So the test asserts the **invariant** — no two adjacent identical lines — which survives quince#809
and whatever changes the frame mix next. An exact count would have gone stale within a PR and been
"fixed" by editing the number.

**And it left a self-flipping assertion for the next author**, pinning the `Bytes` frames as still
leaking with a message saying *"quince#809 is fixed, and this assertion is now the wrong way round:
flip it to require that it is DROPPED."* The next PR flipped it. That handoff worked exactly as
designed, across two pull requests.

## The predicate that answered two questions

`hasBytes` was read by the log filter *and* by the progress publisher — **named for what it MATCHED,
consumed by callers who wanted what it MEANT**. Widening the character class fixes the flood and
silently starts publishing per-file figures three orders of magnitude below the job total, inside
quince#808's open question about those numbers.

Splitting it — `sizeFrame` for the filter, `hasBytes` unchanged for the publisher — makes the fix a
strict no-op on the published figures. **There was a third reader neither the issue nor the review
had named**, an early return meaning *no progress change*; it stays on `hasBytes`, and the split is
only sound because all three were checked.

## The part worth keeping: I asserted a mechanism I had not run

The fix's own comment claimed the alternation order was load-bearing — that `[KMGT]?B|Bytes` would
match the bare `B`, leave `ytes`, fail the required `/`, and reproduce the bug inside its own fix —
and said **"measured both ways"** when it had not been.

**Measured: both orders pass.** Go's regexp keeps whichever branch lets the whole pattern match, so
a branch that cannot reach the `/` is discarded.

I caught it by running the mutation instead of trusting a comment I had written thirty seconds
earlier. **The correction produced a better test than the claim it replaced**: what actually matters
is that the unit is captured WHOLE, because `strings.EqualFold(m[2], "Bytes")` is the publishing
guard — a partial `B` capture would stop the flooding *and* start publishing, the exact combination
the split exists to prevent. The test was renamed from what it claimed to pin to what it does.

**The reviewer noted the symmetry without inflating it, and it is worth carrying:** three instances
of that shape in eight hours, by two seats — this one, an earlier review taking a `grep` claim as
measured, and an approval of a test name asserting an unmeasured fact. Same shape every time, caught
three different ways, and none of the three by re-reading.

## The other thing a fixture is for

Every fixture in the parser suite used `MB`. **A whole class of frame had never reached either
consumer in a test**, which is why the pattern was free to be wrong for as long as it was. There is
now a table per unit with two columns, and the columns differing on the `Bytes` rows *is* the fix.

## Not established

Only the receive-heavy shape is measured; an incremental has fewer batches and a different ratio. The
3,758-line count is another seat's, not mine, and the fixture is assembled from the shapes that log
exhibited rather than captured as one run — its meta says so. Which units the tool can actually emit
is still open: `Bytes` and `MB` are confirmed from real logs, `KB`/`GB`/`TB` are in `parseSize` and
unverified on the wire, which is why `TB` has no row. And quince#808 — whether those figures should be
per-message at all — is untouched by design.
