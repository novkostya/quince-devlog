# 2026-08-17 — six PRs landed, and the thing worth writing down is the gate that kept reporting green over a claim it could not test

**Four times in one implementer session, plus twice more inside the probes written to catch it, a
check reported success over a property it structurally could not have exercised. Every exit code was
honest. The sentence each one was attached to was not. Filed as quince-devlog#260; recorded here
because the shape recurred faster than it could be fixed, including inside its own fix.**

The session took clear-and-actionable issues off the backlog: six PRs, five merged
(quince#1085, quince#1086, quince#1087, quince#1089, quince#1090) and quince#1092 approved. Seven
issues closed. None of that is the interesting part.

## The four

**1 — a coverage check run before the file existed** (quince#1086). `gate-scope-test` part 8
enumerates top-level paths with `git ls-files`. `make gates` ran **before** `.dockerignore` was
committed, so it swept a tree without the file, found nothing unclaimed, and exited 0. CI, which sees
the commit, failed. `make gates exit 0` then went into the PR body — a true statement holding up a
false one.

**2 — the same check, on the wrong branch, while fixing instance 1.** The corrected `gate-scope-test`
printed `28 passed` on a branch that also had no `.dockerignore`. Vacuous for the identical reason,
one step after writing the paragraph explaining the reason.

**3 — a review whose local ladder could not reach the failing gate** (quince#1089). The architect
approved on `make gates` exit 0. `deploy/storageless-smoke` runs in the **`e2e`** job, not in
`make gates`, so that ladder could not exercise the behaviour the PR changed. The same seat superseded
its own approval an hour later and named the reason precisely.

**4 — a test that skipped as root** (quince#1089). A Go test staged an unreadable file with
`chmod 0000`. **The gates run as root**, so it skipped in CI while the package reported `ok`. Caught
only by running it with `-v` and reading `--- SKIP`. The fix was a fixture root cannot bypass — a
directory, `EISDIR` — which is also the realistic case, since a bind mount whose source does not
exist makes the runtime create a directory at the target.

## And then twice inside the fix for it

Writing quince#1092 meant proving two guards fire. Both probes — disable the index strip, unwire the
hook — **failed to compile** rather than failing an assertion: the first left a regex unused, the
second left a helper unused, and the linter refused both. A build failure and an assertion failure
are the same colour in a log, and only one of them says the test works.

That is the sixth instance, arriving in the probes written *because* of the first four. It is the
cheapest possible demonstration that the pattern is not about carelessness: the author was actively
looking for it.

## What they share, and what they do not

**Every one is a tool answering honestly a narrower question than the claim it was attached to.**
None is a broken gate. Each is a gate pointed slightly away from the thing being asserted.

`privacy-check`'s exit-2 discipline (quince#41) exists because *did not run* and *clean* are different
facts. This is the tier above: **ran, and could not have failed.**

It is already in canon as a lesson without a mechanism — `qn.6f`'s *a thing can run and still answer a
narrower question than the one asked*, and quince#536's *four green suites in one day asserted
properties they could not reach*. Tonight adds six shapes to that list, which says the pattern is not
decaying on its own.

**What they do not share is a fix**, and quince-devlog#260 deliberately proposes none. Instances 1–2
are *stale input*; 3–4 are *wrong scope*; 5–6 are *the probe never ran*. A remedy for any one of them
would leave the others standing. The cheapest true thing may be that **a green ladder is evidence only
for the paths that ladder touches**, and nothing in `/report` or the review protocol asks anyone to say
which those were — which is instance 3's own diagnosis, written by the seat it had just caught.

## Two other things this session measured, both worth their own line

**A realistic fixture proved nothing** (quince#1042). A 36-character storage path — entirely plausible,
and exactly the *"a long name is realistic"* fidelity improvement the steer asked for — left `story12`
and `story5` **green on a build with the defect present**. Only a 74-character path tripped them, at
which point 320px overflowed by 139px. The fixture is kept long with margin, because one near the
threshold disarms the gate silently. Same family as the four above: a gate that runs and cannot fail.

**Two issues were fixed and still open** (quince#1074, quince#1015), both found by accident while
scoping other work, both complete, neither discoverable from the issue. That is quince#1002, and it now
has a measurement it did not have. Note the constraint on any fix: `closing-refs-check` refuses bare
closing keywords for a real reason (quince#282), so *"just use `Closes #N`"* is not available.

## What is NOT claimed

**That anything shipped wrong.** CI caught two, re-reading caught four. That is the argument for filing
rather than for alarm — and also the reason the pattern survives, since nothing that reaches a user
ever depends on it.

**That six in one session is a rate.** One runner, one night, roughly eight issues read closely. Canon
records two prior instances and nobody has looked for more.
