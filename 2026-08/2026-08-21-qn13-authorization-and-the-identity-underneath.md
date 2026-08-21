# 2026-08-21 — qn.13 gets real authorization, and the naming fixes turn out to be symptoms

**Route authorization landed in four slices, the WebSocket stopped broadcasting every device to every
client, and then an Operator-directed issue found that both of yesterday's naming fixes were treating
a symptom: every quince credential presented the same WebAuthn `user.id`.**

## What landed

| | |
| --- | --- |
| the socket gets a principal and a send-time filter | quince#1380 |
| slice 8a — every route carries a scope decision | quince#1384 |
| the do-nothing ruling on a device named `quince-admin` | quince#1386 |
| slice 8b-1 — a scoped principal reaches only its own device | quince#1392 |
| slice 8b-2 — the last four routes resolve theirs | quince#1399 |
| slice 8c — the two list endpoints narrow | quince#1401 |
| one WebAuthn `user.id` per principal | quince#1398 |

## The identity bug, which is the entry's point

Every credential presented the same `user.id` — one stored random value, minted when the install had
one principal. `userHandle`'s own comment says *"the ADMIN's stable WebAuthn id"*. **qn.13 added a
second kind of principal and kept the identity model from when there was only one.**

`user.name` is a display string; `user.id` is the identity. Same `(rpId, user.id)` genuinely **is**
the same user. So the sheet collapsing three credentials into one row was **correct platform
behaviour**, and D2.1 "fixed" it by making a label carry identity work it cannot do. And two devices
sharing a NAME became an authorization dead end — `ErrAmbiguousScopeDevice` — because a display
collision was the only thing separating two principals.

**With one handle per principal, that error is DELETED rather than patched.** A name collision
becomes cosmetic: both credentials present separately and each grants only its own device. Refusing
to issue a credential over a cosmetic wart was the worse answer, and two devices sharing a name is
common — iOS default names are not unique.

**Two things were verified before building, because the issue said its blast radius was unmapped.**
The library really does compare handles — `bytes.Equal(userHandle, user.WebAuthnID())` in the
vendored source, refusing with *"User handle and User ID do not match"* — so login and reauth had to
answer with the CREDENTIAL's handle, resolved inside the lookup because a discoverable assertion
names nobody until the authenticator answers. And `user_handle` appears nowhere else: not in
`passkeyHint`, not in `allowCredentials`, not in the stored rows before this.

**One claim could not be settled and it is the one that made the issue urgent.** Whether an
authenticator REPLACES a discoverable credential sharing `(rpId, user.id)`. The W3C
`authenticatorMakeCredential` text would not retrieve in full — two attempts, both truncated before
§6.3.2 — and MDN describes duplicates being *prevented*, by `excludeCredentials`, **which D4.1 rules
the enrolment ceremony must not send.** So the guard MDN names is deliberately absent on exactly that
path. The fix removes the reliance either way; a measurement is owed and needs slice 9 plus a phone.

## Authorization is four shapes, and the gate found the routes a careful reading missed twice

D3's capability table reads as route-level yes/no. Over 60 registered routes it is not: some
**refuse**, some are permitted only for the caller's own device, some need the **response** narrowed,
and `POST /api/jobs` names its device **in the body** — a plain-looking create that a path-reading
guard would wave through.

Classification had to live beside the PATTERN, and that was forced rather than preferred: `authExempt`
matches on `Method + URL.Path`, which cannot express `{id}` routes, and this codebase deliberately
refuses prefix matching. Go sets `r.Pattern` only AFTER routing, so a middleware wrapping the mux
cannot read it. The one place a pattern exists as a string is the registration call.

**So a recording mux plus an assertion that panics at construction — and it earned itself
immediately.** The route inventory was built by grepping the registration file; the table written
from it still dropped four vault routes and the `/api/` catch-all. The panic named all five on the
first test that built a server. **A careful reading produced the same list twice and was wrong both
times.**

## The socket was the surface nobody had looked at

`/api/ws` bypasses the JSON API chain — the code says so — so it never passed through `authGuard`,
where the principal is bound. Its own auth closure discarded the session verbatim: **the exact
pattern the rung exists to fix, on the one path slice 3 did not reach.** Slice 3's PR body claimed
the session was no longer discarded; that was true of `authGuard` and false here.

The review then found the fix's own comment claiming a property it did not have — the principal was
resolved once pre-upgrade, so a send-time filter was **exactly as stale** as the narrowed
subscription it was being contrasted with. Closed by re-resolving on the existing ping tick, which
**also ended sockets outliving their sessions**: a client that logged out kept receiving every frame
until it disconnected on its own. True before qn.13, and nobody had cause to notice.

## Three self-inflicted things worth writing down

**A test that did not test its own name.** The first `TestAScopedPrincipalCannotAskForAnotherDevicesList`
bound no scoped principal at all — it exercised the no-principal path and passed. That is the exact
defect this session flagged in two reviews, shipped into its own working tree.

**A gate result unread.** One commit was made and pushed before reading the ladder, which was red on
a trivial `bodyclose`. The failure was nothing; skipping the exit line was not.

**A mutation that proved nothing, three times.** Deleting a line to check a test catches its absence
produced a BUILD failure — an unused variable, an unused import — which looks identical to a real
failure in a log and demonstrates nothing. The valid form mutates a value rather than removing a
declaration.
