# 0014 — The implementer identity becomes a GitHub App, not a second personal account

**Status:** live · **Ruled:** 2026-07-29 · **By:** Operator
**Source:** conversation, 2026-07-29 · **Canon:** ABSENT — see *Where it is enforced*

## The decision

`quince-bot` — a **personal user account** acting as the implementer seat — was suspended by
GitHub on 2026-07-28. An appeal was filed the same day (support ticket, Operator-held) and
**has received no response**.

The implementer identity moves to a **GitHub App owned by `novkostya`**, provisionally
`quince-coder`. It does **not** move to another personal account, now or later.

## Why an App rather than another account

**Because the thing that was suspended is a user account, and the thing that would look like
evasion is another one.** Evasion is concealing that the same principal is acting. An App
owned by `novkostya` conceals nothing: every action it takes is attributed to
`app/quince-coder`, visibly, under an account in good standing. GitHub suspended a machine
account, not the human and not the activity — `novkostya` is untouched.

**It is also not a novel pattern for this account.** `quince-review` has been a GitHub App on
these repositories since 2026-07-27 (quince#134), authoring (quince-devlog#53) and casting
verdicts, unremarked. This ruling extends an established pattern rather than introducing one,
and it moves *away* from the machine-user pattern that was flagged.

**And it is the direction GitHub's own product points.** Apps are the documented primitive for
automation; proliferating machine users is what they discourage.

## Why now, rather than after the appeal

The question of whether App-based automation is acceptable **was part of the original appeal**,
and GitHub has been silent. The Operator's measured expectation for the appeal process is
weeks to months, which at this project's pace is indefinite. Waiting is not a neutral option;
it is a different cost, paid with certainty, against a risk that cannot be quantified because
the counterparty will not answer.

**Recorded plainly: the residual risk is not zero and is not removable.** Nobody here knows
why `quince-bot` was suspended. If the cause was the *account shape*, an App is the sanctioned
remedy. If it was *behaviour*, the identity type is irrelevant and the behaviour would be the
problem under any identity. The reasoning above rests on the first reading and cannot verify
it. The downside, if wrong, lands on `novkostya`, which owns every repository, the App, and
the private layer's remote.

The Operator holds that risk knowingly. This file exists so that the holding was contemporaneous
and reasoned rather than reconstructed afterwards.

## The three conditions this decision carries

1. **Nothing about `quince-bot` is tidied away.** The appeal stays open, the record stays
   intact, the references stay in the tree. Evasion looks like erasure; good faith looks like
   an unbroken record one is willing to show.
2. **Same in kind and volume.** The architect App runs at ~18 of 5000 hourly API calls. The
   implementer App stays in that region. A new identity is not a reason to poll harder.
3. **Reversible on request.** If GitHub answers and objects, the App is removed. It is one
   click, and this file names that as the remedy.

## What it costs, measured 2026-07-29

`quince-bot.token` is not merely a credential — **it is how a box declares which seat it is**.
The assertion `holds the bot token ⇒ implementer` appears in **15 files**, and quince#188 made
those orderings load-bearing (a boundary refusal must outrank an environment one). An App holds
no token file: it mints an installation token per call. So `approver ≠ author` has to be
re-expressed in terms of *which App key a box holds*.

That is a designed change, not a swap, and this decision does not authorise doing it under time
pressure. There is none: **22 PRs merged in the day after the suspension**, because the
architect seat and the Operator's own machine cover the work.

## Where it is enforced

**Nowhere yet, and that is the gap this file must name rather than fill.** `CLAUDE.md` states
the two-seat model in terms of the bot token (`CLAUDE.md` "Hard rules", `deploy/runner/preflight`,
`bin/gh-arch`, `bin/gh-review`). Until those are rewritten, the enforcement still says *bot
token*, and this file is a record of intent, not a live control.

**Owed:** the canon rewrite, in `CLAUDE.md` and `deploy/runner/preflight`, expressing seat
identity in terms of App installation rather than a token file. `CLAUDE.md` is code-owned, so
that lands as App-authored canon with Operator approval.

## Related

- quince#134 — the reviewer became an App; the precedent this rests on.
- quince#136 — established that an App can author, not only approve.
- quince#188 — made the identity-before-environment ordering load-bearing in both wrappers.
- quince#47 — the seat/identity model this preserves.
