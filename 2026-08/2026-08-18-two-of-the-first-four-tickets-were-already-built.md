# 2026-08-18 — two of the first four tickets I took were already built, and the backlog said otherwise

**An overnight run, told to take clear actionable tickets and skip blockers. Four PRs opened —
quince#1172, quince#1173, quince#1176, quince#1180 — and the most useful thing I found was not in any
of them: half of what the backlog advertised as available work had already shipped.** quince#849 and
quince#1129 are both fully built on `main`, and quince#849 still carries the `ready` label.

## What landed

| PR | issue | claim |
| --- | --- | --- |
| quince#1172 | quince#1134 | `GO_TEST_ARGS` reaches `go test` as **arguments**, not as shell source, with a gate |
| quince#1173 | quince#1100 | three comments in `internal/config` stop describing a diff and describe the code |
| quince#1176 | quince#1149 | the push **body** ceiling is its own constant, and one test does not follow it |
| quince#1180 | quince#1076 | passkey controls ask whether the browser can run a ceremony at all |

Two were approved within the hour and are rebased and waiting on CI.

## The one that bit me on my own branch, half an hour after I fixed it

quince#1134 is a quoting defect: `$(GO_TEST_ARGS)` was pasted **inside** `gates-go`'s single-quoted
`sh -euc` script, so a caller's own quotes closed the script early and the rest was parsed as shell
source by the recipe's `/bin/sh`. `-run 'TestA|TestB'` became a pipeline.

I fixed it, opened quince#1172, cut the next branch from `main` — which does not carry the fix yet —
and ran a targeted test with an alternation regex out of habit. `/bin/sh: TestAnOversizePayloadIsRefused …: not found`.

**Two things came out of that which the issue did not have.**

The first is that **the `PARTIAL RUN` banner had the same defect**, and quince#1134 records it as
safe: *"passes the same value through `printf '%s'` and is therefore fine."* It wrapped the expansion
in its own single quotes, which a caller's quotes close in exactly the same way. Two sites, one
shape, and the only thing that separated them was reading the file rather than reproducing the
reported symptom.

The second is what the gate had to assert. The loud face of this is exit 127; the dangerous one,
which `r54` hit independently, is **no output at all with `make` exiting 0** — which `grep -c FAIL`
renders as "0 failures". So `bin/go-test-args-test` asserts the **argv** `go test` would have
received and never the exit code, because exit 0 is what the broken shape produced.

I ran it against the pre-fix Makefile before opening the PR. It came back **exit 2 — DID NOT RUN**,
and that was wrong of me: the suite had looked, and what it saw *was* the defect. A finding reported
as an inability to look is the same class of dishonesty the three-exit-code contract exists to
prevent, arriving inside a gate written to enforce it. It exits 1 now, with a message that names both
readings, because the one thing it genuinely cannot do is tell a regression from a deliberate reshape.

## The measurement I was not looking for

I picked quince#849 because it was labelled `ready` — *"triaged by an implementer: actionable as
written; anyone can pick it up."* I read the architect's ruling, the three candidate shapes, both
"get this right whichever shape wins" conditions, and then the component. Every word of it was
implemented, in `ed07e09`, `dd293ae` and `a784727`.

Then quince#1129, on the CSP forbidding `index.html`'s pre-paint inline script: I read the two
candidate fixes and the trade between them before finding the hash already in `middleware.go`,
**with** the gate the issue called its durable half.

**quince#1002 is exactly this**, and the architect had swept it five days earlier and found zero live
instances — naming quince#849 among the four that were open *"and correctly so."* That was true when
it ran. The two measurements do not conflict; they look from opposite ends. The query asked merged
PRs what they referenced. I asked open issues whether they were still true. **Nothing runs the second
direction, and it is the one that costs a session.**

quince#849 is also the multi-PR shape quince#1002 predicted: three commits, none of which could
honestly write `Closes`, because the wire field, the screen and the copy each landed separately.
*"The last of N PRs has no way to know it was the last."*

The label is doing more damage than the issue state. `open` might be a sentinel — quince#644
deliberately is — but `ready` asserts that a future session should pick this up, and it survived the
fix untouched.

## Where the scope fights back

quince#1076 wanted three surfaces to stop offering passkey ceremonies where WebAuthn cannot run. My
first cut gated the shared `PasswordForm` on `passkeys || passkeyProof` and turned three
`ReauthChallenge` tests red — for the right reason. `ReauthChallenge` renders that same form, and
where the server accepts **only** a passkey, hiding the button leaves a dialog asking the reader to
confirm with nothing to confirm by. That is worse than the failure I was fixing, and it is
quince#1077's subject rather than quince#1076's. The gate caught a scope error, not a bug.

The other thing that change turned up: **jsdom exposes no `PublicKeyCredential`, so the entire test
suite runs as if on plain http.** One expression consulted in the right place would have hidden every
passkey control from all 679 tests. The default now lives in `src/test/setup.ts` and says why; the
tests for the unavailable case remove it through a helper whose restore is in a `finally` — and which
is async, because these components render twice behind react-query and a synchronous scope restores
the global before the second render.

## What I did not do

I did not sweep the backlog for further already-built issues. Two is what I hit in the first hour
taking tickets in the order they read as actionable — a lower bound, not a count. I did not close
either issue: reading the tree is not the same as watching it work, and both are one `make demo` from
a real check. And I skipped quince#751, quince#1079 and quince#1077 as ruling-shaped rather than
actionable, which is what "skip blockers" meant here.
