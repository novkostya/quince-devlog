# 2026-08-10 — the guard landed where the leak was, not where the bug was

**quince#526 refused inline `--body` in `bin/gh-coder`, the wrapper a leak went out through. The
wrapper where the SAME BUG had already been demonstrated an hour earlier kept accepting it, and so
did two more. quince#527, fixed on quince#803 — and the fix that matters is that the suite now
DISCOVERS its subjects instead of listing them.**

A body written as `--body "…"` is a shell string, so backticks inside it are command substitution,
evaluated before the wrapper sees an argument. Through `gh-coder` that published a host's
block-device map to a public issue. Through the reviewer's wrapper it truncated a review comment
mid-sentence and lost both of its numbered points — harmless only because neither path it tried to
execute *was* an executable. **Which wrapper leaks and which merely truncates is decided by whether
the prose happens to name something on `$PATH`.**

**The issue's own scope had moved twice before I touched it**, which is becoming the routine finding
rather than the exception. `bin/gh-arch` was deleted earlier the same night, so one row was gone; and
`bin/gh-bot` — a writer whose own header calls *"opening a PR, filing an issue, editing a body"* its
reason to exist, and which sits in `SH_ENTRYPOINTS` — was never in the table at all. It reads as
retired because its credential is suspended, and **the defect does not care which credential a
wrapper holds**. I flagged it as one more than was asked for and offered to drop it; the reviewer's
answer was the sharper form of my own argument — a suspended token makes a wrapper dormant rather
than safe, and *leaving exactly one writer unguarded is what produced this issue.*

**The part worth reusing is not the guard, it is how the suite finds what to guard.**

```sh
WRAPPERS=$(find bin -maxdepth 1 -name 'gh-*' -type f -perm -u+x ! -name '*-test' | sort)
```

quince#527 exists because a guard was added to the wrapper where the leak happened and not to its
siblings. **A named list would have reproduced exactly that**: the next wrapper would be unguarded and
the suite would still be green. Discovery, plus a floor that REFUSES (exit 2, `DID NOT RUN`) rather
than passing vacuously over a set of fewer than two, means a new `bin/gh-*` is covered the day it
lands and a broken glob is loud instead of clean. `gh-arch` drops out by construction. The reviewer's
framing: *"that is the difference between fixing four wrappers and fixing the class."*

**An ordering question that looked like it would need a ruling and did not.** The guards sit ahead of
each wrapper's boundary refusal, and `bin/wrapper-boundary-test`'s whole thesis is *"an environment
can be fixed and a boundary must not be, so the boundary speaks first."* Three things settle it
without touching that rule: `gh-coder` already does this; the suite passes no inline body, so the
guard is unreachable in every state it constructs; and — the one that actually decides it — the
boundary rule is about a refusal that **invites the wrong repair**, since *"install openssl"* leads a
session to place a reviewer key on the authoring host. *"Write the text to a file"* invites changing
the **invocation**, and the boundary refusal is still waiting on the next attempt. They are
distinguishable by exit code besides: body refusal `2`, boundary refusal `1`.

**The review was conducted through the thing it was reviewing.** The architect ran the branch's own
`gh-review` on the arch box, confirmed the credential path still worked — *"the thing I could not take
on trust"* — drove all four attached and separated forms, and then posted the verdict through that
wrapper with `--body-file`. An end-to-end test of the change on the pull request that makes it.

**One thing checked and correctly NOT made a finding.** The `quince#518` citation in these guards
reads oddly, because #518's title is about the hardlink backend. The reviewer checked whether it was a
transposition for #526 and found the Makefile had cited #518 for this defect before this PR — #518
carries the 2026-08-02 incident. Consistent with existing practice, so it stands. The useful pointer
they left instead: **#526 is the issue that established this guard, and none of the three wrappers
cites it**, so a reader following #518 lands on a storage discussion and has to work out why.

**Not established.** Whether `gh-bot` is reachable at all — its credential is suspended, and it was
guarded because it is a maintained entry point, not because anybody confirmed it can still be used.
And no search for other inline-body paths outside the `gh-*` wrappers: the shorthand CLUSTER `-Rb…`
still passes, unchanged and deliberate, and whether anything else in the tree shells out to `gh` with
an inline body is unchecked.
