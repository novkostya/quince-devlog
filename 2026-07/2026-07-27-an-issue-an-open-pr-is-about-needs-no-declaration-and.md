# 2026-07-27 — An issue an open PR is *about* needs no declaration — and the tool found the bug in its own discovery rule by running as its author's live watch

**An issue an open PR is *about* needs no declaration — and the tool found the bug in
its own discovery rule by running as its author's live watch.** quince#80 half two, landed by
[quince#89](https://github.com/novkostya/quince/pull/89) (`e2f6545`) with the follow-up
[quince#91](https://github.com/novkostya/quince/pull/91). Half one was a *declaration*, so it was
still something a session had to remember to do; the ruling said that is insufficient alone, and
the ordinary case is why — nobody should have to declare the issue their own PR is for.
**The discovery signal inverts the obvious design.** GitHub's own link data is the obvious answer
and it is not enough: over 25 PRs here (`gh pr list -R novkostya/quince --state all --limit 25`,
2026-07-27T09:57Z) `closingIssuesReferences` covers **9**, the `#N`-in-title convention covers
**22**, and their union **23**; the two exceptions are quince#34 and quince#30. **The decisive case
is quince#87 itself** — the PR that built half one. Its body says *"Closes half one of #80"*, which
GitHub does not parse because the keyword and the reference are not adjacent, so its link data is
**empty** while its title carries `(#80)`. A derived half resting on link data alone would have
missed the very PR written to fix the issue. The **body is deliberately not scanned**: quince#87's
cites eleven issue numbers, nearly all as history, and watching every issue a PR mentions is the
wallpaper this classifier has already rejected twice — worse here than anywhere, because the
channel's whole value is that an event on it means something. Discovery costs **no extra `gh`
call**; two fields ride along on the queue fetch. **The defect it found in itself is the part worth
keeping.** While the branch was running as the author's live watch it emitted `issue-fetch-failed
repo=novkostya/quince-devlog issue=87 reason=GraphQL:_Could_not_resolve_to_an_issue…`: a devlog PR
titled *"… a declaration now reaches it **(quince#87)**"* had made a naive `#[0-9]+` scan derive
`quince-devlog#87`, which does not exist. That is
[devlog#18](https://github.com/novkostya/quince-devlog/issues/18)'s class — **a cross-repo
reference resolved against the wrong repository — reproduced mechanically by a regex**, and it
surfaced as an event rather than as silence, which is the tool answering correctly a question it
should never have asked. Two fixes, and the second is the more general: the scan now requires the
`#` not to follow a word character; and **a failed read counts against `--fail-after` only for a
DECLARED issue**, because a declaration is a *request* while a reference is *the tool's own
inference*, and letting one bad guess exit the watch after three ticks is the tool punishing the
session for its mistake. **The guard is verified to FAIL against the old regex**, not merely to pass
against the new one — and that same run proves the second fix, exiting **6 rather than 7** as three
referenced-read failures decline to kill the watch. Closing it also closed a gap quince#87 had
declared as owed: the loop stub answered the Nth *call* with the Nth payload regardless of what was
asked, so a tick making two KINDS of call fed a `pr list` an issue object and **no loop fixture
could reach the issue path at all**. It now dispatches on argv with a queue per kind. **quince#91 is
the tail, and it is a silent drop caught by review:** the class was `[^A-Za-z0-9_/-]` while the
comment claimed word characters only, and the two extras were inert on every qualified form — each
is blocked by the alphanumeric before the `#` — while costing `fixes #12-#13`, which derived
**`[12]`** and dropped `#13` to a hyphen without a word. The no-silent-caps rule broken by a
character class, on the channel that carries rulings. Measured both ways before changing it; the
whole price is `docs/#5` now yielding `5`, which is not repo-qualified and so defensible. Fixtures
**34 → 36**. **What is owed:** `issue-reopened` still has no fixture, the `#12-#13` case rests on
side-by-side runs rather than a fixture and is declared as debt rather than implied as coverage,
the union is unreconciled where its two signals disagree — reviewer and author both failed to
construct a case where watching both is wrong — and quince#62's **fresh-session** property remains
untouched: one implementer session throughout, though the architect has now run half one on a
second box under a second identity, which narrows the box-and-identity part of that gap and leaves
the fresh-session leg exactly where it was.
([quince#89](https://github.com/novkostya/quince/pull/89),
[#91](https://github.com/novkostya/quince/pull/91),
[#80](https://github.com/novkostya/quince/issues/80),
[#87](https://github.com/novkostya/quince/pull/87),
[devlog#18](https://github.com/novkostya/quince-devlog/issues/18))
