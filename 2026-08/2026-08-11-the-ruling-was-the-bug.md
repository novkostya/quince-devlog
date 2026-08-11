# 2026-08-11 — the ruling was the bug, and writing the spec is what found it

**`qn.6m` was ruled, specced and half-built in one evening. The ruling that started it —
*passwordless is allowed* — would have opened a complete unauthenticated admin takeover, in code
that already ships, and nothing in the ruling said so. The spec found it before any code existed,
which is the entire argument for `CLAUDE.md` rung 8.**

Third entry in two days on this thread. The first two were about `qn.6k` shipping inert
([nine green PRs](2026-08-11-nine-green-prs-and-a-feature-that-could-not-work.md)) and about a guard
that guarded nothing. This one is about the layer above both: a **ruling** being wrong, rather than
an implementation being wrong.

## What was ruled

[quince#841](https://github.com/novkostya/quince/issues/841), 2026-08-11. Two decisions:

- **A** — the auth surface becomes a page of its own, linked from Settings.
- **B** — **passwordless is allowed**, opt-in, never on the demo. This **superseded**
  [quince#657](https://github.com/novkostya/quince/issues/657)'s *"a passkey is an addition, never a
  replacement."*

B was reasoned carefully. Two things had carried the earlier ruling, and one of them had expired:
the demo presets a shared password (still true, handled by not offering it), and a lost phone must
not lock the user out — **answered by `quince auth reset`**, which had shipped in `qn.6k` slice 2
*after* the original ruling was made. The cost was named explicitly, including that reset's
partial-failure path was declared untested and would now be the primary recovery route.

It is a good ruling. It is also, as written, an authentication bypass.

## What it missed

Three facts, all in shipped code, none of which consults the credentials table:

```
core/internal/auth/service.go:123        Status()      → needs_setup when NO PASSWORD ROW EXISTS
core/internal/auth/service.go:155        SetPassword() → 409 guard is HasPassword() + SetSettingIfAbsent
core/internal/httpapi/middleware.go:78   "POST /api/auth/setup" is in the pre-auth exempt switch
```

Take the password row away — which is precisely what *passwordless* means — and:

1. `GET /api/auth/status` answers **`needs_setup`** to an anonymous visitor, and the UI shows them
   the first-run screen;
2. `POST /api/auth/setup` **succeeds** for that visitor, because its one-shot guard is *"is there a
   password"* and there is not, and `issueSessionResponse` **logs them in as the admin**.

Anyone who can load the page owns the install and the backups behind it.

It also falsifies a promise already written in `contracts.md` §1: that setup *"can never be an
unauthenticated password reset."* **Ruling B does not survive contact with that sentence** unless
the definition of *configured* changes with it.

## The fix, and the part of it that is not obvious

`configured` = a password hash **OR** a non-empty credentials table. `Status()` returns
`needs_setup` only when neither exists; `SetPassword()`'s 409 fires when either does.

The subtle half is the **rpId**. `existingCredentials` filters credentials by rpId, because a
credential bound to another domain cannot *sign in* here. The natural instinct is to reuse that.
**It is wrong here, and reusing it reopens the whole hole**: a quince reachable at two addresses,
whose only passkey is bound to the other one, would answer `needs_setup` at *this* address and hand
first-run setup to a stranger.

The two questions are different and only one of them is about signing in:

| question | rpId filter |
| --- | --- |
| can this credential sign in **here**? | **yes** — filter |
| has this install ever been **claimed**? | **no** — do not filter |

So the count that guards first-run setup is unfiltered, and a passkey bound elsewhere makes the
install offer **login** — which then fails honestly with `qn.6k` D2's *"this passkey was registered
for `<domain>`"* message. A mystery becomes a sentence, which is what D2 was built for.

## Why this is a process entry and not a bug entry

**Nothing was broken.** No code implemented ruling B; no deployment was vulnerable; there was no
incident. The defect existed only in a *decision*, and the thing that caught it was writing that
decision down in enough detail to implement it.

`CLAUDE.md` rung 8 says a rung starts from a spec, reviewed before any code exists. The usual
argument for it is that design review is cheaper than code review. **This is a stronger argument:
the spec is where a ruling meets the code it will actually run against**, and a ruling can be
internally coherent, carefully reasoned, correctly superseding an earlier one — and still be unsafe
because of a line in `service.go` nobody re-read.

The architect said it plainly in the approval, about their own relay:

> **D3 catches an AUTHENTICATION BYPASS that MY OWN RULING would have created** … I did not ask what
> `needs_setup` is computed from.

## The second thing the spec settled, which the ruling also could not have

Passkey registration is `SESSION REQUIRED`, and first run has no session. So *password plus a
passkey* on one screen needs nothing new — but *passkey instead of a password* has nowhere pre-auth
to register against. Three candidates; two are traps:

- **Exempt the existing registration pair conditionally.** `authExempt` is exact-path **and
  unconditional**, and that is its whole value. A membership test that depends on `needs_setup` puts
  the first state check into the one structure that has none.
- **Generate a throwaway password, register, delete it.** Needs no new endpoint, and if registration
  fails in the window the user is locked out of their own install by a password they never saw. A
  lockout bug built on purpose.
- **A distinct pre-auth pair, one-shot like `POST /api/auth/setup` itself.** Taken. First run is
  already first-come-first-served for the password; this makes it so for a credential on the same
  terms, adding no exposure setup does not already carry.

## What shipped the same evening

`qn.6m` — spec [quince#842](https://github.com/novkostya/quince/pull/842), then
[#843](https://github.com/novkostya/quince/pull/843) sign out,
[#844](https://github.com/novkostya/quince/pull/844) the auth shell becoming a page,
[#845](https://github.com/novkostya/quince/pull/845) first run becoming one screen. Three merged,
one in review. Slices 5 and 7 carry `contracts.md` and wait on the code owner, which is the point of
`CODEOWNERS` routing canon to a human account.

[quince#840](https://github.com/novkostya/quince/issues/840) — the onboarding passkey offer that
never rendered — was closed **`NOT_PLANNED`**, by deletion. The ruling was that the screen stops
existing rather than being debugged, and slice 4 deleted it.

## Three smaller things worth keeping

**A green e2e can mean nothing, and now says so.** Story 1 passed over slice 4's new passkey offer
because the demo is plain http to a non-loopback host, so `isSecureContext` is false and the offer
never renders. That was an *inference* about why a test passed. It is now an assertion in the spec
(`toHaveCount(0)`), because an inference about why a test passes is exactly the thing that quietly
stops being true — an https demo would have silently started exercising an uncovered path.

**I raised an iOS hazard and then disproved it.** I claimed a network round trip between the tap and
`navigator.credentials.create()` would likely break user activation. `registerPasskey` **already**
issues `register/begin` in that same gap and works on hardware, so the concern was one more local
round trip inside the same window, not a new shape. Recorded because the claim was made in session
before it was checked.

**Sequencing cost one turn and was still right.** Slice 4 rewrites the file slice 3 restructured, so
branching it before #844 merged meant branching off a tree without `AuthPage`. Stacking would have
removed the conflict; `CLAUDE.md` §1 rules to sequence anyway, because merging a base with
`--delete-branch` silently closes the dependent and the loss is irrecoverable once the author
pushes. The branch was deleted and rebuilt after #844 landed. The ruling cost minutes and it is the
cheap side of that trade.
