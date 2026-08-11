# 2026-08-11 — a rung that is BUILT and is not PROVEN, and the difference is one phone

**`qn.6k` (passkeys) is code-complete: nine PRs from Operator ruling to merged, in one day. Every
line of it is correct protocol handling, correct refusals and honest failure messages. NONE of it is
evidence that Face ID gets anybody into quince. G9 has not run, and until it does the honest word for
this rung is `built`.**

Recorded because the temptation at the end of a rung is to write *done*, and this project's own hard
rule — nothing claims more than was proven — applies hardest to the thing you just finished.

## What landed

| | |
| --- | --- |
| quince#826 | the spec |
| quince#827 | `quince auth reset` + the credentials table — **the escape hatch, before any credential could exist** |
| quince#829 | the rpId mismatch names the domain a passkey belongs to |
| quince#830 | registration |
| quince#831 | assertion, the shared rate limiter, three exact-path allowlists |
| quince#832 | conditional mediation on the login form |
| quince#833 | list / rename / remove |
| quince#834 | the Settings surface |
| quince#835 | the onboarding offer |

Two of those needed the **Operator's** approval as code owner, because they edit `docs/contracts.md`
and an App cannot be a code owner. Both were the only blocking moments in the day, and both worked
exactly as the mechanism intends.

## The rung's own lesson: writing it down found two bugs, at two altitudes

**The spec found one while being written.** D5 asked *which of these endpoints are pre-auth?* and the
answer surfaced that the assertion pair must be in the **storageless-reachable** list too — a
storageless install being exactly where onboarding offers a passkey. A feature that fails precisely
where it is promised.

**The implementation found the second while being built.** There is a *third* exact-path list —
`csrfExempt`, because no CSRF cookie exists before login. The spec, which had just caught the
two-list trap, said "both". Each omission fails differently and none legibly: a 401 from the endpoint
that hands out sessions, a 503 on a storageless install, or a CSRF refusal about nothing the user
did.

Neither was reachable by running anything. In both cases the code did not exist yet.

## The design decision no example would have given

Every usage example in `go-webauthn` builds the relying-party handle **once at startup**, because a
normal deployment has one domain. quince does not — the access path is a user choice, and the staging
box was answering on two origins at once that afternoon. A singleton pins whichever name arrives
first and then either refuses every ceremony on any other or mints credentials against a name the
user never visits. **Following the examples would have produced exactly the silent failure the rung's
rpId design exists to prevent.**

## Four checks that did not check anything

All four surfaced the same way — by deleting the guarded thing and watching for the alarm:

1. A regression test green with **all three** guards removed; validation, not the guard, was stopping
   the post.
2. A `sed` that silently did not match, so two "passes" in a non-vacuity check meant nothing.
3. **A guard that was not one** — bypassing a `typeof PublicKeyCredential` check changed nothing
   observable, because the property access throws into the same `catch`. The gate that mattered was
   the next line.
4. A `?? []` that made an `Array.isArray` check look load-bearing when the only case tested was
   `undefined`, which the nullish default already covered.

And a fifth of the family: `git checkout --` on a file holding **uncommitted** work wiped a function,
and `make gates` had passed *before* that — so a green result was briefly held for a tree that no
longer existed. **`make image` caught it; `make gates` does not build the image.**

**The common shape is a control that appears to work.** Not one was found by running the suite.

## What is owed, and by whom

**G9 — a real passkey registering and asserting from the Operator's phone.** It blocks the rung being
called done and nothing else can supply it. **G10** (do passkeys survive iOS Lockdown Mode — upstream
of `qn.12`'s shape) and **G11** (`.local` as an rpId) are unrun and block nothing.

G11 got cheaper by accident: chasing an unrelated iOS focus oddity left quince serving its **own** TLS
on the staging box with a real trusted chain and no proxy in the path — which is the origin shape that
gate wants, and the one G9 needs too.

— implementer `r32`
