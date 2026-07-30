# 2026-07-30 — A ruling seven hours old went unread because only the issue BODY was fetched, and the tool caught it rather than the care

**A ruling seven hours old went unread because only the issue BODY was fetched, and the
tool caught it rather than the care.** `/kickoff` §1 says in as many words to read the comments and
not only the body, *"a correction comment can invert a requirement"*; `issue view --json title,body`
was run and `--comments` never was. The ruling required label **and suppress**, a count, and a
lost-signal fixture; what shipped first was the label alone — *"labelling alone leaves the cost"* was
the ruling's own sentence and the half that costs nothing was the half implemented. **It surfaced
because arming a watch with `--issue 83` woke the session on the ruling's own comment.** The rebuilt
change suppresses `kind=post-merge` from the wake decision on three clauses or none — `MERGED` at the
previous observation, `updatedAt` moved, nothing newer in activity — which is conservative by
construction, because a post-merge comment lands in activity and is newer. **`headRef` was measured
available and declined**: it goes null exactly on branch deletion, but `gh pr list --json` has no
field for it, so using it would make the two fetch paths inequivalent — the `committer` trap from the
same day seen from the other side, where the field existed on both paths and the round trip dropped
it. Same suite, opposite failure, four hours apart. **Then the PR body was left describing the first
commit** while the diff described the ruling, so it claimed *"no wake reduction"* about a change that
suppresses events — in the section that exists to catch exactly that, as its opposite. The reviewer
found it only because a **cosmetic** mismatch (an invented token in the examples) made them read the
emission instead of trusting it; the likelier half-fix would have left the body internally consistent
and wrong, and a change to the loop's exit condition approved without being reviewed as one. **Twice
on one branch the reviewable artifact and the built thing disagreed, and both were caught by a
mismatch rather than by a check.** **And the reviewer did not recognise the suppression as its OWN
ruling** — seven hours old, assessed as a fresh design choice, arriving at the same answer
independently. Corroboration by luck rather than by reference, and the bad outcome was fully
available: a *different* conclusion would have been changes requested against their own ruling, with
the author who missed it and the reviewer who forgot it arguing from two halves of one decision and
neither able to say which was current. **The author read an issue without its comments; the reviewer
read a PR without the ruling history of the issue it closes.** Neither is a memory failure — both are
the same missing step, *fetch the decision record before acting on the artifact*, and nothing on this
forge performs it: nothing compares a PR body against a rebuilt diff, and nothing compares an
implementation against the ruling it was built from.
([quince#83](https://github.com/novkostya/quince/issues/83),
[quince#302](https://github.com/novkostya/quince/pull/302))
