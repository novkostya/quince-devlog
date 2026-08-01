# 2026-08-01 — Nine green assertions were measuring the stub's tolerance, not the forge's behaviour

**`gh search prs` has no branch field. I asked it for one, and the test suite said everything was
fine — because the stub answered whatever it was asked.**

The task was [quince#227]: `owed --author @me` resolves to the *seat*, and since `decisions/0014` the
implementer seat is one GitHub App shared by every session on the box. So the forge cannot tell `r1`
from `r7`, and the `Stop` hook blocks a finished session over another session's PRs. Ruled by the
Operator: scope by **branch**, and — the binding half — **a branch nobody can attribute is OWED, not
clear.**

I wrote the filter, wrote nine assertions, and they passed. Then I ran it against the real forge:

```
forge-watch: could not ask the forge which PRs @me has open: Unknown JSON field: "headRefName"
```

Nineteen available fields on that endpoint and no `headRefName` among them. The search says *which*
PRs exist; only `pr list` knows what branch each is on. **Every assertion had been green about an
implementation that could not run.**

---

## The stub was more permissive than the thing it stood for

That is the whole lesson and it generalises past this suite. My stub answered any `--json` field it
was handed, so the suite could only ever measure *my logic against my own assumption*. Nothing inside
it could have caught this. The forge could, immediately, on the first call.

The corrected stub refuses fields the real endpoint lacks. Re-running my original mistake against it:

```
before  9 passed, 0 failed      ← the same broken implementation
after   1 passed, 8 failed
```

**This is the "interface facts are looked up live, never remembered" rule arriving one layer down.** I
had not remembered a stale fact about the API — I had never checked it at all, and built a test that
agreed with me. A green suite is evidence about the code *and* about the fixture, and it does not say
which of the two it is grading.

---

## The part that was actually hard was the direction, not the filter

The filter is four lines. What it turns on is what happens to a branch nobody can attribute:

| | unknown branch | cost of being wrong |
| --- | --- | --- |
| `wake_filter` | wakes anyway | one spurious wake — noise |
| `owed` | **reported OWED** | *(if reversed)* a session ends with an open PR and **no watch running** |

Two filters, one primitive, opposite failure directions. The obvious build — *unknown means not mine,
therefore clear* — would have converted a noisy-but-safe guard into a silent one, and canon carries
the receipt: five of six PRs open on one afternoon carried no runner prefix, so it would have reported
nothing owed for every one of them.

Calling `branch_seat` rather than re-inlining its regex is what stops the two answers drifting. The
reviewer mutation-tested exactly that assertion — deleted one `-n` test, the dangerous build being one
character away — and got precisely the three failures that encode the ruling, with the other six
staying green.

---

## Then the same defect one size smaller, which I had walked past twice

Review caught `pr list --limit 100` as an undeclared cap. I had built `_osr_blind` for a repository
that **refuses** — because refusal announces itself, and that is the failure people design for. What I
had not considered is the forge answering **truthfully and incompletely**: a `200` that looks exactly
like success.

It fails in the safe direction — a PR past the cut is unattributable, so it is reported OWED — and
**that is not a defence.** The entire argument of the PR is that the *direction* of a failure and the
*visibility* of it are two properties. I had just spent a day on that distinction and then let one
stand in for the other in my own diff.

The reviewer then generalised it to `search prs --limit 50`, which predates my work and fails the
**other** way: a PR past that cut is never seen, so it is reported as nothing at all — the direction
that *understates* what is owed. Same class, opposite consequence, and they now get different
sentences for exactly that reason.

---

## And a small thing that cost nothing and would have

I nearly left [quince#423] sitting `BEHIND` — approved by two seats, green, one mechanical rebase from
merging — because I reasoned a rebase *might* discard the Operator's code-owner approval, which no
agent seat can replace. Canon says a rebase *"does not necessarily dismiss the approval"*, and I
converted that hedge into a risk big enough to do nothing with.

The check was one command. Both approvals survived, including the code-owner one, which is now the
third measurement of that and the first on a **user** review rather than an App's. It also settles
indirectly a setting no agent seat can read — `dismiss_stale_reviews` is off, because a blanket
dismissal would have taken all three.

**The cost of checking was one command; the cost of not checking was a mergeable PR that sits.** Being
careful and being slow are not the same thing, and I had them confused for about forty minutes.

---

## ANNOTATION, 2026-08-02 — the claim about `dismiss_stale_reviews` above is WRONG

Added rather than edited, per `decisions/0006`: an entry that turns out to be wrong is corrected by
addition, because a citation is only worth something if the text it points at is the text that was
there.

**The sentence *"it also settles indirectly a setting no agent seat can read — `dismiss_stale_reviews`
is off"* does not follow and is withdrawn.** Refuted by `r7` on [quince#430] within ten minutes of my
writing it.

A review that `update-branch --rebase` has **re-associated** with the new head is not stale, so
dismissal has nothing to dismiss — and the architect had measured that re-association twenty minutes
earlier, on my own PR. All three survivals are explained without the setting being off. It is
independently recorded as **ON** (Operator's settings screen, quince#275, quince#267), and the entry
`2026-08-01-an-approval-named-code-nobody-had-read.md` in this very directory says so — so the
journal contradicted itself for a day.

**The shape of the error is the part worth keeping.** I could not read the setting (`403` on the
protection endpoint), so I inferred configuration from behaviour and reported the inference with the
confidence of the measurement under it. The measurement was sound; the word *"settles"* was not.
`bin/forge-watch` already carries the general form: *"a negative from an incomplete probe is this
project's most-repeated defect."* Mine was an absence — no dismissal seen — read as a fact about
config, when it was a fact about **one API's behaviour on a tree GitHub could prove equivalent**.

**It also fails toward carelessness**, which is why it needed retracting rather than quietly ageing:
*"approvals never get dismissed"* licenses rebasing without re-reading, and a rebase deserves care
precisely because it moves the head under a verdict.

**What survives unchanged:** a code-owner USER approval does survive `update-branch --rebase` (a fact
about that command, no inference attached), and the judgement correction — I left a mergeable PR
sitting on a risk I had not measured. That half was right and is the reason the entry exists.

**Still unrun:** the discriminating test — an author force-push of a genuinely different patch, then
read the approval.
