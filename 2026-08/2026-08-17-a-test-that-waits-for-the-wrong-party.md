# 2026-08-17 — a test that waits for the wrong party

**`waitTerminal` waits on the engine's own job row. The assertion two lines later reads a map filled by
a different goroutine, and nothing orders the two. Starve that goroutine and the test fails 36% of the
time — which is what a loaded CI runner does to it.** quince#1115, fixed in quince#1120.

The issue arrived **already diagnosed**, by a seat working the release pipeline under an explicit
Operator scoping, which named the race, named the trap, wrote the five-line patch and then declined to
widen into a package it had no business in. That is the whole of the good outcome here: the expensive
part was the reading, it was done by whoever happened to trip over it, and it was written down where the
next seat would find it rather than fixed in passing.

**What it could not do was reproduce it** — *"5/5 green locally; the diagnosis is from reading, not from
a failing run I can re-run at will."* And that is one flag away: `go test -cpu=1` sets `GOMAXPROCS` for
the run, and a collector goroutine that only runs when the main goroutine yields loses the race
constantly. **54 failures in 150.** After the fix, 0 in 150 on the same flag.

**The instructive part is the three call sites that DIDN'T fail.** The same unsynchronised read appears
five times in that file, and the issue argued the other four were *"same latent bug, one exposed
instance"* while marking it unmeasured. Measured: 0/150 each, at the throttle that breaks the fifth
54 times. **They are not correct, they are lucky.** `seeding` and `waiting_for_passcode` are published
early, so the rest of the job supplies a happens-before nobody asked for; `done` is the last event before
an assertion that waits on its own publication, with zero slack. **A test whose ordering comes from
"there was other work afterwards" passes until the work gets shorter** — so all five were converted, and
the measurement went into the comment, because a future reader looking at three tests that never flaked
deserves to know why they were changed.

**And the near-miss worth recording: `waitSettled` is the trap.** It exists for exactly this shape
(quince#427 — *"a test that waits for terminal and immediately reads the announce is racing the
engine"*), so it is the obvious reach, and it waits for the **engine** to release the job — a different
unsynchronised party from the one that is actually unsynchronised. It would have narrowed the window and
left the race, converting a 36% flake into a rare one nobody could attribute. The helper that exists for
your bug's shape is not the same as the helper for your bug.

**A ruling landed today that closes a habit this project had built rather than decided: EVERY OPEN ISSUE
MUST BE ACTIONABLE.** Operator, on being told that quince#974's reporters had retired so no reply would
ever land — *"keep it open only if there's something we can do … otherwise I'd rather close, we can
reopen and file a new one if it reappears."*

What it kills is the **sentinel issue** — one held open as a durable note saying *if X recurs, it may not
be the cause you think*. Two instances died with it, both from the last fortnight: quince#644, held open
twice in writing after its mechanism was fixed because *"the window is still there; it is now merely
harmless"*, and quince#974/#975 on one unreproduced observation. The content did not vanish, it moved to
where a reader meets it — `killOutcome`'s comment and a deterministic guard test for the first,
`story12`'s context-carrying assertion for the second. **Nobody greps the tracker before editing a
function.** Recorded as quince-devlog#268, with the bound stated: this is not licence to close a hard
issue, or a live flake that still reddens PRs.

**quince#975 is the argument for it.** Left open with nothing to do, it became an *attractor*: three
sightings of an entirely different bug were filed into it because it was the nearest open thing that
looked similar, and the count on it was then wrong too. An open issue is never merely a note.

**One trap found by walking into it.** `gh pr update-branch --rebase` returns, and the state you read
next is mid-flight: `head` still the old oid, `mergeStateStatus=UNKNOWN`, and `reviewDecision` reading
**`REVIEW_REQUIRED` on a PR whose approval is intact.** Ten seconds later it is `APPROVED` and stable.
The obvious response to that first read is to go and ask the architect to re-approve — a round trip for a
verdict never lost — and canon's own *"a rebase does not necessarily dismiss the approval"* primes you to
believe the dismissal is the real answer. `strict: true` means every merge by anyone puts every open PR
`BEHIND`, so this read happens constantly. quince-devlog#269; the remedy is to poll until two reads agree,
which is the discipline canon already demands for reading back the arm.

**And the rebase treadmill is real rather than a nuisance.** quince#1120 was approved with auto-merge
armed while **`BEHIND`**, which under `strict: true` is an arm that can never fire — then went `BEHIND`
again when another PR merged underneath it. Two rebases, range-diff verified byte-identical both times,
and then the arm fired unattended. The mechanism works; what it costs is that somebody has to notice, and
the seat whose work is blocked is the one that will.
