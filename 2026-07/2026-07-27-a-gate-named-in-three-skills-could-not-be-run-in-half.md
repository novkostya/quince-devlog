# 2026-07-27 — A gate named in three skills could not be run in half the forge set, and had been complied with in words for as long as nobody tried it

**A gate named in three skills could not be run in half the forge set, and had been
complied with in words for as long as nobody tried it.**
[quince#78](https://github.com/novkostya/quince/issues/78) closed by
[quince#97](https://github.com/novkostya/quince/pull/97) (`3526539`). `report`, `land` and
`review-pr` all named only `make privacy-check`, and **`quince-devlog` has no Makefile**. No
Makefile was added there, per the ruling: it would exist to wrap one script, in a repository with
no build, and be a second place for the invocation to drift from the tool. The devlog form is the
product checkout's script run **from the devlog clone**, and two things about it were learned by
getting them wrong in the same session: **do not pass `--patterns`** — it defaults to `./local`,
relative to the *current directory*, and handing it a file rather than the directory produces a
`2`, which is DID NOT RUN; and **`cd` to the repository being swept**, not the one holding the
script, because `--ref` resolves against the current directory's git repo. **Which copy was chosen
rather than defaulted**, since the ruling asked: the **work clone's**, because a stale
privacy-check is precisely the one that exits `0` having checked nothing — the defect quince#41
fixed — and the launchpad has been measured stale at a commit predating a file entirely
(quince#33). The failure modes differ and that is the argument: a work clone's copy fails by *not
existing*, which is loud; the launchpad's fails by *being old*, which is silent and looks like a
pass. **A contradiction next door was fixed with it**, ruled in scope by review rather than assumed:
`/kickoff` §6 said the gate *"prints `skipped` and exits 0 having checked nothing"* — the behaviour
quince#41 removed — forty lines from §3 saying it exits `2`. Measured on a layer-less clone before
correcting it: **exit 2**. One skill asserting both the pre- and post-fix behaviour of a tool is
devlog#54's drift inside a single file, and landing a fix for *"the gate is unreachable"* beside
*"the gate passes silently"* would have been the reported symptom left standing next to its cause.
**And a reading habit became canon:** a clean sweep ends `swept branch-diff commit-message
branch-name text`, and **that list is an assertion about coverage, not a formality** — `0` answers
*did anything match*, only the list answers *was anything looked at*. Found because a failed rebase
short-circuited an `&&` chain, the commit never ran, and the sweep reported clean, truthfully, over
an empty branch; the reviewer had quoted the full list four times that day without reading it as a
claim. That is quince#41's distinction one level up.
([quince#97](https://github.com/novkostya/quince/pull/97),
[#78](https://github.com/novkostya/quince/issues/78),
[#41](https://github.com/novkostya/quince/issues/41),
[#33](https://github.com/novkostya/quince/issues/33))
