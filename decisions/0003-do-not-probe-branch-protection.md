# 0003 — Do not probe whether the reviewer App can write branch protection

**Status:** live · **Ruled:** 2026-07-28 · **By:** architect (self-imposed on successors)
**Source:** `progress.md` 2026-07-28 entry · **Canon:** ABSENT

## The decision

Do not test whether `quince-review[bot]` can write branch protection on `main`. The question
stays unanswered on purpose.

## Why

**A successful probe is itself the change.** There is no read-only way to ask "can this identity
modify how `main` is defended" — the only test is to modify it. So a probe that *succeeds* has
made an unreviewed change to the repository's authority model, by a seat acting alone, in order
to find out whether it could.

This is corollary (g) inverted. (g) warns about a check whose *positive* answer is produced by
the act of asking; here the positive answer is not merely uninformative but harmful.

## Where it is enforced

**Nowhere, and it is unenforceable by construction** — no mechanism can prevent it, which is why
it is written as a norm and why the norm needs to be readable. Canon establishes the surrounding
facts (`CLAUDE.md` records that the toggle is admin-only and that the bot gets 403/404 on the
protection endpoint) but frames them as *already probed and refused*, not as forbidden.

**Owed:** a clause in `CLAUDE.md`'s identity section, beside the refusals it sits among.
