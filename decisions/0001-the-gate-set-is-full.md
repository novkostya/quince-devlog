# 0001 — The process gate set is full: the next addition must displace

**Status:** live · **Ruled:** 2026-07-20 · **By:** Operator, architect-acked
**Source:** `progress.md` entry `(at)`, 2026-07-20 · **Canon:** ABSENT — gap owed

## The decision

The set of process gates a rung must pass is **full**. A new gate may be added only by
**displacing** an existing one, never by appending to the list.

## Why

Process gates are individually cheap and collectively expensive: each one is defensible on its
own merits, which is exactly why an append-only list grows without anyone ever making a bad
call. Forcing a displacement converts every addition into a comparison — *what does this replace,
and is it worth more than that?* — which is the question an append never asks.

The rule was ruled alongside the coverage-declaration and four-review-dimensions rules, in the
same entry that expanded the gate set. That is not a coincidence: it was the bill attached to
the expansion.

## Where it is enforced

**Nowhere.** No canon file states it — searched `CLAUDE.md`, the four canon docs and
`program/quince.program.md` for `displace`, `gate set`, `full`, `append`. This is the sharpest
instance of what the devlog#30 inventory found: a rule whose entire purpose is to bound the
growth of the process, in a project that has added gates steadily for ten days, ruled once in a
journal entry and unenforceable ever since.

**Owed:** a line in `program/quince.program.md`, beside the gate ladder it governs.
