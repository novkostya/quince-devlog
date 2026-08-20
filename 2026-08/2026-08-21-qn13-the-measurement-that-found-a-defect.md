# 2026-08-21 — the qn.13 picker measurement confirmed the property and found the defect underneath it

**A measurement taken to settle whether a UX property survives came back *yes*, and the reason it
survives is a lockout waiting to happen. Three credentials on one iPhone present as ONE row, because
iOS collapses on `(rpId, username)` and quince names every credential `quince-admin`. They are not
uncluttered — they are indistinguishable and unselectable, and one of them could carry different
authority.**

## What was measured, and why the answer is not the finding

`qn.13`'s spec (quince#1347) declared one thing owed to hardware: do two discoverable credentials
sharing one `user_handle` on one rpId present as one entry or two on iOS? It decided whether the
no-account-picker property `qn.6k` chose discoverable credentials to obtain survives.

**It could not be taken on the stock product**, and that was the first thing worth knowing.
`auth/passkey.go:261` sends an exclusion list over every credential at the rpId, so the authenticator
refuses a second one on a device that already holds one — the exact state the measurement needed.
The build that went to the lab had that line removed and nothing else; it was rolled back within the
hour and the daily image tag was never overwritten.

**Result: three credentials in quince's table, one row on iOS.** The property survives. Sign-in used
credential `A` and left `B` *"never used"*, and the user was never asked.

**That last sentence is the finding.** A picker lets you choose. A single row that silently selects
among credentials **carrying different authority** is worse than the picker the property exists to
avoid — and under this rung, one phone could hold both an admin credential and a device-scoped one.

## The Operator's reaction was the ruling

> household member must not be quince-admin, that's wild

State honesty at the one place a user actually looks. The sheet labels a credential with its
`user.name`, so a household member's phone would tell them they hold **admin** — the opposite of what
their credential grants. So a scoped credential carries its device's name, and that is a **scoped
exception to quince#819** rather than a repeal of it: `passkey.go:161` requires the constant so a
passkey files itself beside the password rather than as a second identity, and a scoped credential
*is* a second identity, deliberately.

## What the measurement changed downstream

- **quince chooses what is offered.** `BeginDiscoverableLogin()` is an empty allow-list — *"platform,
  you choose"*. `BeginLogin(user)` populates one. A remembered principal gets one tap as the right
  identity; a subtle *change user* falls back to today's flow. The browser-side memory already exists
  as `passkeyHint.ts`'s boolean and holds a credential id instead, so nothing personal lands in
  `localStorage` and the hint still grants nothing — authority resolves from the assertion.
- **The enrolment ceremony excludes nothing.** An exclusion list on a page reached pre-authentication
  hands every admin credential id to whoever scanned the QR.

## The review found a site the spec had missed, and its shape is the lesson

The architect flagged that `BeginDiscoverableLogin` has **two** call sites, and — this is the part
worth keeping — **said plainly it had not checked whether the second one already passed an
allow-list**. It does: `reauth.go:158` narrows for `OpRemovePasskey` so a credential cannot prove its
own removal, and stays discoverable elsewhere on stated grounds:

> `add_passkey` and `set_password` are about the credential SET rather than a member of it, so
> restricting them would exclude nothing

**Scope breaks that reasoning.** There is no longer one set; those operate on the **admin's**, so
admitting a scoped credential as proof is a household member performing an admin operation. So the
invariant grew: it binds **ceremonies as well as predicates**, and *counting all rows* and *admitting
all rows as proof* are the same unsafe default. Slice 4 moved five sites, not three.

**A reviewer's honest "I did not check this" was worth more than a confident verdict either way.**
Asserted as fine, it would have stayed missed; asserted as broken, it would have been wrong, since
the removal path was already correct.

## Two defaults that grant, landed with their names on them

Slice 3 (quince#1357, merged) and slice 4 (quince#1361) each carry one, and both are the shape D6
exists to fix:

- **A session's NULL credential means admin.** Honest while a password is the admin's and nothing
  else exists. Accepted because the alternative is invalidating every live session on upgrade, and
  because `mintSession` takes the credential as a **parameter** so a future caller must state it.
- **A credential's NULL scope means admin.** True of every row that exists today, which is what makes
  it additive — and refused for new rows, which the two ceremonies each state.

`PrincipalFrom` returns a bool for the same reason: an exempt route has no principal, and a dropped
second value would turn *absent* into a zero `Principal`, which reads as *admin*.

## The gate was checked against a broken instrument

`TestScopedOnlyInstallCannotReachPasswordless` asserts an **absence** — that a scoped-only install is
not offered the passkey factor — and an absence passes just as readily when the instrument is broken.
So the one-line fix was reverted, the test was watched to **FAIL**, and it was restored. A standing
control sits beside it: the same call with an admin credential must still find the factor, so a
predicate that refused everything could not pass the suite.
