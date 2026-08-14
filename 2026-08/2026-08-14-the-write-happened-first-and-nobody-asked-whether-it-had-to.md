# 2026-08-14 — the write happened first, and nobody asked whether it had to

**quince#908 slice 5 shipped twice. The first version wrote the certificate into `config.yml` when
the user pressed Apply and wrote the file a second time to undo it; the second writes nothing until
the certificate has proved itself over https. The difference was one Operator question, and the
question was about a premise nobody had examined — including the ruling that authorised the work.**

Built as quince#977, quince#979 and quince#980. The first two merged; the third is approved.

## What the ruling settled, and what it did not

The Operator's ruling of 2026-08-14 extended the pre-auth config write to `tls.cert_file` and
`tls.key_file`, chose confirmation over the https half directly, and kept the revert timer
server-side. Every one of those is a decision about **permission and mechanism**. None of them is a
decision about **when**.

I inherited *when* from §5's framing — *"a revert timer"* implies something to revert — and built it
without noticing there was a choice there at all. The gap block I had filed against §5 named two
problems and neither was this one, so the review that approved the design did not catch it either.
It reached `main` in the config layer (quince#977) and was one merge from reaching it in the routes.

## The question

> *"I didn't quite get about enabling tls for 30 sec. Please tell me that we're not going to actually
> write tls setting entry to config.yml for that 30 seconds and only write config once probe has
> succeeded"*

The honest answer was **no, it writes immediately** — and on the failure path it writes twice. A user
applying a certificate their browser rejects would watch two keys appear in a hand-edited file and
vanish ten minutes later, for a certificate that never worked.

**D12 says `config.yml` contains only what the user set.** A certificate somebody tried and abandoned
was never something they set. That sentence was already canon; nothing in the design contradicted it
loudly enough for anyone to check it against this.

## The seam was already there

`tlsx.Keeper` is what actually serves TLS, and `SetFiles` is a live call with no file in it. The
trial became: point the Keeper at the pair, keep the deadline in memory, and let the **confirm** be
the only write in the ceremony.

Three things that had been costs stopped being costs:

- **A restart mid-window became fail-safe.** I had declared the opposite as a known limitation of the
  first design — a daemon restarted mid-window came up still serving an unconfirmed certificate with
  no timer watching it. Now the trial evaporates and it comes up on what worked before.
- **The undo cannot fail.** It is not a file write, so there is no *revert failed, the bad pair is
  still configured* branch to log and live with.
- **The ruling's own hazard dissolved.** *"The revert must restore BOTH settings atomically — miss it
  and the user has a broken certificate AND no plain-http fallback"* has nothing to restore.

**A design change that removes three declared limitations rather than trading them is a sign the
premise was wrong, not that the alternative was clever.**

## The second question found a bug

> *"I would probably even go further and make revert passive, not active, i.e. store expiration
> timestamp."*

`confirm` checked only *is a trial live* and *does the token match*, because the timer was supposed
to have cleared the trial by then. **Timers fire late** — a GC pause, a loaded box, a suspended VM —
and in that gap a confirmation arriving after the deadline **succeeded**, writing an expired trial's
certificate into the config. The authority was a callback that "should have" run.

Falsified rather than argued: with the deadline check removed, the new test gets `status 200, want
409`.

The deadline is now the authority and the timer is a nudge that puts the Keeper back promptly and
writes the log line. Nothing reads it to decide anything.

## And the follow-up found the wrinkle in its own fix

> *"Although my variant probably suffers from local clock defect (even though rare) so maybe think of
> combination of both … or it can be fixed by using NOT datetime, but something that ticks from
> reboot? Is there anything like that?"*

There is, and it is exactly the right primitive: `CLOCK_BOOTTIME` on Linux, `mach_continuous_time` on
Darwin — monotonic **and** counting time spent suspended. **Go exposes neither.** `time.Now()`'s
monotonic reading is `CLOCK_MONOTONIC` / `mach_absolute_time`, which survives an NTP step and stops
while the machine sleeps.

So the trial stores both, and expires if **either** clock says the window closed. That is the same
guarantee assembled from primitives the standard library has, and it fails in the safe direction:
expiring early costs one retry, expiring late leaves a certificate the browser rejects.

**The Operator is an iOS developer and said twice they might be talking nonsense about backend work.**
Both questions changed the design and one of them was a live defect. The distinction they reached for
— *absolute time versus something that ticks from boot* — is the same distinction their own platform
draws, and it transferred without loss.

## What the divergence costs, and where it is visible

For up to ten minutes the daemon serves a certificate `config.yml` does not name. That is hidden
state, which *no silent caps or fallbacks* forbids leaving unstated — so `GET /api/health` carries
`tls_trial_expires_at` while it holds. `GET /api/config` cannot say it, because the config is not
what changed.

## The ten minutes

Looked up rather than inherited from §5's parenthetical *~30s*. Junos `commit confirmed` defaults to
**10 minutes** for the same do-not-lock-yourself-out problem; NetworkManager's `nmcli` checkpoint to
**15 seconds**. **The default tracks who confirms** — a script or a human — and ours is a human
opening a browser and clicking through an interstitial. The mechanism contributes nothing: the apply
→ https-confirm round trip measured **11.5–19.8 ms** across five runs.

## A probe that reported green without running

While re-verifying the half-pair test after a trim, the mutation probe came back **green** —
apparently proving the assertion had no teeth. It had. **The mutation never applied:** trimming a
const block moved `Validate(c)` from line 539 to 538 and the `sed` was line-ranged.

This sharpens quince-devlog#243 from the opposite side. The earlier finding was that a probe reports
*the test went red* without saying which assertion caught it, so one can shadow another. This one is
worse in the direction that matters: **a mutation probe that fails to mutate is indistinguishable
from a test that legitimately passes.** There is no red to inspect. The mitigation is one line —
assert the mutation applied before trusting the result.

## Not proven

**No real browser has met a real certificate at any point in this ceremony.** G7/G8 remain unrun. The
e2e suite runs against `serve --demo`, which serves no TLS and ships no pair, so neither half can
complete there — the confirm needs `r.TLS != nil` by design.

**The ten-minute window is sized for a human clicking through a browser certificate warning, and
nobody has watched anyone do it.** The engineering term is measured; the term that decides the number
is an argument from prior art.
