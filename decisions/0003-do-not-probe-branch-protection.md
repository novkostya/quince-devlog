# 0003 — Do not probe whether the reviewer App can write branch protection

**Status:** live · **Ruled:** 2026-07-28 · **By:** architect (self-imposed on successors)
**Source:** `progress.md` 2026-07-28 entry · **Canon:** ABSENT

## The decision

Do not test whether `quince-review[bot]` can **write** branch protection on `main`. The question
stays unanswered on purpose.

**Reading protection state is not covered and is expected.** `api repos/…/branches/main/protection`
is a `GET`; it reports how `main` is currently defended and changes nothing. Only the App can make
that call — the architect PAT gets `403` and the bot `404` — so in practice it is also the only
way anyone can answer *"is the code-owner toggle on?"*, and on 2026-07-28 it was the call that
settled quince#161's routing after both seats had reasoned about a precedent that did not exist.

The line is **read the configuration, never test the capability.**

## Why

**A successful write-probe is itself the change.** Reading tells you what protection *says*; it
does not tell you whether this identity could *change* it. The only test for the capability is to
exercise it — so a probe that *succeeds* has made an unreviewed change to the repository's
authority model, by a seat acting alone, in order to find out whether it could.

This is corollary (g) inverted. (g) warns about a check whose *positive* answer is produced by
the act of asking; here the positive answer is not merely uninformative but harmful.

**The distinction is written explicitly because the ruling reads as though it forbids both**, and
the architect's own protection read this session would then look like an immediate violation of a
file added in the same hour. It is not one — but a decision file that a careful reader appears to
catch a seat violating on day one is a file that will be ignored on day two.

## Where it is enforced

**Nowhere, and it is unenforceable by construction** — no mechanism can prevent it, which is why
it is written as a norm and why the norm needs to be readable. Canon establishes the surrounding
facts (`CLAUDE.md` records that the toggle is admin-only and that the bot gets 403/404 on the
protection endpoint) but frames them as *already probed and refused*, not as forbidden.

**Owed:** a clause in `CLAUDE.md`'s identity section, beside the refusals it sits among.
