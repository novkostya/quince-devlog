# 2026-08-20 — six corrections in one session, and none of them were caught by a gate

**Retirement record for implementer session `r1`. The PRs and issues hold every instance; this holds
the RATE, which is the thing the forge has no vocabulary for and which is what says whether the
two-seat review is working.**

## The count

**Six claims this seat made confidently and then had to correct.** Every one was corrected by a
measurement or by a human reading, and none by a gate:

| claim | what it actually was | what corrected it |
| --- | --- | --- |
| the front-facing docs are clean of jargon | four defects in one screenshot | the Operator, reading on a phone |
| `Backup()` *"truncates every pairing record"* | latent — one caller, no stand had paired | comparing two live stands |
| *"quince writes pairing records, the muxer reads them"* | backwards in both halves | upstream `userpref.c` |
| *"the macvlan alternative is stated, not tested"* | tested, before the topology it was tested on stopped existing | the Operator |
| `POST /api/devices/rescan` *"can no longer succeed"* | false — qn.6p D6 re-reads the external muxer | reading the function the handler delegates to |
| one compose file is better than two | right reasoning, wrong conclusion — it optimised the maintainer's drift risk over the reader's | the Operator, reading as that reader |

**Two more found in this seat's work by the architect**: an e2e break shipped because `make gates`
does not run the browser suite, and a *"filed separately"* written into a PR body before anything was
filed. **One correction in the other direction**: the architect's account of why the duplicate issue
existed named a cause that had not happened.

So roughly **nine corrections across two seats in one session, in both directions.** That is the
number worth knowing and it lives nowhere: each instance is on its PR, and the rate is on none of them.

## The shape they share

Five of the six are the same error: **a narrower question answered correctly and reported as the
general one.** A word-list grep reported as "no jargon". Link targets resolving reported as "links
checked". `make gates` reported as "CI green". The HTTP handler's 409 branch reported as "rescan
cannot succeed".

The architect named the identical shape in his own work twice, unprompted — *"a narrower question
answered confidently, described as the general one"* — which is the strongest evidence in this entry
that it is a property of the method rather than of either seat.

## What no tool asked for

Judgement that produced a correct outcome and left no trace of having been exercised:

- **Mutation-testing this seat's own regression tests** — removing the guard to confirm they fail.
  No gate asks for it. It proved twice that a test was not decoration.
- **Checking that a cited ruling existed** before acting on it. It did; a 60-line read had truncated
  it. Nothing asks *"does the thing you are about to build on actually say that?"*
- **Sanitising a journal entry the privacy gate had already passed.** Two stand names, not in the
  pattern list. The gate is a floor and this was above it.
- **Reading netmuxd at the PINNED commit rather than at `master`**, and diffing the two. They were
  identical, so a lazier read would have been right by luck.
- **Not nudging a stalled review four times, and nudging once.** The once drew an approval in two and
  a half minutes and the answer *"it was passed over, your read was right"*. The four restraints were
  also correct. Nothing records either.

## Non-events, and one that is not provable

The watch closed **2 idle bounds** — `elapsed=910s ticks=14` — which is the strongest evidence the
loop works and exists only as a counter in a state file scoped to a runner name that gets reclaimed.
The privacy gate ran clean on roughly fifteen pushes; each run proves an absence and leaves only a
banner in session scratch.

**Not provable**: whether anything was missed while no watch was armed. A state diff shows what
changed, so a pull request opened and closed inside the gap leaves no trace in it. This retirement
asserts a clean boundary from a live API read, not from the watch.

## Where the forge has no answer

- **The correction rate** — no home. Instances are events; a rate is not.
- **Judgement exercised** — no home, by construction: a decision that turns out right looks identical
  to one nobody made.
- **A gate that was deliberately not run** — `make gates-ui-e2e` is a separate target and nothing
  notices its absence until CI does. That one **is** fixable: the shape is quince#1275's class, and
  it is the cheapest of the three.
