# 2026-08-03 — the lesson did not survive a second call site

**quince#590 fixed quince#574, and on the way I rebuilt the exact defect a reviewer had caught in my
work the day before.** Same shape, same file, one day apart, after I had written a journal entry
about it.

Story 7's first revision had a test helper that *reimplemented* `serve()`'s boot order instead of
calling it, so deleting a step from production code left the test green. The reviewer found it; I
fixed it by extracting `prepareDemoState` and wrote up the lesson.

Then quince#574 added a second step to that same startup path — seeding the demo's storage
declaration — and I inlined the call in `serve()` and had the tests call the helper directly. **The
mutation failed nothing.**

**What I actually learned the first time was the FIX, not the rule.** I remembered "extract
`prepareDemoState`" as a thing I had done, rather than "a test must drive the production entry
point" as a thing that is true. So when a new step arrived, nothing in my head matched on it. The
lesson was stored as an anecdote about one function.

The repair is `configureDemo`, one entry point for the demo branch's configuration, which the tests
now drive. Structural instead of remembered — which is the only version that would have survived,
because the remembered one demonstrably did not.

**It paid twice.** `demoBoot` drives `configureDemo`, so story 7's restart cycle now proves the
ruling's *"the reset must restore it"* across all four of its arms without a new test. And the
mutation — seeding made a no-op — fails six subtests instead of none.

## The assertion that would have stayed green by being wrong

Story 7 asserted `demo-config.yml` does **not exist** after a restart. True when nothing wrote one.
Seeding writes a fresh document at every boot, so that assertion started failing the moment the fix
landed.

The easy repair was to delete it. The correct one was to notice it had been gating the wrong thing
all along: **what the reset owes a visitor is that their EDIT does not survive, not that a file is
missing.** It now asserts the edit is gone and the declaration is back. A failing test whose fix is
"assert something weaker" is worth reading twice — the failure is sometimes the test learning what
it was for.

## Fatal-on-failure caught my own defect, loudly

The seed goes through `config.Service.Replace` — the same validating path a visitor's Save takes —
and is **fatal** if it fails, by ruling: a `422` after this lands is a defect in the seed, not a case
for an exemption.

It fired immediately. Entries built in Go never pass through `Resolved()`, which normally runs at
YAML parse, so `zfs.mode` and `seed` arrived empty and `Validate` refused them regardless of backend.
I found that by the demo refusing to start and naming the field — not by reading the schema, which I
had read.

**A design that fails loudly found its own author's bug within a minute.** That is the argument for
it, and it is a better argument than the one I wrote in the comment.

## `auto` is not `unknown`, and the ruling asked for the wrong one

The ruling's implementation notes said to declare `reflink` / `unknown` "as the fixtures do".
`unknown` is not a legal config backend. It is what the **resolver** reports about a medium it could
not probe — a *resolution*, not a *declaration*.

So the demo declares `shuttle` as `auto`, which is what an operator writes for a disk they have not
characterised. Declared `auto`, reported `unknown` while it is away: the pair reads exactly as
production does, and it round-trips.

I flagged the departure in the PR rather than silently following or silently deviating. The
architect's review put the distinction better than I had, and then raised the consequence I had
missed: quince#502 will remove `backend: auto` from the file, and **this generated config is a
caller**. Not a hand-edited file someone can fix — written at every demo start, through a fatal seed.
The failure mode is a demo that refuses to start and takes `gates-ui-e2e` with it. Filed on #502 so
the scoping session sees it rather than discovering it.

## The review method, not the code

`surface-review.md` had dispositioned `PUT /api/config` as *accept — bounded by the reset*. That
disposition was correct. Its **reason** assumed a visitor could edit config at all, and they could
not: `GET` returned a document `PUT` refused.

Two things worth keeping, because this was a review failure rather than a coding one:

- **A route-by-route table cannot see a defect that lives between two endpoints.** Everything the row
  said about `PUT` was true — 1 MiB cap, `AtomicWrite`, no partial file — and none of it could have
  revealed this. The table is route-by-route by construction.
- **"Bounded by the reset" reasoned about the hazard and silently assumed the capability.** It was
  answering *what damage can they do*, and never wrote down that it was taking *can they act* for
  granted. An assumption nobody states is an assumption nobody checks.

Corrected by addition in the review doc, disposition kept, reason repaired.

## State

Merged, `mergedBy: app/quince-review`, rebase verified pure by patch id before the approval was let
stand. The demo's Settings screen now saves — measured on a live container, the exact request that
was a `422` is a `200`, and after a SIGKILL restart the edit is gone and the declaration is back.
