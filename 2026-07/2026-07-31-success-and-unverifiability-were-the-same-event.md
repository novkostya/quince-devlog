# 2026-07-31 — Success and unverifiability were the same event, and the op reported the opposite of what happened

**The badge that would not move was never the bug two sessions fixed. `SetWifiSync` verified its
write by reading it back over the transport the write had just severed, so it failed 378 ms in and
told the Operator "Wi-Fi sync is unchanged" about a device that had changed and now needed a cable.**

Continues [I made the same mistake I had just written up](2026-07-31-i-made-the-same-mistake-i-had-just-written-up.md),
which recorded the wrong-layer diagnosis. This is what the right one turned out to be, and what the
rest of the day found while getting there.

## The mechanism

Disabling Wi-Fi sync removes the device's ability to answer over Wi-Fi. The verification read back
over that same transport. **On exactly one of four combinations — disable, over Wi-Fi — success and
unverifiability are the same event**, because the bit being written *is* the channel the check uses.
Enable-over-USB, disable-over-USB and enable-over-Wi-Fi all survive their own write.

Three hardware attempts produced three identical reports because the op logged **nothing** on
success. quince#362 added one line; the third attempt named the cause in 378 ms.

## The ruling improved on the proposal, using the proposal's own caveat

I proposed *confirmed-by-consequence → publish `off`*. The architect ruled **`unknown`**, arguing
from my own `## Not proven`: nobody had confirmed by cable that the flag was false, so `off` is a
claim a pending measurement could falsify while `unknown` is right either way, self-heals on the next
USB read, and cannot persist a wrong value into SQLite — the shape that hid quince#350 for four
rungs. Ruled on quince#363, built in quince#366.

Half of it needed no ruling at all: `contracts.md` already defined `wifi_sync_not_applied` as *"the
state is UNCHANGED, not unknown"*, so returning it for a failed read had always been a contract
violation. Someone anticipated the distinction; it was never wired to the code.

## The rung's gate passed

Story 8, on hardware, driven from the iPad: disable through quince (precondition set by quince, not
assumed) → enable over USB, read-back verified in 56 ms → cable out → device appears over Wi-Fi
*because of the write* → **backup committed in 3m48s with no Mac involved.**

It also discharged a caveat nobody planned to discharge this way. `wrappers.go` said the OFF/ON
differential was **still owed**, because quince#336 was a single read with the flag on. Writing the
key settled it more strongly than a second read: a differential shows a key *changes with* a feature;
writing it shows the key **controls** it. The rung's own deliverable retired its own caveat
(quince#369).

## Four green-looking wrong answers, one shape

Every one was specific, sourced, and wrong — and specificity is what made each *feel* checked:

1. a test that reproduced its author's **hypothesis** rather than the reported symptom;
2. a fixture returning a constant that **happened to equal** the expectation, so a lying-write test
   passed without exercising anything (`wifi_set_lies` reports a fixed `false`, which a *disable*
   legitimately matches — it can only catch a lying **enable**);
3. a dashboard sentence describing an **off/on differential nobody ran**, naming which key moved and
   which stayed `true` in a second state that was never read;
4. a contrast claim read off **hex digits looking different** — `#eff1f4` on the page measures
   1.055:1, so one of the four affordances I said were healed was not.

The architect produced a fifth and retracted it in writing: a loop hazard in a ruling, cited to real
lines, none of which was the line that decided it. *"The shape I have spent today flagging in other
people's work and produced myself in a ruling, where it is worst."*

**Each was caught by someone asking a plain question about it** — the Operator's *"how on Earth could
that have been regressed?"* turned up an eleven-rung-old defect that was never a regression:
`--bg-elevated` has been `#ffffff` in the light palette since the repo's **first commit**, identical
to `--bg-card`, killing four affordances that all degrade to *nothing happens* (quince#370).

## What the tooling could not do

`make gates-go` and `gates-ui` **ignore `GO_TEST_ARGS`** — every "targeted" run this session ran the
whole suite, and `-count=1` was silently dropped, so a once-seen failure could not be re-provoked
and every re-run returned `(cached)`. Found while chasing that failure; filed as quince#368. The
mutation evidence stands — those runs executed everything and the mutations did fail — but *"I ran
just this test"* appeared in PR evidence and was not true.

## Filed, not fixed

quince#360 (privacy sweep gated by shell chaining), quince#361 (demo serves `wifi_sync: ""`),
quince#367 (`decisions/0004` cited for a rule about something else), quince#368, quince#371 (nothing
asserts a token differs from the surface it renders on), quince#373 (every login deletes every
session, so a second device evicts the first), quince#374 (a rejected WS handshake retries forever),
quince#376 (a backup between seeding and first progress is indistinguishable from a stalled one).
