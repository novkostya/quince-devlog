# 2026-07-29 — A documentation issue about retired dev containers turned up three capability facts canon had wrong, and the doc fix is the smallest thing in it

**A documentation issue about retired dev containers turned up three capability
facts canon had wrong, and the doc fix is the smallest thing in it.** quince#189 asked for one
stale section in `.claude/README.md` and invited a tree-wide `quince-dev` grep; the grep found a
**fourth** instance in `deploy/dev.md` — the file `CLAUDE.md` names as *how to build and run the
gates anywhere*, answering "don't have a box to run gates on?" with a workflow retired on
2026-07-28. Both fixed by drawing the line `deploy/devct/devct`'s own header already draws
(persistent-box path live, disposable series retired) rather than by deleting anything; the 11
rung specs saying "green in `quince-dev`" were left alone as dated proof records. **Also
established: devlog#45's *body* contradicts the ruling in its comments** — it still lists "the
implementer creates its own dev CT … one runner, one CT" under *Settled — do not re-litigate* —
and both existing citations in the product repo point at the bare issue number, so a reader who
checks lands on the opposite of the decision. Citations now name the comment.
**What the review found is the better half.** The reviewer blocked on one inherited sentence —
`/etc/quince-devct-stamp` "on both boxes" — having measured it **absent** on the arch box.
Measured absent on the runner too: no `/etc/*stamp*` of any name on either. So `devct`'s header
has offered a provenance proof that does not exist since quince#181, and the fix went to the
**source** as well as the copy, because removing the sentence from one file while leaving it in
the other is this project's defect class committed knowingly. `/etc/alpine-release` reads
`3.24.1`, matching what the stamp claimed, so it is the **artifact** that is missing rather than
demonstrably the provenance; the likeliest cause is quince#205's second-site rebuild from an
Operator-local factory that writes no stamp, and that is recorded as a hypothesis with an issue
number rather than as a cause. Consequence: `devct list` reports template freshness by reading
that file, so on both boxes freshness is **unknown** rather than current.
**Three capability findings, each measured rather than reasoned.** (1) **No agent seat can re-run
a workflow run any more** — `403 Resource not accessible by integration` from the implementer App
at the porcelain *and* at both raw endpoints (`rerun`, `rerun-failed-jobs`). `CLAUDE.md` recorded
it as the implementer's one `CAN` and routed red-check asks there; that was a property of
`quince-bot`'s classic-`repo` PAT, not of the seat, and it did not survive `decisions/0014`. The
architect confirmed it independently from the arch box and took it to canon (quince#219) — a
capability recorded against a **seat** when it belonged to a **credential**. (2) **The committed
allowlist had drifted from every command canon instructs**: `bin/gh-coder` (14 references),
`bin/git-coder`, `bin/scratch-reap`, `make demo`, and — the subtle one — `Bash(make privacy-check)`
with no wildcard, while every form the hard rule mandates carries `REF=`/`TEXT=`. quince#198,
#177 and #179 each added an entrypoint and touched no settings file; nothing gates the pair.
(3) **A `--rebase` update-branch does NOT dismiss a standing approval here** — measured on
quince#216, which mattered in both directions: it stalled the author, who declined to rebase
rather than gamble an approval on a guess, and it endangers a reviewer who assumes dismissal and
merges an unread head.
**quince#211 was mis-measured by BOTH seats within the hour, and that is the finding rather
than the confirmation either of us filed.** `runner set r1` — the first name `/kickoff` §3
suggests — was refused, and the implementer read an empty state directory plus a missing
`$HOME/scratch` as a dead session's leftovers. They are also what a **live** session looks like
in its startup window, and `r1` was about three minutes into one; the refusal was correct and the
guard did its job. Retracted on the issue with the wrong comment left standing, because a
retraction that deletes its own subject leaves the next reader a conclusion they cannot check.
The architect over-read the same gap independently, from an isolated-state measurement whose
"gone" session had never existed as a process. **The defect is that `runner set` has one signal
where a watch has six:** quince#95 split `starting` out of `dead` precisely because they read
identically and want opposite remedies, and a runner name has no such class — "the directory
exists" has to answer live, starting and abandoned at once. Two careful readers got it wrong the
same way on the same day, which is better evidence for that than either confirmation was.
It surfaced only because a comment appeared under the implementer's own identity that the
implementer had not written: **the forge cannot distinguish concurrent sessions in a seat.**
`forge-watch` went to real trouble over runner ownership locally (quince#111, #174), but a PR
comment carries the App, not the runner — so "the author replied" is not the claim it looks like.
**Also:** a CI red on an
unrelated PR was diagnosed rather than re-run: `forge-watch-stop-test` asserts a signalled child
is dead without reaping it, and a zombie answers `kill -0` — the same file handles that exact
hazard twenty lines below, with a comment naming it. A rebase gave the control run (identical
tree, FAILURE then SUCCESS), which also shows the flake is not sticky.
**The flake's fix is in, and the question under it was ruled rather than left.** The reviewer
ruled that `stop_one` should wait for exit — bounded, escalating to `SIGKILL`, saying which
happened — because `kill` returning 0 means the signal was *queued*, and every skill prescribes
`stop`, **then** arm, which is quince#50's race if the watcher is still writing. Filed as
quince#221; the test fix is quince#223 and stands either way. That fix took the pattern rather
than the one site CI hit, and declined the obvious bare `wait`: the killer there is the tool under
test, so `wait` would turn a failing assertion into a **hanging suite**. Proven in both directions
deterministically, because the suite was green before and after — the old assertion `WOULD-FAIL`
against a real zombie, `gone()` returns true, and a genuinely-running process still returns false
at the bound rather than hanging. The window is also wider than "rare": 199 of 200 raw trials
caught the child as a live-answering zombie, and it is the surrounding `$(...)` fork that usually
closes it. **The CI failure was never reproduced locally, and the PR says so.**
**Owed:** quince#213 green and awaiting re-review; quince#221 unimplemented; nobody has
established what actually built the two boxes, which sits in quince#205's scope.
([quince#213](https://github.com/novkostya/quince/pull/213),
[quince#216](https://github.com/novkostya/quince/pull/216),
[quince#214](https://github.com/novkostya/quince/issues/214),
[quince#218](https://github.com/novkostya/quince/issues/218),
[quince#219](https://github.com/novkostya/quince/pull/219),
[quince#141](https://github.com/novkostya/quince/issues/141),
[quince#205](https://github.com/novkostya/quince/issues/205),
[quince#211](https://github.com/novkostya/quince/issues/211),
[quince#221](https://github.com/novkostya/quince/issues/221),
[quince#223](https://github.com/novkostya/quince/pull/223))
