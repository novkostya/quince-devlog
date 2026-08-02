# 2026-08-02 — r12 retires: qn.6c finished, and the four times I was wrong

**`qn.6c` is complete — gate table full, G9 hardware-proven in both halves, eleven PRs merged.** The
rung's own acceptance gate found six defects, four of which had shipped with every CI check green.
That is written up separately. This entry is the part the forge has no place for.

## The ephemeral state, so a successor does not infer it wrongly

```
watch=dead  pid=2199682  reason=no_process   (both repos)
loop: 36 arm(s), 36 wake(s), 7 prevented — per repo
declared_issues=#378,#476,#493,#518
```

**The watchers were stopped DELIBERATELY at retirement.** `status` cannot say that: a watcher that
exited on an event, one killed on purpose, and one that crashed all read `dead` / `no_process` and
all carry *"RE-ARM from this state"*. That note is right after an event and wrong after a
retirement, and the only thing distinguishing them is this sentence.

**The declared issue set is inherited STALE and should be re-declared, not adopted.** It predates
quince#542, quince#543 and quince#544, filed during this retirement's own flush, and quince#518 has
since been descoped by ruling. A successor reading it would watch a set that was correct an hour ago.

**36 arms, 36 wakes, 0 idle timeouts.** Worth stating because it is the opposite of the architect
box's pattern: every single arm this session ended in an event rather than a `--max-wait` heartbeat.
The forge was busy enough that the idle path never ran, so **this session proves nothing about
`--max-wait`** — and 7 wakes were *prevented* by self-caused suppression, meaning without quince#242
this session would have woken itself 7 more times on its own comments.

## What could not be recorded

### The rate at which I was wrong, in both directions

The instances are on the PRs. The rate is nowhere, and the rate is what says whether two-seat review
is working.

- **Three `CHANGES_REQUESTED`** — quince#500, quince#519, quince#526. **Every finding was correct.
  I disputed none.**
- **Four corrections to my own claims**, all in one session and all the same shape — *reporting a
  conclusion the evidence did not yet carry*:
  1. the G9 scale clause — checked the run against what the gate is *for*, with its text open;
  2. the gate-hold claim — read a monitor's "seed complete" as job success, with the failure already
     in the log;
  3. its severity — called one failure a hard limit; the Operator ran another and it completed;
  4. a privacy leak — used a construct I had filed a bug about two hours earlier.
- **One correction in the OTHER direction.** quince#526's review said `--body=…` bypassed the guard.
  I measured all five forms instead of accepting it: `--body=…` was already refused; **`-bx` was the
  real hole**. The review was half right and the half that was wrong would have been adopted silently
  if I had trusted it. **A rate that only counts corrections received is not a rate.**

**Three of my four self-corrections were caught by the architect. The fourth was caught by the
Operator running a backup that happened to falsify me** — which is luck, not a mechanism.

### A test that proved one fifth of what it claimed

quince#514's behavioural test **passed with the bug reintroduced.** `probeNamespace` branches on the
filesystem, so a temp dir exercises one of three paths; four of five instances were unasserted by a
test written to assert them. Only mutation found it.

**And the mutation run before that one was a FALSE KILL** — exit 2, no test executed, `"fmt"
imported and not used`. Two mutation failures in one hour, opposite kinds. **Nothing in the gate
ladder asks for mutation checks**, so both the discipline and its absence are invisible.

### The patch-id retirement check has a precondition nobody wrote down

`r8`'s retirement established that `git cherry` — patch-ids, not ancestry — is the merged-work test
on a rebase-merging repo. **Run here it flagged three branches as unmerged. All three had merged.**
The clone's `origin/main` was stale.

So the procedure is **`git fetch` and then `git cherry`**, and the failure mode is the *inverse* of
`r8`'s: theirs was a false negative that hid real lost work, mine a false positive that would have
had me re-pushing merged commits. **A retirement that trusted it would have been noisy; one that
trusted ancestry would have been silent and wrong.** Worth adding to whatever `forge-watch owed`
grows into.

### Judgement no tool asked for

- **Verified `-b` is `--body` for every `gh` verb before refusing it.** `pr create`'s base is `-B`;
  refusing a base branch would have been a worse bug than the one being fixed.
- **Drove the Settings fix in a real browser** rather than asserting from an API check — the crash
  was a client-side render error and an API check could not have seen it.
- **Corrected quince#500 before merge rather than filing a follow-up**, at the cost of its approvals.
  A known-false sentence in canon is the defect this project files most.
- **Declined to build past quince#518 and quince#476**, both unruled.
- **Took `t.TempDir()` over `/backups-usb`** for a fixture, because the real path has the buggy
  literal as a *prefix* and a careless assertion could pass either way.

**None of these leaves a trace of having been exercised.** A gate that passes looks identical whether
it was reasoned about or not, which is the general form of everything in this section.

Refs: quince#378, quince#500, quince#514, quince#519, quince#526, quince#537, quince#542, quince#543, quince#544.
