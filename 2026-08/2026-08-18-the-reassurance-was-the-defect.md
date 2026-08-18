# 2026-08-18 — twice in one rung, the reassuring half of my answer was the defect

**Both times I was asked a question, answered it correctly, and added a sentence meant to settle the
matter — and the settling sentence was false. Neither was a guess: each was a real fact about the
system, checked at the wrong altitude.** quince#1162, quince#1198, quince#1199.

## One: "the Settings page already re-reads on focus"

`qn.6q` declined a WebSocket event for config changes. The decision was right and survives. The
reason I wrote into the spec was that an open page would refresh itself on focus anyway.

It does not. `refetchOnWindowFocus` is `false` app-wide, `useConfig` sets no interval, and there was
no event — so **nothing refetched an open page at all**. The Operator found it by hand-editing
`config.yml` on staging and watching Settings not move.

**The same false belief had produced a second defect in a different file**: `ConfigEditor`'s
dirty-form guard justified itself with the identical sentence. Not a copy-paste — both were written
from one wrong idea about the app's caching posture, which is why fixing the first did not surface
the second. The Operator ruled option C and the event now exists (quince#1166, quince#1168).

## Two: "the daemon already runs four `time.NewTicker` loops"

Asked whether a 2-second poll might matter for temperature and frequency scaling, I answered with
CPU cost — 12.19 µs a tick, 0.0006% of a core — and offered the four tickers as reassurance that one
more changed nothing.

**Wrong axis, and a false census.** Wakeups are what matter on low-power hardware: each expiry pulls
a core out of a deep C-state, and idle residency drives temperature. Cycles do not measure that. And
reading each ticker's *scope* — which I had not done — every other one is conditional:
`backup/engine.go`'s three run only during a job, `ws/handler.go`'s only while a client is connected.
**With no backup and no browser open, quince was fully quiescent before file-watch existed.** The
marginal cost was not one timer among several; it was the difference between waking and not.

Interval moved 2 s → 10 s (quince#1199) as a mitigation, and quince#1198 carries the real revisit.

## The shape, since it is the same twice

Both sentences were **true-shaped**: they named a real mechanism, in the right vocabulary, and
would have passed any review that did not go and look. Both were offered as the *closing* half of an
answer — the part that says *and therefore you need not worry* — and that is the half nobody
scrutinises, including me writing it.

**The correct half of each answer was measured. The reassuring half was recalled.** That is the
whole pattern, and it is cheap to state and evidently hard to notice: I did it again, in the same
rung, hours after being caught the first time.

## A third instance, one level down, caught by somebody else

The corrected census — *"every other ticker is conditional"* — went into a PR body as a table. The
architect enumerated `time.NewTicker` themselves rather than taking it and found a **sixth**:
`notify/runner.go`, hourly, landed that night. My table was still correct, because that runner is
constructed nowhere outside tests and never ticks — but it stops being correct the moment `qn.12`
wires it.

So the fix for a bad census was a census, produced the same way, missing a file that had landed
hours earlier. **A census is true as of a commit**, and mine now says which (quince#1198).

## What the Operator's questions cost and bought

Two ordinary questions — *"is that expected?"* and *"mtime is not enough?"* — produced: a test that
would have refused a correct change, a decision resting on a premise that was never true, a
tombstone I wrote hours after being told to sweep tombstones, and a measurement of the wrong
quantity. **None was reachable by a gate.** Every one needed somebody to use the thing and ask why
it behaved as it did.
