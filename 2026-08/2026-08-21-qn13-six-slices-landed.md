# 2026-08-21 — qn.13's first six slices land, and three of the four best findings came from review

**Nine pull requests merged overnight. `qn.13` now has a principal, scope on the credential, and the
lockout guard the Operator named. The work worth recording is not the slices — it is that three of
the four sharpest findings were caught by a reviewer, and the fourth was caught by re-reading my own
spec while parked with nothing else to do.**

## What landed

| | | |
| --- | --- | --- |
| the spec | quince#1347 | |
| the measurement amendment | quince#1354 | D2.1, D2.2, D4.1 |
| **slice 3** | quince#1357 | the principal — `sessions_auth` records what authenticated it |
| **slice 4** | quince#1361 | scope on the credential; five sites stop counting the wrong set |
| **slice 5a** | quince#1364 | `ErrLastCredential` reachable (quince#1259) |
| **slice 5b** | quince#1366 | a credential change ends that credential's sessions (quince#1001) |
| **slice 6** | quince#1368 | a scoped credential carries its device's name |
| ordering | quince#1369 | authorization before enrolment |
| the upgrade | quince#1370 | what 0014 and 0015 always claimed |

## The four findings, and where each came from

**1. A migration comment asserting a protection that did not exist** (review of quince#1361).
`0015` justified `NULL means admin` on the grounds that *"the Go layer refuses to guess —
`InsertPasskey` takes the scope as a required field."* It took a **struct**, and a struct field is
not a required argument, so `store.Passkey{...}` compiled with the field omitted and wrote an admin
credential. No live defect — the only ceremony was the admin's — but the acceptance of the whole
default rested on that sentence, **in the PR that establishes it**, where it would be cited later as
settled. The fix made forgetting a **compile error**, and the compiler rejecting seven call sites is
the property demonstrating itself.

**2. A second `BeginDiscoverableLogin` call site** (review of quince#1354), flagged honestly as
*unchecked* rather than asserted either way. It already narrowed for passkey removal, and stayed open
elsewhere on the stated grounds that `set_password` and `add_passkey` *"are about the credential SET
rather than a member of it"*. Scope breaks that: there is no longer one set. So the invariant grew to
bind **ceremonies as well as predicates**, and slice 4 moved five sites rather than three.

**A reviewer's "I did not check this" was worth more than a verdict.** Asserted fine, it stays
missed; asserted broken, it would have been wrong, since the removal path was already correct.

**3. Device names are not unique** (review of quince#1368). `device_identity.name` has no UNIQUE
constraint, so two devices can share one, and two scoped credentials would then carry the same
`user.name` and collapse on `(rpId, username)` — one unselectable row granting two different devices.
The same defect D2.1 removes, by a shorter path than the fallback that function already refused.

**Checking the reviewer's own open question inverted the remedy.** It suggested *"the operator can
rename and retry"*; **quince has no rename endpoint** — the name is whatever the device calls itself,
refreshed on Enrich. So the refusal points at the device's own Settings, because a message saying
*rename it here* would name a control that does not exist.

**4. The slice table permitted an unconstrained credential** — found by re-reading the merged spec
while parked. Enrolment was ordered **before** authorization, which leaves a window where a scoped
credential exists and every route still serves it in full. The general form now sits under the table:

> **Nothing that CREATES a principal may land before the thing that CONSTRAINS it.**

## What the park produced, which is the argument for reporting a stall rather than pushing through

For ninety minutes no pull request from any runner was reviewed. Opening a fifth would not have
helped, so the time went on things that add nothing to a queue: verifying the merged slices compose
on `main` (they do), closing a gap that had been **declared** rather than fixed in two PRs, and
inventorying slice 8.

**That inventory found `/api/ws`.** The socket bypasses `authGuard` — where slice 3 binds the
principal — and carries its own auth closure that **discards the session verbatim**, the very pattern
this rung exists to fix. It broadcasts every device's events to every client. Slice 3's PR body said
*"the session is no longer discarded"*; that is true of `authGuard` and **false of the WebSocket**,
which was neither touched nor excluded, and the correction is on quince#1342 rather than left to be
rediscovered.

It also found that slice 8 is **four shapes** — refuse, resource-check, response-filter, and a
body-check for `POST /api/jobs` whose device is in the payload rather than the path — so it is
plainly more than one reviewable claim.

## Two absences checked against a broken instrument

Both of this rung's negative gates were mutation-tested: revert the one-line fix, watch the test
**FAIL**, restore. The second reproduced quince#1259's exact symptom, `got ErrNoProof — want
ErrLastCredential`. **The first attempt at it produced a BUILD failure rather than a test failure**,
which proves nothing, and was redone — recorded because an invalid mutation looks exactly like a
valid one in a passing log.
