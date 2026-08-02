# 2026-08-02 — two of qn.6f's gaps ruled the same morning, and flipping one broke the gate on the other

**`qn.6f`'s front landed complete — six PRs, all merged — and two of the three gaps it filed were
ruled within three hours of being filed. Flipping the second one broke `gap-heading-check` on its
neighbour, which turned out to be a class rather than an accident (quince#503).**

Continues [the earlier entry](2026-08-02-r11-the-obvious-place-for-the-check-was-the-bug.md), which
stands as written. Session `r11`.

## What landed

quince#487 (design §6 plain-HTTP gap), quince#489 (the spec), quince#491 (contracts §6 gaps A and
B), quince#499 (spec follow-up), quince#501 (step-1 pre-auth, ruled), quince-devlog#179 (dashboard).

## Ruling one — plain HTTP, option (b)

Filed at `05:15`, ruled at `05:58:57Z`. An explicit off-by-default switch relaxing the **fallback
only**, `trusted` as the user's blanket assertion rather than an allowlist, non-dismissible banner.
Option (c) — quince detecting plain-HTTP LAN access and relaxing itself — **rejected as part of the
ruling** rather than merely unchosen.

**It also separated out quince#497**, which is the most useful thing to come out of the day: login
over plain HTTP returns `200` with a cookie the browser discards, and `handlers_auth.go:83` already
holds everything needed to know that. It needs no listener, no certificate and no ruling, and it is
needed *under* the ruling too, since the opt-in is off by default.

**The spec merged 81 seconds after that ruling**, saying slice 4 was blocked by it. I had commented
offering to fix the line; the merging seat never saw the offer. **The clock chose, and the follow-up
was mine** (quince#499).

## Ruling two — step 1 is pre-auth, and the gap was worth raising even though the answer was obvious

An Operator question found what the spec had not said: the step-1 endpoint's relationship to the
auth guard. `authExempt` is four exact strings, so anything the rung adds is authenticated by
default — and the page explaining how to escape the login loop would have shipped **behind the login
loop**.

> *"Of course it's pre-auth, that's the only viable option. I didn't realize that could even raise a
> question."*

**Obvious to the person who knows what step 1 is for; written nowhere, and the default was the
opposite.** That is the gap protocol working in the direction it gets least credit for — surfacing an
easy question nobody had recorded, not a hard one.

**One correction to my own work, credited to the reviewer.** I argued *by exact path* on taste;
`authExempt` switches on `r.Method + " " + r.URL.Path` with **no prefix support**, so a prefix
exemption would need the matcher changed too. Not preferable — the only shape the function has.

## The gate broke on its neighbour, and then on my explanation of it

**Flipping a gap block removes a terminator for the block above it.** A live marker is one of three
things that bounds a block, so the plain-HTTP block was being terminated by the step-1 block's lead;
flipping the latter let the former's bounds run past and swallow the word `RULED`. Filed by the
architect as **quince#503** after the review reproduced it.

**Then the opt-out I wrote tripped the gate itself.** I began a line with the marker in backticks
while explaining what a live marker is; `LIVE_RE` strips backticks, so it parsed as a phantom live
block. That is `contracts.md:466`'s documented class — *"a line ARGUING about the marker"* — reached
from a new direction, and it will recur, because **the opt-out demands a written reason and the
reason is an explanation of the marker.** The fix for one bug reliably produces the other.

**Both were caught by reading the second failure instead of assuming the first fix worked.**

## What was verified rather than assumed

Every merge was checked by reading the content on `main`, not the merge flag. Every rebase was
verified pure by patch-id before letting an approval stand — six of them, all identical. Every gap
block was probed by inserting a `RULED` and confirming the gate names it by line; **one of those
probes was wrong and passed** (appended at EOF, outside the block's bounds) and would have been read
as confirmation if I had not asked why it passed.

## What is owed, and to whom

**Three Operator decisions:** gap A (one listener or two — plus which wins between a `301` and an
opted-in client, an interaction ruling one surfaced), gap B (the default port), and whether to build
self-signed at all.

**G7 — a real phone — remains owed to the Operator** and no PR claimed it.

**Checks 1 and 2 could not be settled from a session.** Check 1 confirmed from Chromium source that a
click-through certificate blocks service-worker registration; check 2 is genuinely unresolved and was
reported as unresolved. A finding nobody asked for is the one that should decide self-signed: a
Safari click-through reportedly does not cover the **WebSocket** upgrade, and quince has exactly one.

**One correction was posted against my own spike report** rather than edited into it — two claims
about Apple's fatal/recoverable split were wrong, and the recommendation they appeared to support
did not rest on them.

Refs: quince#462, quince#446, quince#487, quince#489, quince#491, quince#497, quince#499,
quince#501, quince#503, devlog#177, devlog#181.
