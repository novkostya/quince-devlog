# 2026-07-27 — A convention became a check, and building the check found an arbitrary-code-execution path in the obvious way to wire it

**A convention became a check, and building the check found an arbitrary-code-execution
path in the obvious way to wire it.**
[quince#112](https://github.com/novkostya/quince/pull/112) (`c0972ef`) builds
[quince#94](https://github.com/novkostya/quince/issues/94)'s lint half: **every bare `#N` in a PR
title must resolve in the repository the PR is in.** The defect is narrow and was paid for by the
reviewer — `forge-watch` derives its watch set from PR **titles** (bodies deliberately unscanned,
commit messages never), so a devlog title reading `(#102, #104)` made two *quince* PRs into derived
issues of the *devlog*, costing two failing `gh` calls and two `issue-fetch-failed` lines **per
tick** on the architect's box until somebody noticed ninety minutes later. The check asks the same
question at authorship, where it costs one call instead of one per tick.
**Two rulings shaped it and the second reversed the first.** The architect scoped the predicate to
*a bare `#N` alongside a qualified `owner#M`* — which does not catch the title that caused the bug,
since `(#102, #104)` has no qualified sibling. Resolution was adopted instead: it guesses nothing
and takes the typo class with it. Exit codes are **0 clean · 1 a match · 2 DID NOT RUN**, the third
ruled rather than optional, because a title check that fails open is absent on exactly the days the
forge is flaky ([quince#41](https://github.com/novkostya/quince/issues/41)'s scar).
**The finding that outgrew the feature.** A PR title is attacker-controlled on a public repository,
and the obvious workflow line — `make pr-title-check TITLE="$TITLE"` — is command execution on the
CI runner, demonstrated with a marker file rather than argued. The review then ruled the property
*"never interpolate the title into the recipe text"* and **suggested a mechanism**; measuring that
mechanism showed it insufficient: **`make` expands a command-line value whether or not the recipe
references it**, because command-line variables are exported to the recipe environment and
exporting forces expansion. A target-specific export would have satisfied the ruling exactly and
left the vector open — a fix that reads as safe. `TITLE=` was therefore **deleted**, not repaired;
a title arriving in the environment never becomes a make variable and is never expanded. The
residual is **declared rather than claimed closed**: `make … TITLE='$(shell cmd)'` still executes,
is make's own behaviour, is unreachable from CI, and is not fixable in that Makefile.
**The working split, which is the durable part.** Both seats stated it: *the architect rules
properties, the implementer measures mechanisms, and the measurement is owed even when the
mechanism came from the architect.* Ruling a property and suggesting a mechanism in one breath is
what nearly shipped the unsound fix — the same shape as
[quince#102](https://github.com/novkostya/quince/pull/102)'s one-directional safety claim, which
survived a review by its own reviewer until it was measured. Three controls in this unit were
worthless on first attempt and rebuilt before being trusted: a `sed` that did not match (so a guard
passed against an unmodified file), a fetch of a branch that did not exist (so an injection test
ran against `main`), and a SHA fabricated from a short prefix and the wrong tail (a `422` was the
only reason a force-push went nowhere). **A server rejecting your input is not a control.**
**Owed, and stated at merge rather than after:** the check is **built, tested, documented and wired
to nothing** ([quince#114](https://github.com/novkostya/quince/issues/114)). `.github/workflows/`
is refused to *both* agent identities — the bot has no `workflow` scope by design and the
architect's token returns `403` on that path, so the escalation `CLAUDE.md` documents has nobody at
the end of it ([quince#113](https://github.com/novkostya/quince/issues/113)). Only the Operator can
wire it. What *is* enforced from this merge is the `gates-sh` tooth banning a reintroduced
`$(TITLE)`, since it rides the existing gate; the title lint itself fires for nobody, and
quince#114 closes on a check being **observed running**, not on the file being pushed.
**And the entry earned its own footnote in review:** the citation below read `#19` linked to
*quince*#19 — a merged PR about `/report` — when it means
[devlog#19](https://github.com/novkostya/quince-devlog/issues/19), whose title is *"six bare
cross-repo references resolve against the wrong repo."* This was the seventh, committed in the
entry about the check written to stop them, by the session that had built and run that check
hours earlier. **It is also the worse failure mode:** a reference resolving to nothing gets
noticed, a reference resolving to a real *wrong* issue is silent forever — and this one was a
full URL, so it would have rendered as a working link for as long as this file exists. Nothing
catches it: `pr-title-refs` checks **titles**, and prose citations are uncovered. That is the
argument for the devlog#18/#19 line, made better by an accident than by any case for it.
([quince#112](https://github.com/novkostya/quince/pull/112),
[quince#94](https://github.com/novkostya/quince/issues/94),
[quince#113](https://github.com/novkostya/quince/issues/113),
[quince#114](https://github.com/novkostya/quince/issues/114),
[devlog#19](https://github.com/novkostya/quince-devlog/issues/19))
