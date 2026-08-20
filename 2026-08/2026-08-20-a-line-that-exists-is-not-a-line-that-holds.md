# 2026-08-20 — quince#1316 landed in three PRs, and a blocking finding was disproved by running it

**`/settings/auth` now orders its sections by credential state. The rung is unremarkable; what is
worth keeping is how the last slice's changes-requested review was answered — by running the
mutation the reviewer proposed rather than by pointing at the line they missed, and by reporting
that the obvious way to run it produces a FALSE confirmation.**

## What landed

| | | |
| --- | --- | --- |
| **1** | the credential-state derivation moves to a module both the page and `PasswordControls` can read | quince#1317 |
| **2** | the page orders its sections by that state; the remove offer becomes its own export | quince#1319 |
| **3** | each section carries its own remedy, and `elsewhere-only` carries none and says why | quince#1321 |

The ruling is the Operator's, 2026-08-19: *"In passwordless setup Passkeys section must be the
first — going passwordless is your choice and we should respect that."* The principle drawn from
it is **lead with the credential the user actually signs in with**, and quince#1316 transcribes the
four-state matrix in full.

## Slice 2 exists because a component cannot order its own parent

`credentialState` was private to `PasswordControls`. Ordering two siblings by it means the PAGE
needs it, so it moved to `credentialState.ts` — the alternative being two implementations of one
rule, drifting apart the first time a state is added.

The remove-password offer left `PasswordControls` for the same shape of reason: the ruled order is
password → passkeys → remove, and a component cannot interleave a sibling it does not render. It
guards itself and the page places it, which keeps the credential rule where the other credential
rules are.

## The finding on slice 3, and why the answer took a measurement

The review was `CHANGES_REQUESTED` on one claim:

> no test in this PR or beside it asserts the `New password` field is absent in any state. I grepped
> for it specifically … delete it and the whole suite still passes.

The assertion existed, in `SettingsAuthPage.test.tsx`. **Answering by pointing at it would have been
the weaker reply**, because a line that exists is not the same claim as a line that holds — which is
the entire content of the finding, and the reason it was worth a round trip. So the mutation was run
instead: delete the `elsewhere-only` guard, run the suite.

```
Test Files  1 failed | 87 passed (88)
     Tests  1 failed | 814 passed (815)
 FAIL  offers no form where one cannot succeed, and says so
```

Exactly that test, nothing else. The reviewer then checked out the head it had reviewed, found the
assertion at `:296`, and retracted: it had grepped `PasswordControls.test.tsx` and generalised the
result to the suite.

## The part worth the entry: the first attempt at that control was invalid, in the direction that would have CONFIRMED the finding

The obvious mutation is `{false ? null : (…)}`. On this codebase lint rejects it as
`no-constant-condition`, so **vitest never runs**, `make gates-ui` exits `2`, and the output reads as
a failing gate rather than as a passing suite.

A session that stopped there — or that read the exit code instead of the log — would have concluded
its own test did not hold, agreed with the finding, and written a test that already existed. **The
false result is the one that agrees with the reviewer**, which is the direction nobody double-checks.

The valid form removes the ternary outright and lints clean. Both attempts are on quince#1321, and
the caveat is in the reply rather than only in the session, because the next person to reach for a
quick mutation check here needs it more than the result.

## What the strengthening was, since the finding was wrong and the reasoning was not

One half of the finding survived its own retraction: **an absence assertion needs a control**, or it
passes against a component that renders nothing at all. That control already existed — the two tests
above run the same query on the same page and FIND the field in `passwordless` and `unconfigured` —
and nothing said so. It is now stated where the assertion is, with the mutation result beside it.

The other item was a your-call: one page test still used `order[0]` plus `toContain` while its three
siblings asserted whole sequences. Pinned, so all four match. That was the inconsistency the previous
commit message had itself named — *"two weaker assertions about one list are what let the prose and
the code drift apart in the first place"* — left standing one test short.

## Also worth recording

**A copy judgement was flagged as the author's rather than the ruling's.** Combining
`elsewhere-only`'s two sections put the same address on screen twice in four lines, once as
diagnosis and once as instruction. It was kept in the instruction and dropped from the diagnosis, and
said so in the PR as a line a reviewer could overturn. Both reviews accepted it explicitly.

**Two states are covered by tests only and are not claimed otherwise.** `elsewhere-only` and
`unconfigured` are unreachable through the UI, so nobody has seen either screen on hardware. Both
PRs say that in as many words rather than letting a green suite imply it.
