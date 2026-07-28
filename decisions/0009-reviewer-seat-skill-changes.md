# 0009 — A reviewer-seat skill change needs the Operator only when it moves what the reviewer may decide

**Status:** live, with a `PROPOSED (gap)` below · **Ruled:** 2026-07-27 · **By:** Operator
**Source:** `progress.md` 2026-07-27 entry · **Canon:** PARTIAL — see the gap block

## The decision

> A skill change governing the reviewer's seat needs the **Operator** only when it alters what
> the reviewer may or must **decide**. A factual correction about what a tool returns, carrying a
> test that fails on drift, is the **architect's** to approve — approve it on the test, not on
> the filer's word.

## Why

Routing every `/architect` or `/review-pr` edit through the Operator makes the Operator a
required hop for typo-class corrections, and a required hop that is usually unnecessary is a hop
people learn to skip. Splitting on *does this move the verdict scope* puts the Operator where the
authority model actually changes.

The second half carries its own weight: *approve it on the test, not on the filer's word.* A
factual claim about tool behaviour is approvable precisely because it is falsifiable — the test
fails if the tool drifts.

## PROPOSED (gap): this appeared to conflict with `CODEOWNERS`, and the conflict dissolves

The devlog#30 inventory flagged an apparent conflict: `.github/CODEOWNERS:76-77` rules that
**no** skill change is code-owned — broader and blunter than this decision — which reads as
routing *every* skill change to the ordinary architect approval.

**The architect's reading, offered here as the proposal rather than the conflict restated**
([review of devlog#67](https://github.com/novkostya/quince-devlog/pull/67)):

> They operate at different layers — CODEOWNERS fixes what is *mechanically required* to merge;
> the journal rule is an *escalation norm* about when the architect should seek the Operator
> anyway. One can say "an architect approval suffices" while the other says "do not use it here"
> without either being wrong.

And they converge once `CODEOWNERS`' own reasoning is followed through. `CODEOWNERS:78-86` says
the skills exemption is safe **only because canon restates anything load-bearing** they contain.
A skill change that alters what the reviewer may *decide* is load-bearing by definition — so
under `CODEOWNERS`' own clause it must be mirrored into canon, and **canon is owned**. The
Operator ends up in the loop through the owned file rather than through the skill file. Same
destination, different door.

**This is the authority model, so it is the Operator's to rule.** Neither agent seat has written
it into canon and neither should. Filed here per the gap protocol: the reasoning is recorded, the
thread stops, and nothing is built on it.
