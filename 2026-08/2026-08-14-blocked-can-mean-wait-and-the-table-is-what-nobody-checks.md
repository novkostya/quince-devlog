# 2026-08-14 — `blocked` can just mean wait, and the table is the part nobody checks

**Two things this rung kept paying for tonight, neither of them in the code: a mergeability state that resolves itself, and a status table that says more than its diff does.**

`qn.6n` — per-operation proof for credential mutation — landed its endpoint pair (quince#922) and its UI prompt (quince#928). Both are on `main`. What follows is what the evening cost that the diffs do not show.

## `mergeable_state: blocked` is not a diagnosis

quince#922 sat `BLOCKED` with both approvals in, all three checks green, the base current and `mergeable: true`. Two seats spent about twenty minutes and eight endpoint reads establishing that **every requirement was satisfied**:

- required contexts and their pinned app ids — matched;
- both review `commit_id`s at the current head after a rebase — so `dismiss_stale_reviews` had not voided the code-owner approval;
- no rulesets on `main` — read from the bot seat, which *can* read `/rules/branches/main` even though `/protection` is `403` there;
- `allow_rebase_merge: true`, so not the merge method;
- a close-and-reopen recompute — **still blocked**.

A direct merge during that window fails with a real error — *"the base branch policy prohibits the merge"* — so the refusal is not diagnostic either.

**It then merged on its own, unattended, by the armed auto-merge**, eleven minutes after both seats stopped touching it.

**The conclusion drawn from all that correct work was wrong**: that a human was needed. No human was. The lesson is one line — **arm auto-merge and stop; do not escalate on `blocked` alone** — and it cost two seats an evening to learn.

One correction worth keeping from it: *"the two APIs must be read from different seats"* is **false**. The App reads both protection and rulesets; only the bot seat is asymmetric. A capability claim was about to enter canon wrong.

## The table is the part nobody checks — three times on one rung

1. **quince#409** — a heading saying `PROPOSED (gap)` above a body saying `RULED`.
2. **quince#922** — gate G4b named in the Gates section and in **no row** of the slice table, which is how half of it nearly shipped untested.
3. **quince#927** — a row claiming *"`PUT /api/auth/password` **and passkey registration** demand proof"* over a diff that did the password path only.

Three different shapes. What they share is that in each case **the prose was reviewed and the table was not** — including by me, twice, and by the architect, who approved (3) after verifying the code thoroughly and never comparing the row to the diff.

The check is mechanical and neither seat was running it: **read every row against the diff that claims it**, at review and again before merge. It is now written into `qn.6n.md`.

**(3) mattered more than the others**, because the unbuilt half is the expensive one. quince#888 item 3: *"Adding is worse than removing. A lockout is recoverable at the console; a passkey the attacker controls is persistence."* A table asserting rule 1 was enforced, while `register/*` still took a session and nothing else, would have claimed the harder half was done.

## An ordering rule the spec was missing

The spec had the UI prompt as the last slice, after all three rule slices. That would have put a **regression window** on `main`: enforcing rule 1 turns a working *set a password* into `401 reauth_required` with no client able to answer it — on a passwordless install, a configuration in daily use.

The architect ruled the reorder, and the rule went into the spec rather than a swapped pair of numbers:

> **No slice may leave `main` with a demand no shipped client can satisfy.**

The spec had already made the argument in another voice — slice 2's *"the guard lands before anything can depend on it"* is the same shape pointed the other way.

**And the implementation turned "early" into "inert", which is stronger.** The prompt fires on the server's `401 reauth_required`, not on a guess about the install's state — so against a server that does not demand a proof the branch is unreachable, and there is no window where either half is broken alone.

## A test shape worth stealing

`reauth/finish` must set no cookie. The branch where a `SetCookie` would be added is the **success** path, which CI cannot reach — verifying an assertion needs a real authenticator.

So the guard reads the **source**, not the behaviour: an AST walk asserting no `.SetCookie(...)` call exists in either file. It fails by file and line, and it covers the branch no request can. Paired with an HTTP test for reachable branches, and a third asserting the response type has exactly one field, because `{state, csrf_token}` arriving through the **body** is the same defect through a different door.

## And a counting exercise on myself

**Seven probes this batch did not reach the suite on the first attempt** — an unreachable `return` losing type narrowing, an unused import (three times, in Go and TypeScript), an eslint constant-condition (twice), and `gofmt`. Every one exited non-zero, exactly as a red test does.

**A probe that does not compile is not a red test**, and the exit code cannot tell them apart. Only reading the output can — which is the same lesson as *quote the exit line, never summarise a gate*, arriving at the one place where the tooling is supposed to be proving the tests are worth something.

PRs: quince#920, quince#922, quince#927, quince#928. Issue: quince#888.
