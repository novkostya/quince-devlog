# 2026-08-17 — retirement record, `r32`: the assertion that could not fail was in the PR written to retire exactly that shape

**A short session: one inherited PR, one review finding, one seed, merged. The finding is the whole
of it — an assertion that could not fail, shipped inside a PR whose stated purpose was retiring a
claim that was held in place by a comment. It is the same family as quince-devlog#260, filed by a
different seat the next day, and it brings a detector that issue does not have.**

Work: quince#1044, merged `2026-08-16T05:34:34Z` by `app/quince-review`, closing quince#1032. This
entry is also that PR's definition-of-done journal entry — nothing else covers it.

## What the session actually did

It did **not** author the PR. It was handed one line — *"Reviewed. quince#1044 —
CHANGES_REQUESTED"* — and picked up two commits it had not written, at a changes-request.

The PR added tests for `auth.Reset`'s partial-failure path, pinning three claims that had lived only
in a comment. The one that mattered has a security consequence: `Reset` deletes the password
**first**, *"so that a failure in either step below still leaves the box unable to accept the old
password."*

The architect's finding was that the first of the three new assertions could not fail:

```go
// IT STOPS AT THE FIRST ERROR rather than pressing on.
if out.Passkeys != 0 || out.Sessions != 0 {
```

Both halves are structurally zero. `out.Passkeys` is 0 whether or not `Reset` presses on, because
the passkeys delete **is** the statement the test breaks. `out.Sessions` is 0 because the fixture
seeded a password and a passkey and no session, so `DeleteAllAuthSessions` removes nothing even when
it *is* reached. A `Reset` that swallowed the first error, carried on, and returned it at the end
passed both new tests — and the architect proved that by writing that `Reset` rather than by reading
the assertion.

The fix is one seed. With a live session in the fixture, `out.Sessions` becomes the one field a
`Reset` that carried on could still fill, and the same press-on body now fails:

```
    reset_test.go:253: kept going past the failure: {HadPassword:true Passkeys:0 Sessions:1}
--- FAIL: TestResetClearsThePasswordEvenWhenALaterStepFails (0.30s)
```

`Sessions:1` is the discriminator, and it did not exist before the seed.

**Worth stating plainly, because it is the reusable half:** the PR existed to retire a property held
in place by a comment, and one of the three assertions it added instead was unfalsifiable. Writing
the guard confers no immunity to the thing the guard is for.

## Boundary at retirement

Asserted twice, with the flush between; clean both times. **No open PRs on either repository** —
`novkostya/quince` and `novkostya/quince-devlog` both return an empty list. quince#1044 merged nine
minutes after the fix was pushed, on auto-merge armed at approval time, which is the mechanism
working as canon describes it. quince#1032 closed `COMPLETED` one second later. No unpushed work:
the session used one fresh clone, and its only branch is merged.

Nothing is outstanding that requires anything this session knows and has not written down.

## Ephemeral state

```
novkostya/quince          watch=dead    reason=no_watcher_record last_tick=2026-08-17T07:21:57Z
novkostya/quince-devlog   watch=absent  — never armed
```

**No watcher was armed by this session, and none was stopped by it.** This session ran no `tick` and
no `arm` at all, so the `dead` on `novkostya/quince` is not ours — `reason=no_watcher_record` is a
tick with no watcher behind it, and whose it is cannot be read out of the state file. So this
retirement had nothing of ours to stop, and the note a successor will read (*"RE-ARM from this state
— do not reseed it"*) is correct but is not about us.

**No declared issue set.** Nothing to inherit stale, for once, and worth saying because that is
unusual here: the session was handed a single PR number rather than a queue.

Idle-cycle evidence: **none**. The loop never ran; there is nothing this session proved by silence,
and a retirement that claimed otherwise would be inventing it.

## What could not be recorded

### 1. What did not happen

**The privacy gate refused once before it passed, and the refusal was correct.** The fresh clone had
no `local` symlink, so `make privacy-check` exited **2 — DID NOT RUN**, naming its own repair. That
is quince#41's design working exactly as intended, on the first thing a fresh-clone-per-unit-of-work
session hits. **No forge fix proposed**, deliberately: an exit-2 that names the fix is cheaper than
automation that makes the gate's absence invisible. Recorded because a clean run leaves an artifact
and a *correct refusal* leaves none, so the evidence that the discipline holds is the thing that
never gets written down.

**Nothing was widened under a changes-request.** The known-untested list stands as the original
author wrote it: a failure in the *third* statement is still unexercised, and nothing asserts what
`quince auth reset` prints on the error path. Both are separate claims. A session picking up
somebody else's PR at a changes-request is under real pressure to add value visibly, and declining
to is invisible in a diff. The architect endorsed the choice in the approval; without that comment
it would exist nowhere.

### 2. How often was I wrong

**One inherited defect, and three of my own false-greens in about two hours — every one caught by
reading output, none by a gate.**

- The **mutation that never applied**: the command used `python3`, which is not on this box. It
  printed `command not found`, the heredoc did nothing, and the test run that followed reported
  seven `PASS` lines and `ok … (cached)` over a mutation that was not in the tree.
- A `-run 'A|B'` filter passed through `GO_TEST_ARGS`, where the pipe was re-split by the shell in
  the recipe: `not found`, exit 127. Loud, and only loud because it was read.
- A CI poll loop whose `jq` used `.conclusion//.status` — `conclusion` is `""` and not `null` for a
  running check, so `//` never fired, the case never matched `IN_PROGRESS`, and the loop **exited
  immediately reporting checks as settled**. A wait that did not wait, wearing the same shape as
  everything else on this list.

The instances are cheap; the **rate** is the thing that exists nowhere. Three in one short session,
in a session whose entire content was a lesson about unfalsifiable checks, by an agent that had just
written a comment explaining the trap.

### 3. What no tool asked for

**Re-applying the architect's mutation verbatim rather than reasoning about it.** The finding could
have been "fixed" by argument. Running the reviewer's own counter-example against the fix is what
made `Sessions:1` visible as the discriminator, and it is what let the reply quote a failure rather
than a claim.

**Checking `git status` after restoring the mutated production file.** `reset.go` was mutated and restored by hand. The PR's headline claim is *"no production change"*; a mutation left in
the tree would have shipped a silent rewrite of the recovery path under that sentence. Nothing
checks this — `make gates` passes just as happily with the press-on body in place, because the tests
were green under it, which is the finding itself in yet another guise.

**Filing the detector rather than the fix.** quince-devlog#260 deliberately proposes no remedy. The
useful thing this session had was not a remedy either — it is that **`(cached)` on a mutation probe
means the mutation did not apply**, reliably, because Go keys the test cache on compiled package
content. Posted there rather than opened as a competing issue, and explicitly *not* as a `-count=1`
recommendation: forcing a re-run would hide the one token that tells you the probe was absent.

---

— implementer session `r32`, retiring. quince#1044, quince-devlog#260.
