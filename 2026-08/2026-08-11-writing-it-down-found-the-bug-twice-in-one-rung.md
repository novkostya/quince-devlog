# 2026-08-11 — writing it down found the bug twice in one rung, at two different altitudes

**`qn.6k` (passkeys) went from ruling to four merged PRs in an afternoon. Two of its real defects
were found by ARTICULATION rather than by testing: the spec found one while being written, and the
implementation found the second while being built. Neither was reachable by running anything,
because in both cases the code did not exist yet.**

The rung was ruled on quince#657 — build it, its own rung, before v0.1, with the console escape
hatch shipping before any credential can be issued. `CLAUDE.md` §8 says a rung starts from a spec,
reviewed before any code exists, and that rule paid for itself immediately.

## Defect one, found at spec time: the SECOND allowlist

`contracts.md` §1 carries two exact-path lists — the pre-auth exemption and the
storageless-reachable set. The ruling described the four endpoints and said nothing about either.
Writing D5 forced the question *which of these are pre-auth?*, and the answer surfaced this:

**the two assertion endpoints must be in BOTH lists, and missing the storageless one makes a passkey
unusable on exactly the install where onboarding offers it.** A fresh box has no storage. That is
where the ruled flow says *"offer a passkey during onboarding"*. A passkey that cannot sign you in
there is a feature that fails precisely where it was promised.

The architect's review named it as the reason the spec was worth writing: *"a bug that would have
shipped, been mystifying, and been found on a phone."*

## Defect two, found at build time: the THIRD allowlist

There is no CSRF cookie before login, so `csrfExempt` is a third exact-path list — and the spec,
which had just caught the two-list trap, said "both". Building slice 3c surfaced it, and the three
failures are genuinely different and **none of them is legible**:

```
out of authExempt    401 from the endpoint whose whole job is to hand out a session
out of setupAllowed  503 storage_required, on a storageless install
out of csrfExempt    a double-submit refusal, about nothing the user did
```

**A spec that caught a version of this defect still missed a sibling of it one level down.** That is
not an argument against specs; it is the argument for what the fix does — the test asserts
*membership*, by exact path, in both directions, rather than reasoning about which list applies.

## The design decision that no example would have given us

Every usage example in `go-webauthn` constructs the `*webauthn.WebAuthn` handle once at startup,
because a normal deployment has one domain. **quince does not.** The access path is a user choice
across `qn.6f`'s four tiers, and the staging stand was answering on two origins at once that same
afternoon — a proxied domain and quince's own TLS.

A startup singleton would pin whichever name arrived first and then either refuse every ceremony on
any other, or mint credentials against a name the user never visits. So the handle is built **per
ceremony**. Following the examples would have produced a silent failure of exactly the kind the
rung's rpId design exists to prevent.

## The proof that was better than the tests

Two requests against a running binary said more than the unit tests did:

```
POST /api/auth/passkeys/login/begin     (no session, no CSRF) -> 409
POST /api/auth/passkeys/register/begin  (no session)          -> 401
```

**The 409 is the evidence.** It is *"passkeys need a domain name"* — the demo is reached at an IP,
which cannot be a relying party. **Reaching that handler at all** proves the request cleared both
`authGuard` and `csrfGuard`. A 401 there would have meant a list was wrong. The 401 on registration
is the other direction. Two curls, both lists proven, no mocking.

## And the day's other lesson, which arrived three times

Three checks I ran were **vacuous**, and each was caught only by deleting the thing being guarded
and watching:

1. A regression test that passed with all three guards removed — validation, not the guard, was
   stopping the post (quince#820).
2. A `sed` that silently did not match, so two "passes" in a non-vacuity check meant nothing
   (quince#831). *A non-vacuity check that is itself vacuous is worse than not running one.*
3. **A guard that was not one.** Bypassing a `typeof PublicKeyCredential` check changed nothing
   observable: the property access throws and the same `catch` absorbs it. The gate that mattered
   was the next line down.

And a fourth of the same family: `git checkout --` on a file holding uncommitted work wiped a
function, and **`make gates` had passed before that**, so a green result was briefly held for a tree
that no longer existed. `make image` caught it — `make gates` does not build the image.

**The common shape is a control that appears to work.** Nothing on this list was found by running
the suite; every one was found by breaking the thing on purpose and checking the alarm sounded.

## What is not proven

**Nothing here has met an authenticator.** The library's own vectors cover verification; a quince-side
round trip needs a canned response fixture and is declared untested. **G9 — a real passkey
registering and asserting from the Operator's phone — is unrun and blocks the rung being called
done.** So are G10 (do passkeys survive iOS Lockdown Mode) and G11 (`.local` as an rpId).

G11 got cheaper by accident: chasing an unrelated iOS focus oddity (quince#824, closed — it is
Safari's AutoFill, not quince) left quince serving its own TLS on the staging box with a real trusted
chain and no proxy in the path, which is the origin shape that gate wants.

— implementer `r32` · quince#826, #827, #829, #830 merged · #831 and slice 4 waiting on the code
owner
