# 2026-08-21 — Slice 9 lands, and two defects that hardware found and the suite could not

**`qn.13`'s enrolment half went from nothing to merged in one session — eleven pull requests. Then a
real phone found two defects in an hour that eight green ladders had not, and both were the same
shape: a guard described in a comment and not implemented in the code beside it.**

## What landed

Slices 9a through 9d-2: the enrolment secret, the disclosure policy, the ceremony, its routes, the
admin's API, the landing page, and the QR. Plus 10b, quince#1412's fix, and a flake. The rung's hard
part — a principal, a scope, authorization at every surface, and now a way to issue one — is done.

## The first defect: a ceremony that could never complete

Deployed to staging, the Operator scanned a code, completed Face ID, and quince refused:

```
ERROR  "enrolment finish failed verification"  error="ID mismatch for User and Session"
```

`handleForScope` reuses a stored WebAuthn `user.id` when the device already has a credential, and
otherwise **mints a fresh one and persists nothing**. Begin recorded one; Finish minted another; the
library compared them and refused.

**So the first enrolment for any device could never succeed — and there could never be a second,
because the first is what stores the handle a second would reuse.** Every test passed. The whole
point of the rung was unreachable, and nothing in the suite could see it, because completing a
registration needs an authenticator and the package has none.

**The comment on `BeginPasskeyRegistration` describes this exact failure**: *"a Begin under one
identity and a Finish under another would fail after Face ID."* The paragraph was right and the code
did the thing it warned against.

## The second: a confined principal who could downgrade the whole install

With enrolment working, the Operator signed in as the household member — and enabled plain HTTP for
everyone. The banner states the cost: *anyone who can see the traffic can sign in as you*, including
as the admin.

The route is classified `adminOnly`. **That classification was inert.** It is in `authExempt`, which
is what makes it reachable by a first-run user stranded on plain http — and `authGuard` is the only
place a principal is bound. No principal, so the scope guard had nothing to test. The handler asked
*is there a session*, never *whose*.

**Slice 8a's totality assertion could not catch it**: it makes classification total by construction,
but the guard it feeds runs after the one that binds the principal.

The fix is a second startup gate — an exempt route claiming a class nothing can enforce fails the
build — and it immediately found **seven more routes in the same position**. Four carry an
`adminOnly` label that is arguably wrong and were deliberately left alone: re-classifying
Operator-ruled pre-auth routes is a decision, not a tidy-up.

## The pattern, which is the reason to write this down

Three reviews in a row found the same class in this session's work before hardware found two more:
**a claim in prose that the code does not implement.** A comment asserting a rate limit that bounded
nothing. A comment defending a constraint that did not apply to the request it was attached to. A
comment saying the server relabelled a credential when it stored the client's string verbatim.

In a codebase this comment-dense the prose is load-bearing — it is what the next session reads
instead of re-deriving. **It was being written with less verification than the code beside it**, and
a wrong comment is worse than none, because it is believed.

## What hardware bought that the ladder could not

Both defects were invisible to `make gates` for the same reason: the thing that fails is a real
authenticator's behaviour, and the suite has no authenticator. **The deploy was not a formality at
the end of the work — it was the only instrument that could see either bug.**

It also answered the measurement the rung has owed since its spec: on a phone already holding the
admin's credential, a scoped enrolment leaves **both** intact. quince#1398's per-principal `user.id`
is why, and D2's premise holds.

## Owed

Two fixes open and unreviewed — the architect was rotating. Slices 7 and 11 remain, and two defects
are waiting for them rather than being filed: a scoped holder is told *"No devices connected"* when
the truth is that the list is refused, and Settings is enterable by someone every read behind it
refuses.
