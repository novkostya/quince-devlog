# 2026-07-30 — A fix answered the right question about the wrong field, and the regression it caused was found by the seat that approved it — four hours later, on itself

**A fix answered the right question about the wrong field, and the regression it caused
was found by the seat that approved it — four hours later, on itself.** quince#299 taught `owed_role`
the architect box's live credential and, in the same arm, changed which wrapper that box is handed:
from the cached PAT tool to the App tool, on the argument that *"the key IS the App's and the App is
what casts verdicts and merges"*. True, and about **verdicts**. Every consumer of that field is a
**READ** — `owed`'s forge query, its fetch default, and the watch command the `Stop` hook prints —
and not one casts anything, which the issue's own *"not swept"* left open and the fix's sweep closed.
So a **watch loop** landed on a wrapper that mints a fresh installation token per call and caches
nothing, exactly as that wrapper's own comment warns: *"if that ever bites, cache it."* **It bites,
and measurement made the case stronger than the filing did**: the issue was careful to say its cost
was arithmetic, and the figure — **measured as a PROXY, and the qualification is part of it: the
implementer's App wrapper on the implementer box rather than the reviewer's on the architect's, with
the mint not separated from the API call** — is `5 calls → 9.222 s ≈ 1.84 s per call`, so a tick of
~39 wrapper invocations spends most of a 90 s interval minting one-hour tokens it discards. **Not
overhead on a tick but a tick that barely fits between its own ticks**, and that consequence inherits
every one of the three caveats above. **The first timing attempt reported
`0 ms` and was nearly posted as evidence the concern was unfounded**: BusyBox `date` has no `%N`, so
the nanosecond arithmetic produced zeros. *A timing harness that reports zero is reporting that it
did not work.* The fix redefines the single field as the **read** wrapper rather than adding a
second — identity still decided by the review key, so nothing re-couples to the PAT — and falls back
to the App wrapper when that PAT is retired, degrading to correct-but-slow rather than broken. **The
new assertions are driven rather than grepped, correcting the suite section's own premise** that
`owed_role` cannot be exercised without a credential and a forge: it performs `[ -f ]` tests and
nothing else.
([quince#303](https://github.com/novkostya/quince/issues/303),
[quince#304](https://github.com/novkostya/quince/pull/304))
