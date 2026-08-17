# 2026-08-18 — an amended ruling, and the two canon docs that had to move with it

**quince#1181 implements the Operator's 2026-08-17 ruling on quince#1157: the http→https redirect is
`301` only where `config.yml` names a certificate pair, and `307` otherwise. The interesting part is
not the status code — it is that the ruling AMENDS an earlier ruling, and that saying so correctly
costs an approval this runner cannot obtain.**

## What broke, and why nothing caught it

The redirect was an unconditional `301`, decided deliberately: cacheable on purpose, so a bookmark
upgrades itself once and stays upgraded. The code carried the whole trade, including its cost — the
redirect stays cached if the certificate later goes away — and accepted it on one clause:

> it is why turning TLS off is a config edit rather than something quince ever decides on its own.

`certTrial` falsifies that clause. A trial serves a certificate for ten minutes and then puts the
previous one back **by itself** — quince deciding, on a timer, to stop serving TLS, which is the one
event the ruling assumed could not happen. The trial landed after the ruling and nothing pointed back
at it.

**No gate could have caught this**, and that is the shape worth recording. Both changes were correct
in isolation. What broke was a *premise* held in a comment, invalidated by a mechanism added in a
different file months later. Nothing type-checks a premise.

## Three obligations that were about writing, not code

The ruling listed four things it obliged, and only one of them was the fix:

1. the predicate is *`config.yml` names a pair*, **not** *"a trial is running"* — those differ for a
   pair loaded and unconfirmed with no trial in flight;
2. the comment carrying the old trade is **rewritten in the same diff**, not appended to, because it
   asserts something flatly false at this head;
3. it is recorded as an **amendment** to the earlier ruling, in the shape quince#1152 used;
4. a test that a trial does not emit `301`.

Obligation 2 is the one this project keeps paying for from the other side. A correction placed
*underneath* a false present-tense sentence leaves the false sentence readable, and the Operator
struck exactly that shape from `docs/quince.stack.md` the same week.

## The test had to reproduce the mechanism, not simulate it

`certTrial` performs a trial by pointing the keeper at a pair and **leaving `config.yml` untouched** —
*"we're not going to actually write tls setting entry to config.yml for that."* So the test does the
same thing: `keeper.SetFiles(…)` with no write. That is not a convenience; not writing the file **is**
the mechanism, and it is precisely why the config is the right predicate.

It walks four states — no certificate, trial, confirmed, cleared — and I ran it against the pre-fix
behaviour before opening, where it fails naming 301 where 307 was wanted. The ruling's own reason for
demanding a test is that the regression is invisible in a browser until ten minutes later.

## The part that costs an approval

`docs/quince.design.md` and `docs/contracts.md` both asserted a flat `301`. Canon has to move in the
same diff — a change that contradicts canon updates that canon — and **`quince.design.md` is
code-owned by `@novkostya`** while `contracts.md` deliberately is not (Operator ruling, quince#953).

So this PR cannot be merged by the architect at all. Splitting it was the obvious escape and is
wrong: landing the code and the unowned doc first would leave the design doc contradicting shipped
behaviour between two merges, which is the thing the rule exists to prevent. It waits, and the PR
says so at the top rather than leaving a reviewer to discover it.

**Worth knowing for the next session**: an Operator ruling recorded in an owned canon doc always
costs an Operator approval to implement. That is not friction to route around — it is the authority
model working — but it means a ruling that arrives overnight cannot be *landed* overnight, only
built.

## Where the night went otherwise

Five PRs, three approved within the hour: quince#1172, quince#1173, quince#1176, quince#1180,
quince#1181. Every approved one went `BEHIND` two or three times while other runners merged, which is
`strict: true`'s steady state rather than an exception. I rebased them myself on §5's *"the author may
and should when its own work is what is blocked"*, read the approvals back each time rather than
assuming they survived, and recorded the pattern on quince#1172 so the merging seat can see a
cross-PR fact that is invisible from any single PR.

The thing that would end that loop is §6's auto-merge, which is the architect's to arm and not
mine — and which must be armed **after** a rebase, never on a `BEHIND` branch, because auto-merge
does not rebase.
