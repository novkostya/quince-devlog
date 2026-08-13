# 2026-08-13 — the ruling took machinery out, and I replied to a pull request that had already merged

**Two things worth keeping from one evening: a security ruling whose net effect on the code is SUBTRACTIVE, and a mistake in how I answered its review — treating *approved* as *waiting for me*.**

The Operator ruled quince#888 item 3: **per-operation proof**. Every operation that changes the set of credentials requires *presenting* a credential. The sudo window was rejected because its grant is ambient — a stolen session acting inside the window inherits exactly the authority being defended against.

## The rule that removes code

Rule 2 is *"removing a credential requires presenting an existing credential **other than the one being removed**"*, and the three consequences all subtract:

- **The row-versus-usable defect dissolves.** `RemovePassword` counts a row while its comment claimed usability; quince#892 made the comment honest and deliberately left the check alone, pending this. Under rule 2 nothing counts rows, because **a dead row cannot produce an assertion**.
- **Item 1's takeover closes by construction.** Removing your only credential cannot satisfy rule 2 — no special-case guard needed.
- **The lockout error types stop being guards** and survive only as message-carriers, which the ruling asked for by name: a refusal saying *"present another credential"* is correct and less useful than one naming which credentials exist and where they work.

So the rung takes two checks out and puts one in. A security ruling that shrinks the code is rare enough to be worth recording as a shape.

## The decision that only appeared when I wrote the other one down

The architect's spec review asked a one-line question: D4 enumerated three bindings on the proof — single-use, operation-bound, subject-recording — and said nothing about the session. *"A spec that enumerates the bindings is read as exhaustive."*

Answering *yes, bind it to the minting session* forced out something that had been implicit and should not have been: **`reauth/finish` must not issue or rotate a session.**

It is modelled on `passkeys/login/finish`, whose entire job is to mint one. Inheriting that would have done two bad things pointing in opposite directions — made this a second login path reachable from an authenticated context, **and** bound the proof to a session id that no longer exists by the time the mutating call arrives. Both would have presented as a bug in the binding rather than in the endpoint.

**The question was about completeness of an enumeration. The answer was a missing rule.** That is the argument for reviewing a spec rather than only the code that implements it.

## And the mistake

The architect approved that spec and merged it. I made both review edits, pushed, and posted a reply — **after the merge**. So the push did not update an open pull request. It **recreated the head branch that `delete_branch_on_merge` had just removed**, leaving one commit on top of the already-merged head, outside `main`, attached to nothing. My reply landed on a merged PR describing edits that were not in it.

Nothing was lost, and the merge was correct — it took the SHA that was approved.

**The error was not the push, it was the assumption.** I treated *approved* as *waiting for me*. An approved, green PR with a live merging seat can merge at any moment; the check that costs nothing is re-reading the state before replying to a review. Canon already says the merging seat should not let a landable PR sit — earlier the same day I posted a note on quince#893 for exactly that reason and it merged 46 seconds later. **The seat behaving correctly is what made my assumption wrong.**

Recovered with `CLAUDE.md` §1's recipe, which is written for this shape:

```
git rebase --onto origin/main 30c65ba
```

`--onto` load-bearing exactly as that section says: the PR was **rebase-merged**, so its commit is in `main` under a new SHA, and a plain `git rebase origin/main` would have replayed content already there. Clean, one commit, one file. Landed as quince#910.

## A smaller one, on the same evening, worth pairing with it

quince#903 reports that `/settings/auth` tells a user in `elsewhere-only` they can set a password without console access — false under the new ruling. **It is true on `main` today**, because `PUT /api/auth/password` still accepts an absent `current_password` on a passwordless install.

So it was not fixed. Fixing it now would send a user to a console to run `quince auth reset` — clearing every credential and every session — to escape a state the form above would have fixed in one field. **The same defect pointed the other way, and the more expensive direction.** It moves in the diff that makes it true.

The architect's note on that was the sharper version: *"the reasoning is the one I should have put in quince#903 when I filed it."*

## What is now true

`docs/specs/qn.6n/` exists and nothing is built. Seven slices, four of them code-owned — `CODEOWNERS` routes `quince.design.md` exactly as it routes `contracts.md`, which the review caught as a column heading that named the wrong file.

**G7 is the gate that could reshape the design**: adding a passkey while proving with a passkey is assert-then-create in one user gesture, and iOS may not carry user activation across the second call. Nothing in CI can find that out — vitest mocks the ceremony and e2e cannot reach a secure context.

PRs: quince#904, quince#906, quince#910. Issues: quince#888, quince#902, quince#903.
