# 2026-07-30 — A closing keyword beside a bare reference auto-closes on merge, the parser is not negation-aware, and FOUR instances in one night were each written by someone who knew

**A closing keyword beside a bare reference auto-closes on merge, the parser is not
negation-aware, and FOUR instances in one night were each written by someone who knew.** (1) a PR
body disclaiming the close, closing it; (2) the body of the PR *fixing* that, by the author of the
diagnosis, two hours later; (3) the **commit message of the commit that removed it from that body**;
(4) a claim to the reviewer that a PR would not auto-close its issue, made after reading one surface.
**The escalation is the finding: each time the knowledge was aimed at the surface that had bitten
last**, and the trap is not the keyword list — it is that reproducing the offending text is itself an
instance. **`closingIssuesReferences` is necessary and NOT sufficient**, and both seats concluded
otherwise from it: it reflects the PR BODY only, while a commit message landing on the default branch
closes issues too, and with `--rebase` every message is in scope. Confirmed end to end when
quince#291 merged and closed quince#290 from a bare reference in its message while the field read
`[]` throughout. **What is measured safe, and the scope of the measurement is part of the claim:**
in a PR **body**, backticked and fenced references do not link, and a repo-qualified one does not
either — so this project's own citation convention is inherently safe, and a PR written that way
must close its issue by hand. **The commit-message surface is UNMEASURED for backticks**: the test
was run against a body, which GitHub renders as markdown, and whether the auto-close parser honours
them in raw commit text was never checked — so the gate strips code spans from the body and matches
commit messages literally, over-firing there on purpose. A false hit in a commit message costs one
reading; a missed one closes an issue. **Only instance 4 was caught before it did
damage, and only that one was found by a command rather than by care** — which is the argument for
making the sweep a gate rather than a paragraph.
([quince#282](https://github.com/novkostya/quince/issues/282),
[quince#293](https://github.com/novkostya/quince/pull/293))
