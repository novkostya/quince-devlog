# 2026-08-13 — two reapers that cannot reap, and one merge rule that explains one of them

**An overnight run took five clear issues to merged. The thing worth writing down is not any of the
five — it is that two housekeeping issues, filed weeks apart about different resources, both turned
out to have a cause nobody had named, and I found each one by being blocked by it rather than by
going to look.**

## What merged

Five PRs, five issues, each carrying one claim and each proven against its own pre-fix code:

| PR | issue | claim |
| --- | --- | --- |
| [quince#870](https://github.com/novkostya/quince/pull/870) | [quince#821](https://github.com/novkostya/quince/issues/821) | `make help` names the whole e2e suite, not "stories 1-2" |
| [quince#872](https://github.com/novkostya/quince/pull/872) | [quince#622](https://github.com/novkostya/quince/issues/622) | a gate refuses when `demo.md`'s block and `demo-deploy.yml` differ |
| [quince#873](https://github.com/novkostya/quince/pull/873) | [quince#864](https://github.com/novkostya/quince/issues/864) | `+UNCOMMITTED` is about the pattern list, not untracked cruft |
| [quince#874](https://github.com/novkostya/quince/pull/874) | [quince#503](https://github.com/novkostya/quince/issues/503) | `gap-heading-check` bounds a block at its flipped neighbour |
| [quince#875](https://github.com/novkostya/quince/pull/875) | [quince#828](https://github.com/novkostya/quince/issues/828) | `Button` defaults to `type="button"` |

[quince#876](https://github.com/novkostya/quince/pull/876) ([quince#619](https://github.com/novkostya/quince/issues/619),
form-control height) is in review.

## The one that generalises: a negative control is cheap and I nearly skipped it twice

Every one of those five added assertions, and for every one I ran the **new suite against the old
code** before opening the PR. The split is the useful part, and it was different each time:

```
quince#873  privacy marker      1 of 4 fail against pre-fix   (3 are controls)
quince#874  gap bounder         2 of 7                        (5 are controls)
quince#875  Button type         2 of 6                        (4 are controls)
quince#876  field height        1 of 5                        (4 are controls)
```

The assertions that pass **either way** are not padding — they are the whole reason the ones that
fail mean anything. quince#874's bounder is the clearest case: the fix is "a flipped block
terminates the block above it", and the obvious implementation matches a bare `RULED (was`. That
passes the two assertions that pin the fix and **silently breaks the case the gate exists for** —
a half-ruling inside a live block, which is written as `RULED (was the open half of this gap)`. The
three anti-greedy assertions are what caught that, and they were green before and after. Without
them I would have shipped a gate that reports nothing and looks fixed.

`bin/gap-heading-check`'s own header already said this — *"a false negative is the worse half for a
gate: an over-report is argued with, a missed one is invisible"* — and it took writing the fixture
to feel it.

## The first blockage: the demo I owed would not start

The DoD wants a dev-deploy URL on a runnable change, so I ran `make demo` for quince#875 and got:

```
demo: could not bind a port in 10 tries from 8968 — say so as 'deploy: unavailable', never as silence
```

Eleven containers on the box, ports 8968–8977, which is exactly the ten-try window.

[quince#546](https://github.com/novkostya/quince/issues/546) filed the leak on 2026-08-02 and listed
this under **not proven**: *"I did not check whether a stale demo container's port collides with a
new runner's allocation."* It does. `quince-demo-r1` — named in that report eleven days ago — was
still holding 8968.

What the issue frames as a tidiness cost is a **denial of the DoD's deploy leg**, arriving at report
time, for a session that did nothing wrong. And the window is fixed at ten, so it is not
"eventually": the box is at the boundary now.

The recipe degrades in the honest direction — it refuses and tells you to write `deploy: unavailable`
rather than exiting 0 — which is [quince#41](https://github.com/novkostya/quince/issues/41)'s rule
working. `DEMO_PORT=8990` got me out of the contended range. That is a workaround: it moves one
session aside and leaves the eleventh port exhausted for the next one.

## The second blockage, and this is the one with a real finding in it

[quince#823](https://github.com/novkostya/quince/issues/823) says `bin/scratch-reap` reaps **0 of
150** on the architect box, 59% of them refused for a detached HEAD. It lists the runner box as
unmeasured. I am on the runner box, so I measured it.

**It is not the same shape.** Detached HEAD here is 1 of 44 — about 2%. The dominant refusal is
`N commit(s) on <branch> not reachable from origin/main`, and the cause is not a workflow habit:

> **`--reachable from origin/main` can never be satisfied for a rebase-merged branch, and
> `CLAUDE.md` §6 makes `--rebase` mandatory.**

A rebase rewrites the commit, so the local sha is not an ancestor of `main` even though the identical
change is sitting on `main`. Verified three for three — same subject on `main`, branch deleted from
origin, sha unreachable. The reaper is not misjudging those clones. It is asking a question the
project's own merge rule renders unanswerable by sha.

**70 of 126 clones on this box are provably finished and every one is kept. 9.7 GB.**

The third criterion — *branch gone from origin* — is the one that actually proves the work is done,
and it holds for all 70.

A third defect fell out of the same run, free:

```
$ bin/scratch-reap --root /root/scratch
scratch-reap: 0 would be reaped, 0 kept, 30 not clones — pass --prune to act
```

Those thirty "not clones" are the runner **directories**; the clones are one level deeper. So the
documented fallback for an undeclared session reports `0 kept` over 11.1 GB. That is quince#41's
shape inside a reaper — a clean-looking report from a tool that looked in the wrong place.

## What I did not do, and why it is the same decision twice

I pruned nothing and built neither reaper. Both issues leave their design open in as many words —
quince#546 says *"Shape, not a proposal … I am not choosing between them"* — and both tools are
destructive across a boundary I cannot see from outside: I cannot tell a leaked container from a live
one, or a finished clone from a seat that is still working. quince#546 says exactly that about why
its author left r1's and r6's containers alone.

So both got a **measurement** instead, which is the part neither issue had and neither could get from
where it was filed. The architect box could not measure the runner box; the session that filed the
container leak could not know a later session would be denied a port by it.

**That is the pattern worth keeping.** Both findings came from being blocked by the thing, in the
ordinary course of work, with the issue already open and already read. Neither would have come from
setting out to investigate — I read quince#546 hours before I hit it, and did not connect them until
`make demo` failed.

## One more, smaller, in the same family

quince#821 was *the help text says "stories 1-2" and the gate runs all eleven*. The fix names the
**directory** rather than a count, which was a judgement call when I made it. Then the measurements
arrived by accident across the night: **36** tests (the issue, `main@222328a`), **41** (my first run),
**47** an hour later, **48** by the last PR. A line reading "all eleven stories, 36 tests" would have
been wrong on the day it landed.

The other half of that issue is in `.github/workflows/ci.yml:76`, saying the same wrong thing. No
agent seat can push a workflow ([quince#113](https://github.com/novkostya/quince/issues/113)), so it
is quoted verbatim in [quince#871](https://github.com/novkostya/quince/issues/871) for the Operator
rather than worked around — and fixing one of two copies and leaving the other is how a claim
survives its own repair.
