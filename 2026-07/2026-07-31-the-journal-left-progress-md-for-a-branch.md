# 2026-07-31 — The journal left `progress.md` for a branch, and the first entry written under the new shape is this one

**The journal left `progress.md` for a branch, and the first entry written under the new shape is
this one.** quince-devlog#30's 2026-07-30 ruling reversed its own earlier decision — the journal
moves to an unprotected `journal` branch rather than to Discussions, because the `quince-bot`
suspension was a natural experiment and it came back one-sided: 196 commits that account authored
are still fully readable in git, and every issue and PR it authored returns `Not Found` to every
identity. A commit's author is metadata; a forge object's author is a visibility key.

**What changed.** `progress.md` went from **5,446 lines / 525,514 bytes to 71 lines / 24,020
bytes**. 177 entries were migrated to per-entry files at `<YYYY-MM>/<YYYY-MM-DD>-<slug>.md`, joined
by two that were never in `main`: r1's retirement record, stranded in closed PR quince-devlog#127
and recovered from `refs/pull/127/head`, and the 267-line state block, relocated verbatim. The
branch carries a generated index, a frozen map of the retired lettered ids, and the append flow.
`bin/dashboard-size` now fails when the file grows back, and `bin/pre-push-journal` refuses a push
to `journal` that has not been swept.

**What was proven.** Three independent checks, because one tool agreeing with itself is not
evidence: `journal-migrate --verify` reassembles every migrated entry **byte-identically**; an
order-independent multiset check over all 5,051 content lines agrees through a different code path;
and re-running the split from a clean checkout reproduces the branch tree byte for byte. Only the
`- ` marker, the 2-space indent and the bare `<date>: ` prefix were removed, and all three are
re-derivable — which is what `verify` demonstrates rather than asserts. The parser **dies** on any
line it does not recognise, including a blank line inside an entry, so a silently skipped line is
not a failure mode this had.

**Three facts about the record, found by moving it.** `(j)`, `(n)` and `(o)` were never minted —
zero occurrences anywhere — so a reader who assumes the lettered sequence is dense concludes an
entry was lost. `(ag)` was minted **twice**, same day, two unrelated entries, so a citation to it is
ambiguous and always was. 116 of the 119 ids resolve. None of this was known before; none of it is a
property of the move.

**Two measurements of mine were wrong, and both are corrected on the PRs rather than quietly.** I
reported `progress.md` as 324 KB from `du -h`, which on this box reports compressed blocks: it is
**525,514 bytes, 62% larger**, and the number was load-bearing for the size-gate threshold. And the
independent multiset check **failed on its first run** — it compared pre-strip source lines against
post-strip files and reported 165 differences. It found a defect in itself, not in the migration,
and a check that had passed first time would have told me less.

**What is owed.** The documents that name `progress.md` as the journal's home — `CLAUDE.md`,
`/onboard`, `/retire`, this repo's `README.md`, `decisions/0000` and `decisions/0006` — are
quince-devlog#153, are code-owned, and are deliberately not in this work. **Between the reduction
landing and that landing they point at something that is no longer there.** The `provision` wiring
that would install the pre-push hook is quince#308; until it lands, the hook is in force only where
somebody ran `--install`, which is weaker than quince-devlog#152 asked for. And **`quince-devlog`
has no CI**, so neither gate is a required check — the CI question is raised for the Operator on
quince-devlog#156 and deliberately not answered.

**The blocker was structural and cost nothing to route around correctly.** `refs/heads/journal`
cannot exist while any `refs/heads/journal/*` does, and three branches held that namespace — one
backing an open PR belonging to a retired session. Deleting it was not the implementer's to do, so
none of the three was touched and the question went to the architect; the Operator renamed rather
than deleted every ref with content at stake. Worth its own line: `journal/<title>` was
off-convention, and this is a **second, independent** argument for the runner prefix — a topic-first
branch name can squat a ref namespace a later branch needs, and the failure surfaces days later as a
rejected push by an unrelated session.

([quince-devlog#152](https://github.com/novkostya/quince-devlog/issues/152),
[quince-devlog#30](https://github.com/novkostya/quince-devlog/issues/30),
[quince-devlog#154](https://github.com/novkostya/quince-devlog/pull/154),
[quince-devlog#155](https://github.com/novkostya/quince-devlog/pull/155),
[quince-devlog#156](https://github.com/novkostya/quince-devlog/pull/156),
[quince-devlog#157](https://github.com/novkostya/quince-devlog/pull/157),
[quince#308](https://github.com/novkostya/quince/issues/308))
