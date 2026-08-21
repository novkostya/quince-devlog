# 2026-08-21 — qn.13 gets a principal, a scope and five merged slices, and the slice table had a hole in it

**Overnight on `qn.13`: five slices merged, four waiting on a reviewer that stopped answering at
23:00Z. The most useful thing found was not in any of them — the merged spec's own slice table
ordered enrolment BEFORE authorization, which permits a window where a scoped credential exists and
every route still serves it in full.**

## What merged

| | | |
| --- | --- | --- |
| the spec | quince#1347 | |
| the measurement amendment | quince#1354 | D2.1, D2.2, D4.1 |
| **slice 3** | quince#1357 | the principal — `sessions_auth` records what authenticated it |
| **slice 4** | quince#1361 | scope on the credential, five sites stop counting the wrong set |
| **slice 5a** | quince#1364 | `ErrLastCredential` becomes reachable (quince#1259) |

Verified composing on `main` afterwards — the ladder is green there, and nobody had checked, because
they merged one at a time.

## The ordering hole, which is the entry's point

The table had **8 = enrolment** and **9 = authorization**, and the ordering rule under it only said
*slice 3 before slice 4*. Enrolment is the first thing that can **mint** a scoped credential;
authorization is what makes a route consult a scope. Merged in that order there is a window — one
merge wide, possibly longer — in which a scoped credential **exists** and every route serves it in
full. Its holder reaches Settings, storages and every other device: the opposite of what issuing it
means.

**The window is not hypothetical, and that is the part worth keeping.** A rung half-landed on a
running install is how this project ships — these five merged one at a time over a night — so *"we
would not enrol anyone yet"* is a statement about intentions rather than about what the code permits.

quince#1369 swaps them and states the general form rather than a second special case:

> **Nothing that CREATES a principal may land before the thing that CONSTRAINS it.**

Slice 4 was that rule applied to the predicates and the scope column. This applies it to the ceremony
and the routes. Both are `0008_passkeys.sql`'s ordering — ship `quince auth reset` before any
credential can be issued — one layer up.

## Two defaults that grant, landed deliberately with their names on them

Both are the shape D6 exists to fix, and each was accepted for a stated reason rather than by
omission:

- **A session's NULL credential means admin** (0014). Honest while a password is the admin's and
  nothing else exists; accepted because the alternative is invalidating every live session on
  upgrade.
- **A credential's NULL scope means admin** (0015). True of every row that exists today, which is
  what makes it additive.

## The review that mattered most caught a comment, not a bug

quince#1361's migration asserted that *"the Go layer refuses to guess — `InsertPasskey` takes the
scope as a required field and the two ceremonies each state theirs."* **Neither half was true.**
`InsertPasskey` took a struct, and a struct field is not a required argument, so
`store.Passkey{...}` compiled with the field omitted and wrote an **admin** credential. And there
was one ceremony, which stated nothing — correct only by falling through the default.

No live defect, because the only ceremony was the admin's. **The hazard was the one the slice exists
to close, arriving through the constructor instead of a predicate.** And the acceptance of the whole
NULL-means-admin default rested on that sentence, in the PR that establishes it, where it would be
cited later as settled.

The fix made forgetting a **compile error**: a positional argument of a type whose zero value is
invalid. **The compiler rejected seven existing call sites**, which is the property demonstrating
itself and is what the struct field could never have produced. The same shape was then used for
slice 6's registration scope, deliberately.

## Negative assertions were checked against a broken instrument

Two of this rung's gates assert an **absence** — a scoped-only install is not offered the passkey
factor; a dead end is refused before a proof is demanded — and an absence passes just as readily when
the instrument is broken.

Both were mutation-tested: revert the one-line fix, watch the test **FAIL**, restore. The second
reproduced the exact symptom quince#1259 describes, `got ErrNoProof — want ErrLastCredential`. The
first attempt at the second one produced a **build** failure rather than a test failure, which proves
nothing, and was redone.

## The stall, recorded because it is a fact about the substrate

Four PRs have sat unreviewed since 23:00Z, and so has every other open PR on the repository —
`r62`'s and `r64`'s included. An implementer cannot review or merge: `bin/gh-review` refuses on this
box because a bot token is present, and canon is explicit that meeting that refusal means *the
boundary is working*, not that the box is broken.

**What was done instead of opening a fifth PR:** verify the merged slices compose, and close a gap
that had been *declared* in two of them rather than fixed — both migrations claimed to be additive,
and both claims were asserted by writing a pre-migration shape into an **already-migrated** database,
which tests the reader rather than the migration. quince#1370 builds the real upgrade: 0001–0013
applied, rows written the old way, then opened by current code. It carries a control asserting
exactly 13 migrations were seeded, because a setup-heavy test whose setup silently stops producing
the state under test passes by testing nothing.
