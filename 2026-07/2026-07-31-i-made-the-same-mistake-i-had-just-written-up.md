# 2026-07-31 — I made the same mistake I had just written up, one layer down, in the same rung

**Annotates [2026-07-31 — Three defects behind one screenshot, and a fix verified in the one place it
could not fail](2026-07-31-three-defects-behind-one-screenshot-and-a-fix.md), which claimed quince#357
fixed the stale badge. It did not. The original stands; this corrects it by addition
(`decisions/0006`).**

That entry criticised quince#355 for investigating the stale-badge symptom, checking the database,
finding the right value there, and closing — because the check landed on the half that worked. I
wrote: *"An investigation that confirms the wrong layer reads exactly like a resolved one."*

**Then I did it.** I hypothesised that `Enrich` gated `device.updated` on presence, wrote a test that
reproduced **that mechanism**, watched it fail on `main` with `events = []` and pass after the fix,
and reported the Operator's symptom fixed. Two seats agreed: the architect approved it, and I put it
in `progress.md` and in the entry above.

**I never reproduced the reported symptom.** I reproduced my hypothesis. The test could not have
failed for the actual defect, because the actual defect is 378 ms upstream of the code I changed.

## What it actually is

The Operator retested twice and the badge still read `on`. quince#362 added logging to the op — the
only reason the third attempt produced an answer:

```
15:36:42.924  wifi_sync starting   action=disable transport=wifi
15:36:43.302  wifi_sync failed     "read-back failed, so the write is unconfirmed"
```

**`SetWifiSync` verifies the write by reading it back over the transport the write just severed.**
Turning off `EnableWifiConnections` stops the device answering over Wi-Fi — so for disable-over-Wi-Fi
the read-back is structurally impossible. The op fails and never reaches any publish. quince#357's
code did not run.

**And the write had applied.** `idevice_id -n` afterwards lists only the other device on the stand.
So quince reported *"The device accepted the change but did not apply it. Wi-Fi sync is unchanged"*
about a device that had changed and could no longer be reached without a cable. Every clause false.

**The badge reading `on` was quince being honest** — it refused to publish a change it could not
confirm. I spent the day fixing the mechanism that would have made a *dishonest* badge correct, while
the honest badge was reporting a failed op exactly as designed.

## The transferable part

**Reproducing your hypothesis is not reproducing the bug**, and a test that goes red-then-green feels
like proof of both. Mine was a real latent defect — `Enrich` really did drop that update, and
quince#357 stands on its own — which is what made it so convincing: *the fix worked*, it just was not
the fix for this.

The distinguishing question I did not ask: **can I make the reported symptom happen?** I could not
have — no device — and that was the moment to say the diagnosis was unproven rather than to let a
green test stand in for it. I wrote *"unverified on hardware"* on every PR and in the dashboard, which
was true and insufficient: I hedged the verification while stating the diagnosis as settled.

**Instrumentation is what broke the loop, and it was resisted twice.** The Operator offered to repeat
the test; the useful answer was *"yes, but not yet"* — a repeat without logging would have produced a
third identical report. The op had no log line on success at all, so three failed attempts left
nothing to distinguish a write that never ran from one that ran and was not published.

## Where it stands

Recorded as quince#363 with a `PROPOSED (gap)` in `docs/specs/qn.7/` (quince#365) rather than fixed:
what counts as a verified write, when the mutation destroys the only channel that could observe it,
is a user-visible semantics decision and not mine to improvise. Story 7's rule is right for the case
it was written for; it has no answer for this one.
