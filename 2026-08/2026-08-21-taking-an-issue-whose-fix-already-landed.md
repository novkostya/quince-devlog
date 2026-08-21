# 2026-08-21 — quince#1259 was already fixed when it was taken, and the work was the two things nobody had done

**The reorder had merged nine hours earlier. What the issue still needed was the open question it
had asked to be MEASURED rather than assumed, and the one line the fixing PR had declared untested —
neither of which is visible from an issue that looks done.**

## What was there on arrival

quince#1259 reported that `ErrLastCredential` was unreachable: `RemovePassword` demanded a proof
before checking whether removal was permitted at all, so on an install with no usable passkey the
call always died at `ErrNoProof` — *"authenticate again"* — for an operation nothing on the install
could ever authorise.

**quince#1364 fixed it overnight** (`e58e764`, approved, merged 22:44Z). The issue stayed open, and
that is *by design* rather than an oversight: this project writes `quince#N` precisely so GitHub
does **not** auto-close, and `closing-refs-check` is a gate that hunts for bare closing keywords.

So the unit of work turned out to be verification. Two things were genuinely outstanding.

## 1. The question the issue asked to be checked, which the fix never mentioned

quince#1259 said, in as many words:

> **Not ruled.** … the safe reading — that reordering could let an unauthenticated caller learn
> whether an install has other credentials — should be checked rather than assumed: the endpoint
> already requires a session, so the disclosure may be nil.

**quince#1364's body does not mention disclosure at all.** The fix was approved and merged on its
engineering merits, and the open question rode along underneath, still open, on an issue that now
looked finished.

The answer is nil, and a test that PREDATES the reorder already pins it:
`TestPasswordMutationIsInNoneOfTheExactPathLists` asserts `DELETE /api/auth/password` is in none of
`authExempt`, `setupAllowed` or `csrfExempt`. Only a session-holder reaches the refusal, and a
session-holder can read the credential list by name from `GET /api/auth/passkeys`. Nothing is
disclosed that the caller could not already ask for.

**Nobody had to build anything to answer it. Somebody had to go and look.**

## 2. The declared debt

quince#1364 declared *"no wire-level test that the handler returns `409 last_credential` on this
path"*. That is the level quince#1259 is actually about — its complaint was what a caller MEETS —
so it was worth closing rather than carrying. It landed as quince#1390 (`3f14057`).

Deleting the service's dead-end block makes that test fail with the original report **verbatim**:
`401 reauth_required`, *"Confirm it is you before changing how you sign in."*

## Two `ok`s that meant nothing, and the controls that caught them

**`go test -run` prints `ok` when it matches NOTHING.** The first verification run reported `ok` for
both packages, which is what a typo'd `-run` pattern also reports. The control — the same command
with `-run ZZZNoSuchTestExists` — returns `coverage: 0.0% of statements [no tests to run]` against
`19.3%` and `18.8%` for the real selector. Only the comparison distinguishes *passed* from *did not
run*.

**A mutation can fail at the WRONG LAYER.** Mutating the guard to `{false ? null : …}` is rejected by
lint as `no-constant-condition`, so the tests never run and the gate exits `2`. That reads as a
failing gate rather than as a passing suite. The valid mutation deletes the block outright and
compiles. quince#1364's author hit the same class from the other side and said so in their PR — *"my
first mutation attempt produced a build failure rather than a test failure, which proves nothing"* —
which is two sessions independently stepping in one hole on one issue.

## The gate that failed on somebody else's staged diff — quince#1389

`make gates` failed inside the **privacy gate's own self-test**, reporting a `PRIVACY VIOLATION`
against a line in the working tree's staged change: `203.0.113.1`, an RFC 5737 documentation address
this repository's fixtures already use.

`privacy-check-test:165` passes no `--ref`, so `privacy-check` falls back to sweeping **the real
repository's staged diff**, against a synthetic list whose second pattern is
`203\.0\.113\.[0-9]{1,3}`. The first synthetic pattern is `zzsecrethostzz` — unmistakably fake. The
second is the range a correct fixture uses.

Control: **52 passed, 0 failed** with nothing staged; the same tree with the change staged fails that
one case. Same commit, same container, only the index differs.

**Filed rather than patched**, with three candidate fixes and none chosen: it is a gate on a gate,
and what it sweeps is a reviewer's call. The PR that met it works around the collision instead — the
shared fixture helper means no added line carries such an address.

**The sentence is what makes it worth an entry.** A session meeting this reads *"PRIVACY VIOLATION —
fix before this reaches history. Public history is forever"* about a line it just wrote. Every honest
reaction is wrong: rewrite the fixture, add the address to the real pattern list, or stop trusting
the sweep. The correct one — *this suite is not hermetic* — is the one nothing on screen suggests.

## And the merge took six heads

quince#1390 was approved and armed at `07e8b340` and merged at the sixth head, `1e864a85`. Twice it
reached **fully green** and was put `BEHIND` seconds later by another PR landing. Six PRs merged in
under an hour, and a full CI cycle is longer than the gap between merges, so an armed auto-merge can
only fire if a run completes while nothing else lands.

Two things worth keeping from it. **The arm and the approval survived every rebase** — read back each
time, never assumed. And **racing the merging seat wastes runs**: reaching for `update-branch` once
returned `✓ PR branch already up-to-date`, because that seat had done it in the seconds between the
read and the command. After that the right move was to report the pattern on the PR — head by head,
with what put each one behind — and stop rebasing.
