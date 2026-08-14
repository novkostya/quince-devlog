# quince journal

The development journal for [quince](https://github.com/novkostya/quince) — one file per entry,
newest first. **This branch is never merged into `main` and is never protected.** Entries are
pushed straight to it.

That shape is deliberate. A journal is append-only immutable events with no shared mutable state,
so a pull request per entry charges git's full coordination cost for a data structure that needs
none — which is what produced four collisions in three hours on the single-file journal, and two
entries still stranded in open PRs. Disjoint filenames make every concurrent append rebase cleanly.

Current state lives on `main`, not here: the one-line state and the per-rung dashboard in
[progress.md](https://github.com/novkostya/quince-devlog/blob/main/progress.md), and the decisions
log under [decisions/](https://github.com/novkostya/quince-devlog/tree/main/decisions).

## Appending an entry

**There are TWO routes onto this branch and only one of them is enforced.** Which one you take is
decided by your box, not by preference — read both before appending (quince-devlog#159).

### Route A — `git push`. The implementer boxes.

```sh
git checkout journal && git pull --rebase        # always; several runners append the same day
$EDITOR 2026-07/2026-07-30-a-short-slug.md       # <YYYY-MM>/<YYYY-MM-DD>-<short-slug>.md
bin/journal-index                                # regenerate this file
git add -A && git commit -m "journal: <the claim>"

# THE SWEEP IS NOT OPTIONAL. Nothing else stands between this branch and public history.
<your-quince-clone>/deploy/privacy/privacy-check --ref origin/journal...HEAD

git push origin journal                          # on rejection: pull --rebase, push again
```

`bin/pre-push-journal` enforces the sweep on this route rather than leaving it remembered; install
it once per clone with `bin/pre-push-journal --install`.

**A rejected push is ordinary, not a conflict.** `git pull --rebase` and push again: entries are
disjoint files, so the rebase never asks a human anything. Only `README.md` can collide, and it is
regenerated rather than merged — `bin/journal-index` after the rebase, always.

### Route B — the Git Data API. The architect box, which cannot push at all.

**Measured 2026-07-31: the arch box has no git credential helper, for any repository** — that seat
reads through `bin/gh-arch` / `bin/gh-review` and writes through REST, and `git push` has never been
part of how it works. So Route A's last line fails there with `could not read Username`, and the
seat that rules is the seat that cannot follow the documented flow. Recorded rather than left to be
rediscovered by a session that concludes its box is broken.

Commit locally and **sweep exactly as in Route A** — the gate runs against your local commit and is
unaffected by how the commit reaches the forge. Then:

```
POST  /repos/{R}/git/blobs      x2      the entry, and the regenerated README
POST  /repos/{R}/git/trees              base_tree = origin/journal^{tree}
POST  /repos/{R}/git/commits            parents   = [origin/journal]
PATCH /repos/{R}/git/refs/heads/journal
```

One clean commit with the correct author, rather than the two a pair of `PUT /contents` calls leaves.

> **`bin/pre-push-journal` DOES NOT COVER THIS ROUTE, and cannot.** There is no push, so there is no
> pre-push hook to intercept. **On Route B the sweep is manual and non-optional**, and nothing
> mechanical will stop you skipping it.

### What guards what, stated rather than implied

**The privacy gate is the only guard on this branch.** On `main` an entry passes a reviewer *and*
the gate; here there is no pull request, so there is no reviewer. Exit `0` is clean, `1` is a match,
and **`2` is DID NOT RUN and is never a clean result** — a clone with no `local` symlink cannot
sweep and must not append by either route.

**The hook is a guarantee about Route A, not about the branch.** quince-devlog#155 shipped it as
*"the only guard, enforced rather than remembered"*, and that sentence was true of the route it
guards and too broad about the branch. Closing the gap would need something that watches the ref
rather than the client — CI on this repository, which it deliberately does not have
(quince-devlog#156 raises that and does not answer it). Until then the asymmetry is visible here
instead of latent, which is the smaller half of the fix and the honest one.

## The entry shape

An H1 `# <date> — <the claim, one sentence>`, then what changed, what was proven, what is owed,
with the PR and issue numbers that carry it. The claim appears twice by design — once as the title
this index reads, once as the entry's own bold lead.

[Retired lettered ids `(a)`–`(do)`](letters.md) — resolved to the entries that mint them, for the
citations in canon and git history that still use them.

**349 entries · 2026-07-18 → 2026-08-15.** This file is generated — run `bin/journal-index` after every
append; `bin/journal-index --check` fails when it is stale.

## 2026-08

- **2026-08-15** — [five flake issues, and one of them was a flaky test](2026-08/2026-08-15-five-flake-issues-and-one-of-them-was-a-flaky-test.md)
- **2026-08-15** — [the gates were run, and the architect was wrong](2026-08/2026-08-15-the-gates-were-run-and-the-architect-was-wrong.md)
- **2026-08-15** — [two of the issues I picked up were already built](2026-08/2026-08-15-two-of-the-issues-i-picked-up-were-already-built.md)
- **2026-08-14** — [a comment described a move while the code enforced a state, and so did its test](2026-08/2026-08-14-a-comment-described-a-move-while-the-code-enforced-a-state.md)
- **2026-08-14** — [A ruling settled the policy and left the mechanism able to break it](2026-08/2026-08-14-a-ruling-settled-the-policy-and-left-the-mechanism-able-to-break-it.md)
- **2026-08-14** — [`blocked` can just mean wait, and the table is the part nobody checks](2026-08/2026-08-14-blocked-can-mean-wait-and-the-table-is-what-nobody-checks.md)
- **2026-08-14** — [the zfs ceremony worked end to end, and almost every instruction in it was wrong somewhere](2026-08/2026-08-14-the-ceremony-worked-and-every-instruction-in-it-was-wrong-somewhere.md)
- **2026-08-14** — [the escape hatch broke the proof that came after it](2026-08/2026-08-14-the-escape-hatch-broke-the-proof-that-came-after-it.md)
- **2026-08-14** — [the escape hatch was refused by a check guarding a different mistake](2026-08/2026-08-14-the-escape-hatch-was-refused-by-the-check-that-guards-a-different-mistake.md)
- **2026-08-14** — [the field that looked like it already answered was false exactly when it mattered](2026-08/2026-08-14-the-field-that-looked-like-it-already-answered-was-false-when-it-mattered.md)
- **2026-08-14** — [the fix read the exit code and threw away the sentence](2026-08/2026-08-14-the-fix-read-the-exit-code-and-threw-away-the-sentence.md)
- **2026-08-14** — [The guard was right, and nothing walked it back to the screen that calls it](2026-08/2026-08-14-the-guard-was-right-and-nothing-walked-it-back-to-the-screen.md)
- **2026-08-14** — [the write happened first, and nobody asked whether it had to](2026-08/2026-08-14-the-write-happened-first-and-nobody-asked-whether-it-had-to.md)
- **2026-08-13** — [the ruling took machinery out, and I replied to a pull request that had already merged](2026-08/2026-08-13-a-ruling-that-took-machinery-out-and-a-reply-to-a-pr-that-had-already-merged.md)
- **2026-08-13** — [deleting a config key quietly deletes whatever a test used it to prove](2026-08/2026-08-13-deleting-a-config-key-quietly-deletes-whatever-a-test-used-it-to-prove.md)
- **2026-08-13** — [I broke main with the defect I had spent the night documenting](2026-08/2026-08-13-i-broke-main-with-the-defect-i-had-spent-the-night-documenting.md)
- **2026-08-13** — [my e2e proved the button reported success, not that it copied](2026-08/2026-08-13-my-e2e-proved-the-button-reported-success-not-that-it-copied.md)
- **2026-08-13** — [r35 retires: what a night of ten PRs could not record](2026-08/2026-08-13-r35-retires-what-a-night-of-ten-prs-could-not-record.md)
- **2026-08-13** — [the copy button that cannot use the clipboard API](2026-08/2026-08-13-the-copy-button-that-cannot-use-the-clipboard-api.md)
- **2026-08-13** — [the error is chosen by the remedy, not by the cause](2026-08/2026-08-13-the-error-is-chosen-by-the-remedy.md)
- **2026-08-13** — [one removal path asked "will anything be left?" and the other asked nothing](2026-08/2026-08-13-the-guard-that-asked-will-anything-be-left-and-the-one-that-asked-nothing.md)
- **2026-08-13** — [the probe I wrote to confirm a line found a worse bug behind it](2026-08/2026-08-13-the-probe-i-wrote-to-confirm-a-line-found-a-worse-bug-behind-it.md)
- **2026-08-13** — [the copy offered a remedy the same screen refused to let the user follow](2026-08/2026-08-13-the-remedy-the-same-screen-refused-to-let-the-user-follow.md)
- **2026-08-13** — [the script had never been linted because of where it lived](2026-08/2026-08-13-the-script-had-never-been-linted-because-of-where-it-lived.md)
- **2026-08-13** — [Three pre-auth endpoints, three questions, and the one that looks like the answer is the wrong one](2026-08/2026-08-13-three-pre-auth-endpoints-three-questions-and-the-obvious-one-is-wrong.md)
- **2026-08-13** — [Three things looked live, none of them were, and each hid behind a different shape](2026-08/2026-08-13-three-things-that-looked-live-and-none-of-them-were.md)
- **2026-08-13** — [two issues in a row whose premise had gone stale, and only measuring caught it](2026-08/2026-08-13-two-issues-in-a-row-whose-premise-had-gone-stale.md)
- **2026-08-13** — [two reapers that cannot reap, and one merge rule that explains one of them](2026-08/2026-08-13-two-reapers-that-cannot-reap-and-one-merge-rule-that-explains-one-of-them.md)
- **2026-08-12** — [deleting a dialog orphaned two gates that were not about the dialog](2026-08/2026-08-12-deleting-a-dialog-orphaned-two-gates-that-were-not-about-it.md)
- **2026-08-12** — [every step of the reasoning was right, and the product still lied](2026-08/2026-08-12-every-step-of-the-reasoning-was-right-and-the-product-still-lied.md)
- **2026-08-12** — [the button on the screen that explains the problem erased the file](2026-08/2026-08-12-the-button-on-the-screen-that-explains-the-problem-erased-the-file.md)
- **2026-08-12** — [the fresh-install headline came back, and that was half the fix](2026-08/2026-08-12-the-fresh-install-headline-came-back-and-that-was-half-the-fix.md)
- **2026-08-12** — [Seven staging builds to fix one scroll: the header was not flickering, it was changing — and the device found every fault CI could not](2026-08/2026-08-12-the-header-was-not-flickering-it-was-changing-and-three-more-answers.md)
- **2026-08-12** — [the ruling said "warnings", the fix said "errors", and the condition was always "discarded"](2026-08/2026-08-12-the-ruling-said-warnings-the-fix-said-errors-and-the-condition-was-discarded.md)
- **2026-08-12** — [the screen could not tell the user which of two states they were in, so it said the true half](2026-08/2026-08-12-the-screen-could-not-tell-the-user-which-of-two-states-they-were-in.md)
- **2026-08-11** — [a rung that is BUILT and is not PROVEN, and the difference is one phone](2026-08/2026-08-11-a-rung-that-is-built-but-not-proven.md)
- **2026-08-11** — [I checked my guard by deleting what it guarded, and the same move found why somebody else's tool had never worked](2026-08/2026-08-11-i-checked-my-guard-by-deleting-what-it-guarded.md)
- **2026-08-11** — [nine green PRs, every gate passing, and a feature that could not work](2026-08/2026-08-11-nine-green-prs-and-a-feature-that-could-not-work.md)
- **2026-08-11** — [nine slices, and four guards that could not fail](2026-08/2026-08-11-nine-slices-and-four-guards-that-could-not-fail.md)
- **2026-08-11** — [the ruling was the bug, and writing the spec is what found it](2026-08/2026-08-11-the-ruling-was-the-bug.md)
- **2026-08-11** — [writing it down found the bug twice in one rung, at two different altitudes](2026-08/2026-08-11-writing-it-down-found-the-bug-twice-in-one-rung.md)
- **2026-08-10** — [a gate nobody can run looks exactly like a deferred one from `main`](2026-08/2026-08-10-a-gate-nobody-can-run-looks-like-a-deferred-one.md)
- **2026-08-10** — [a handoff is a snapshot, and every item in it has a date](2026-08/2026-08-10-a-handoff-is-a-snapshot-and-every-item-in-it-has-a-date.md)
- **2026-08-10** — [four PRs on one gate, and why it was not thrash](2026-08/2026-08-10-four-prs-on-one-gate-and-why-it-was-not-thrash.md)
- **2026-08-10** — [`ok` and `not_migrated` had never been observed anywhere, and now they have](2026-08/2026-08-10-ok-and-not-migrated-had-never-been-seen-anywhere.md)
- **2026-08-10** — ["physical" means four different things, and on reflink it means nothing per-file](2026-08/2026-08-10-physical-means-four-different-things.md)
- **2026-08-10** — [retirement record, arch1: I enforced one rule all night and broke it once, on the only claim I did not run](2026-08/2026-08-10-retirement-record-arch1-i-broke-the-rule-i-enforced-all-night-once.md)
- **2026-08-10** — [retirement record, `r21`: every error I caught in myself, I caught by running something](2026-08/2026-08-10-retirement-record-r21-every-error-i-caught-in-myself-i-caught-by-running-something.md)
- **2026-08-10** — [quince has now been deployed with Docker, and the file that documents it fails at its first line](2026-08/2026-08-10-the-first-docker-deployment-of-quince.md)
- **2026-08-10** — [the fixture caught the coupling the review predicted](2026-08/2026-08-10-the-fixture-caught-the-coupling-the-review-predicted.md)
- **2026-08-10** — [the gate matched the token and never the link](2026-08/2026-08-10-the-gate-matched-the-token-and-never-the-link.md)
- **2026-08-10** — [the guard landed where the leak was, not where the bug was](2026-08/2026-08-10-the-guard-landed-where-the-leak-was-not-where-the-bug-was.md)
- **2026-08-10** — [the hardlink seed is unsafe through exactly one `idevicebackup2` call, and a class list cannot bound it](2026-08/2026-08-10-the-hardlink-seed-is-unsafe-through-exactly-one-call.md)
- **2026-08-10** — [the key outlived its second value, because deleting it would have downgraded a refusal to a shrug](2026-08/2026-08-10-the-key-outlived-its-second-value.md)
- **2026-08-10** — [`-tags lab` has not compiled on `main`, so gate 12's harness could not be run at all](2026-08/2026-08-10-the-lab-tag-has-not-compiled-for-some-time.md)
- **2026-08-10** — [the op said "done" before it was readable](2026-08/2026-08-10-the-op-said-done-before-it-was-readable.md)
- **2026-08-10** — [the reflink probe tested independence, and a full copy passes that identically](2026-08/2026-08-10-the-reflink-probe-was-testing-the-wrong-property.md)
- **2026-08-10** — [the rule caught it where the reviewer did not](2026-08/2026-08-10-the-rule-caught-it-where-the-reviewer-did-not.md)
- **2026-08-10** — [the sort I re-keyed was holding up a button nobody mentioned](2026-08/2026-08-10-the-sort-i-re-keyed-was-holding-up-a-button.md)
- **2026-08-10** — [three times in one session I named a mechanism I had not measured](2026-08/2026-08-10-three-times-i-named-a-mechanism-i-had-not-measured.md)
- **2026-08-10** — [two descriptions of one set, and only one of them got corrected](2026-08/2026-08-10-two-descriptions-of-one-set-and-only-one-got-corrected.md)
- **2026-08-09** — [a citation check found the same defect one door earlier, and nobody was looking for it](2026-08/2026-08-09-a-citation-check-found-the-same-defect-one-door-earlier.md)
- **2026-08-09** — [a guard that misses its own headline example, twice, and the tag nobody thought to grep for](2026-08/2026-08-09-a-guard-that-misses-its-own-headline-example.md)
- **2026-08-09** — [a guard written for one specific failure did not detect that failure, and said it did](2026-08/2026-08-09-a-guard-that-reported-coverage-it-did-not-have.md)
- **2026-08-09** — [a scope check on nothing was answering "not needed"](2026-08/2026-08-09-a-scope-check-on-nothing-was-answering-not-needed.md)
- **2026-08-09** — [the correction rate, counted in both directions, and one shape that caught all four seats](2026-08/2026-08-09-arch1-retires-the-correction-rate-in-both-directions.md)
- **2026-08-09** — [four explanations produced from source, three of them wrong, and the instrument that ended it](2026-08/2026-08-09-four-explanations-from-source-three-wrong-and-the-instrument-that-ended-it.md)
- **2026-08-09** — [`qn.6i`: reconciliation went async, and the rung corrected its own spec three times](2026-08/2026-08-09-qn6i-the-rung-corrected-its-own-spec-three-times.md)
- **2026-08-09** — [retirement record, `arch1`: the reviewer was wrong as often as the authors, and four of six times somebody else measured it](2026-08/2026-08-09-retirement-record-arch1-the-reviewer-was-wrong-as-often-as-the-authors.md)
- **2026-08-09** — [retirement record, `r19`: four guards passed on first run and were wrong](2026-08/2026-08-09-retirement-record-r19-four-guards-passed-first-run-and-were-wrong.md)
- **2026-08-09** — [the cancel that arrived before the process, and was called a failure](2026-08/2026-08-09-the-cancel-that-arrived-before-the-process.md)
- **2026-08-09** — [the key is always the same size, and the clock does not tick that fast](2026-08/2026-08-09-the-key-is-always-the-same-size-and-the-clock-does-not-tick-that-fast.md)
- **2026-08-09** — [canon told authors to rebase onto a branch the merge procedure had already deleted](2026-08/2026-08-09-the-recipe-named-a-ref-its-own-merge-procedure-deletes.md)
- **2026-08-09** — [`qn.6j` shipped in five PRs, and three of its own guards caught it being wrong](2026-08/2026-08-09-the-rung-that-kept-catching-itself.md)
- **2026-08-09** — [the staleness check was vacuous in the case canon calls safe](2026-08/2026-08-09-the-staleness-check-was-vacuous-in-the-case-canon-calls-safe.md)
- **2026-08-08** — [a real ZFS dataset answered four unprovable questions and asked a fifth nobody had](2026-08/2026-08-08-a-real-dataset-answered-four-questions-and-asked-a-fifth.md)
- **2026-08-08** — [H1 passed, and I was wrong five times getting there; every correction came from a command, never from a better theory](2026-08/2026-08-08-h1-passed-and-i-was-wrong-five-times-getting-there.md)
- **2026-08-08** — [Retirement record, runner `r2`: the Operator caught every empirical error and the architect caught every documentary one, which is a fact about seats that exists nowhere on the forge](2026-08/2026-08-08-retirement-record-r2-the-operator-caught-every-empirical-error.md)
- **2026-08-08** — [the linter decided what the spec had scheduled, and the spec was wrong about its own diff twice](2026-08/2026-08-08-the-linter-decided-what-the-spec-had-scheduled.md)
- **2026-08-08** — [the rung was taken for latency and paid 4.4× in disk, and the Operator was right twice while I was wrong twice](2026-08/2026-08-08-the-rung-was-taken-for-latency-and-paid-in-disk.md)
- **2026-08-07** — [I measured the thing next to the thing, inside a block headed MEASURED, NOT RECALLED](2026-08/2026-08-07-i-measured-the-thing-next-to-the-thing.md)
- **2026-08-07** — [re-reading finds one of my two errors, and it is not the expensive one](2026-08/2026-08-07-re-reading-finds-one-of-my-two-errors.md)
- **2026-08-07** — [the announcement outlived the work](2026-08/2026-08-07-the-announcement-outlived-the-work.md)
- **2026-08-07** — [the argument against the fix was never measured](2026-08/2026-08-07-the-argument-against-the-fix-was-never-measured.md)
- **2026-08-07** — [the assertion was absent from a branch that never rendered](2026-08/2026-08-07-the-assertion-was-absent-from-a-branch-that-never-rendered.md)
- **2026-08-07** — [the fix amended the citation, not the target, three times running](2026-08/2026-08-07-the-fix-amended-the-citation-not-the-target.md)
- **2026-08-07** — [the gaps I declared were the ones holding the bugs](2026-08/2026-08-07-the-gaps-i-declared-were-the-ones-holding-the-bugs.md)
- **2026-08-07** — [the gate was true and the behaviour was wrong](2026-08/2026-08-07-the-gate-was-true-and-the-behaviour-was-wrong.md)
- **2026-08-07** — [the split was the artifact, not the tool](2026-08/2026-08-07-the-split-was-the-artifact-not-the-tool.md)
- **2026-08-07** — [the table was stale before it was written](2026-08/2026-08-07-the-table-was-stale-before-it-was-written.md)
- **2026-08-07** — [what session r17 could not file anywhere](2026-08/2026-08-07-what-a-retirement-cannot-file.md)
- **2026-08-06** — [only the unit test caught the order-blind applier](2026-08/2026-08-06-only-the-unit-test-caught-the-order-blind-applier.md)
- **2026-08-04** — [four ways a check can fail to check, and the two that matter announce nothing](2026-08/2026-08-04-four-ways-a-check-can-fail-to-check-and-two-of-them-are-silent.md)
- **2026-08-04** — [the assertion got the right answer by a route that did not depend on what it claimed to measure](2026-08/2026-08-04-the-assertion-got-the-right-answer-by-a-route-that-did-not-test-it.md)
- **2026-08-04** — [I claimed a check was green without reading it, and the correction I posted was wrong in the other direction, from the same root](2026-08/2026-08-04-the-correction-was-wrong-in-the-other-direction-from-the-same-root.md)
- **2026-08-04** — [the defect existed only in the pair, so no single machine's log contained it](2026-08/2026-08-04-the-defect-existed-only-in-the-pair.md)
- **2026-08-04** — [the rule was already in the repo, three times, and the bug was that nobody had propagated it](2026-08/2026-08-04-the-rule-was-already-in-the-repo-three-times.md)
- **2026-08-04** — [The public demo went live, and a working `Secure` cookie was not evidence about the header next to it](2026-08/2026-08-04-the-working-flag-was-not-evidence-about-the-adjacent-one.md)
- **2026-08-04** — [the zoom was a ratio, not a threshold, and reading WebKit is what turned a rule into a number](2026-08/2026-08-04-the-zoom-was-a-ratio-not-a-threshold.md)
- **2026-08-04** — [two mutations, because one would have left the dangerous reading unproven](2026-08/2026-08-04-two-mutations-because-one-would-have-left-the-dangerous-reading-unproven.md)
- **2026-08-03** — [a forced command discards your flags and exits zero](2026-08/2026-08-03-a-forced-command-discards-your-flags-and-exits-zero.md)
- **2026-08-03** — [a merged spec is not a green light: the `qn.6d` park survived its own PR merging](2026-08/2026-08-03-a-merged-spec-is-not-a-green-light.md)
- **2026-08-03** — [The public demo took four deploys to come up, and every failure accused something that was fine](2026-08/2026-08-03-four-failures-that-each-blamed-the-wrong-thing.md)
- **2026-08-03** — [I gated the failure I had called the cheaper one](2026-08/2026-08-03-i-gated-the-failure-i-had-called-the-cheaper-one.md)
- **2026-08-03** — [The public demo became deployable, and the setting that would have silently broken its reset is one word](2026-08/2026-08-03-one-toml-word-would-have-broken-the-reset-silently.md)
- **2026-08-03** — [staging was behind by more than a day, and nothing could say so](2026-08/2026-08-03-staging-was-behind-by-more-than-a-day-and-nothing-said-so.md)
- **2026-08-03** — [the lesson did not survive a second call site](2026-08/2026-08-03-the-lesson-did-not-survive-a-second-call-site.md)
- **2026-08-03** — [the router cleaned the path and the POST came back as a 404](2026-08/2026-08-03-the-router-cleaned-the-path-and-the-post-came-back-as-a-404.md)
- **2026-08-03** — [writing the `qn.6d` spec found two live defects and a gate that could not have passed honestly](2026-08/2026-08-03-the-spec-found-two-defects-and-one-gate-that-could-not-pass.md)
- **2026-08-03** — [the warning is the deliverable, the schedule is the detail](2026-08/2026-08-03-the-warning-is-the-deliverable-the-schedule-is-the-detail.md)
- **2026-08-03** — [`qn.6d` shipped stories 1–8, and one Operator screenshot falsified two of its own ruled decisions](2026-08/2026-08-03-two-fields-were-wrong-and-a-screenshot-found-both.md)
- **2026-08-02** — [I leaked, the reviewer re-leaked quoting my report of it, and underneath sat a surface nobody had ever swept](2026-08/2026-08-02-a-leak-i-caused-a-leak-i-propagated-and-a-surface-with-no-gate.md)
- **2026-08-02** — [a required push destroyed the scarcest approval in the project, and in doing so ran the one experiment quince#455 asked for](2026-08/2026-08-02-a-push-that-answered-a-question-by-destroying-an-approval.md)
- **2026-08-02** — [a ruling can go stale before it is written down, and it did three times in one night](2026-08/2026-08-02-arch1-retires-a-ruling-can-go-stale-before-it-is-written-down.md)
- **2026-08-02** — [arch1 retires: my instruments failed as often as the authors', and the review worked anyway](2026-08/2026-08-02-arch1-retires-my-instruments-failed-as-often-as-the-authors.md)
- **2026-08-02** — [arch1 retires: the staleness defect hit eight times in one day, and the eighth was the table about keeping up](2026-08/2026-08-02-arch1-retires-the-staleness-defect-eight-times.md)
- **2026-08-02** — [the public-demo spec merged, after the same option set in two documents diverged inside an hour](2026-08/2026-08-02-one-option-set-two-documents-diverged-in-an-hour.md)
- **2026-08-02** — [r1 retires: the rate at which I was wrong, and four other things the forge cannot hold](2026-08/2026-08-02-r1-retires-what-the-forge-has-no-place-for.md)
- **2026-08-02** — [pinning a known limitation as a passing test asserts nothing until you add the counterfactual](2026-08/2026-08-02-r10-a-pinned-limitation-needs-a-counterfactual.md)
- **2026-08-02** — [declining to decide was not the safe answer, and my own rule had already decided it](2026-08/2026-08-02-r10-declining-to-decide-was-not-the-safe-answer.md)
- **2026-08-02** — [three fixes in one night, and the only evidence any of them worked was a failing mutant](2026-08/2026-08-02-r10-the-evidence-was-always-a-failing-mutant.md)
- **2026-08-02** — [I built a gate for a defect class, and the gate shipped with that exact defect](2026-08/2026-08-02-r10-the-gate-had-the-defect-it-was-written-to-catch.md)
- **2026-08-02** — [I labelled an in-session answer "Operator-ruled", and the reviewer searched for it](2026-08/2026-08-02-r11-a-citation-nobody-can-follow.md)
- **2026-08-02** — [qn.6f was scoped, specced, and had every one of its gaps ruled in one morning](2026-08/2026-08-02-r11-eleven-rulings-in-one-morning.md)
- **2026-08-02** — [qn.6f from a merged spec to G7 passed, in one day, and the defect that ran through all of it](2026-08/2026-08-02-r11-qn6f-start-to-passed-in-a-day.md)
- **2026-08-02** — [running a test is not the same as entering its branch](2026-08/2026-08-02-r11-running-a-test-is-not-entering-its-branch.md)
- **2026-08-02** — [the settled design named the wrong function, and only the setup path showed it](2026-08/2026-08-02-r11-the-fix-was-in-the-wrong-function.md)
- **2026-08-02** — [the obvious place for the TLS check is where it silently downgrades](2026-08/2026-08-02-r11-the-obvious-place-for-the-check-was-the-bug.md)
- **2026-08-02** — [making one TS field required found a bug that would have turned a security setting back off](2026-08/2026-08-02-r11-three-slices-and-what-the-type-system-caught.md)
- **2026-08-02** — [two of qn.6f's gaps ruled the same morning, and flipping one broke the gate on the other](2026-08/2026-08-02-r11-two-rulings-and-a-gate-that-broke-its-neighbour.md)
- **2026-08-02** — [r12 retires: qn.6c finished, and the four times I was wrong](2026-08/2026-08-02-r12-retires-the-rate-and-the-stale-ref.md)
- **2026-08-02** — [The schema change had a behaviour change inside it, and the tests would have passed either way](2026-08/2026-08-02-r12-the-behaviour-hiding-in-a-schema-change.md)
- **2026-08-02** — [The value the Operator wanted removed was the only thing checking the other values](2026-08/2026-08-02-r12-the-default-was-the-only-check.md)
- **2026-08-02** — [Code and canon agreed with each other, and both disagreed with the ruling](2026-08/2026-08-02-r12-the-drift-no-gate-can-see.md)
- **2026-08-02** — [G9 ran, and the rung's own gate found six defects that fixtures never could](2026-08/2026-08-02-r12-the-gate-that-found-six-defects.md)
- **2026-08-02** — [`r7` retires: eleven PRs, and the things that could not be filed anywhere](2026-08/2026-08-02-r7-retires.md)
- **2026-08-02** — [r8 retires: qn.6c's code shipped, and the retirement check found work that had been lost](2026-08/2026-08-02-r8-retires-the-rung-shipped-and-the-check-that-found-what-was-lost.md)
- **2026-08-02** — [the demo work's best output was a shipping-product fix, and the second-best was discovering the issue I had filed was wrong](2026-08/2026-08-02-the-demo-found-a-shipping-defect-and-the-issue-i-filed-was-wrong.md)
- **2026-08-02** — [the public demo's surface review found a 64 MiB pre-auth amplifier in the shipping product, not in the demo](2026-08/2026-08-02-the-demo-surfaced-a-product-defect-not-a-demo-one.md)
- **2026-08-02** — [the proxy fix landed, and the deployment that needed it cannot use it](2026-08/2026-08-02-the-fix-cannot-reach-the-deployment-that-needs-it.md)
- **2026-08-02** — [the public-demo spec reached a settings bin D12 does not have, and stopped there](2026-08/2026-08-02-the-spec-reached-a-bin-d12-does-not-have.md)
- **2026-08-01** — [A security word was doing a policy's work, and nobody had weighed the policy](2026-08/2026-08-01-a-security-word-was-doing-a-policys-work.md)
- **2026-08-01** — [A watch armed cleanly and saw nothing, and the guard for it broke two suites on the way in](2026-08/2026-08-01-a-watch-armed-cleanly-and-saw-nothing.md)
- **2026-08-01** — [An approval could name code nobody had read, and the check against it compared a commit to itself](2026-08/2026-08-01-an-approval-named-code-nobody-had-read.md)
- **2026-08-01** — [I modelled version skew in a project that had ruled it does not exist](2026-08/2026-08-01-i-modelled-version-skew-in-a-project-that-ruled-it.md)
- **2026-08-01** — [I was authorized, and could not prove it](2026-08/2026-08-01-i-was-authorized-and-could-not-prove-it.md)
- **2026-08-01** — [one slot cannot tell two resolvers apart](2026-08/2026-08-01-one-slot-cannot-tell-two-resolvers-apart.md)
- **2026-08-01** — [The bug was fixed in a spec and proven in a container, eight PRs apart](2026-08/2026-08-01-the-bug-was-fixed-in-a-spec-and-proven-in-a-container.md)
- **2026-08-01** — [The flake was a production bug, and the harness had already said so in a comment](2026-08/2026-08-01-the-flake-was-a-production-bug-and-the-harness-had-said-so.md)
- **2026-08-01** — [The guard knew one of the two ways to set a variable, and the one it missed was worse](2026-08/2026-08-01-the-guard-knew-one-of-the-two-ways-to-set-it.md)
- **2026-08-01** — [The healthy path was judged by a clock nobody owned](2026-08/2026-08-01-the-healthy-path-was-judged-by-a-clock-nobody-owned.md)
- **2026-08-01** — [The invariant was defended at one door, and the demo world walked in through the other](2026-08/2026-08-01-the-invariant-was-defended-at-one-door.md)
- **2026-08-01** — [Nine green assertions were measuring the stub's tolerance, not the forge's behaviour](2026-08/2026-08-01-the-suite-was-measuring-the-stubs-tolerance.md)
- **2026-08-01** — [The third seat can act under its own name, and every control that should have noticed it still described two](2026-08/2026-08-01-the-third-seat-acts-under-its-own-name.md)
- **2026-08-01** — [Three tests, one blind spot, three different fixes](2026-08/2026-08-01-three-tests-one-blind-spot-three-different-fixes.md)

## 2026-07

- **2026-07-31** — [A fixture that passes may mean the decision was right, or that the fixture does not depend on it, and only a one-at-a-time revert separates them](2026-07/2026-07-31-a-fixture-that-passes-may-mean-the-decision-was-right.md)
- **2026-07-31** — [An epic nobody could start, because its prose said "redesign" where the code said "parameter"](2026-07/2026-07-31-an-epic-nobody-could-start-because-its-prose-said.md)
- **2026-07-31** — [Every UI defect in qn.7 was found by clicking, and every one of my tests was green](2026-07/2026-07-31-every-ui-defect-in-the-rung-was-found-by-clicking.md)
- **2026-07-31** — [I made the same mistake I had just written up, one layer down, in the same rung](2026-07/2026-07-31-i-made-the-same-mistake-i-had-just-written-up.md)
- **2026-07-31** — [I read an absent disk as a new one, because I defined creation from what was there](2026-07/2026-07-31-i-read-an-absent-disk-as-a-new-one-because-i-defined.md)
- **2026-07-31** — [I wrote down the reason, and still applied it out of scope](2026-07/2026-07-31-i-wrote-down-the-reason-and-still-applied-it-out-of.md)
- **2026-07-31** — [Ruling the property found four defects where naming the instance would have found one, and the reviewer's own claims outran his evidence three times in the same night](2026-07/2026-07-31-ruling-the-property-found-four-defects-where-naming-the.md)
- **2026-07-31** — [Six issues taken after the migration, and every review finding against the session was one shape: a claim scoped wider than what was measured](2026-07/2026-07-31-six-issues-taken-after-the-migration-and-every-finding.md)
- **2026-07-31** — [Success and unverifiability were the same event, and the op reported the opposite of what happened](2026-07/2026-07-31-success-and-unverifiability-were-the-same-event.md)
- **2026-07-31** — [The 267-line "one-line state" is relocated here verbatim, because the block's own text says why deleting it would be wrong](2026-07/2026-07-31-the-267-line-one-line-state-relocated-verbatim-when-the.md)
- **2026-07-31** — [The empty constant that had to stay empty, and the three gates that each caught something review would not have](2026-07/2026-07-31-the-empty-constant-that-had-to-stay-empty.md)
- **2026-07-31** — [The guess was right, and checking it was still right](2026-07/2026-07-31-the-guess-was-right-and-checking-it-was-still-right.md)
- **2026-07-31** — [The hypothesis the roadmap told us to verify was wrong in two places, and checking cost twenty minutes](2026-07/2026-07-31-the-hypothesis-the-roadmap-told-us-to-verify-was.md)
- **2026-07-31** — [The journal left `progress.md` for a branch, and the first entry written under the new shape is this one](2026-07/2026-07-31-the-journal-left-progress-md-for-a-branch.md)
- **2026-07-31** — [The rung was rewritten and the rewrite found six items with nowhere to go](2026-07/2026-07-31-the-rung-was-rewritten-and-the-rewrite-found-six.md)
- **2026-07-31** — [Three defects behind one screenshot, and a fix verified in the one place it could not fail](2026-07/2026-07-31-three-defects-behind-one-screenshot-and-a-fix.md)
- **2026-07-30** — [`2>/dev/null` on a command does not cover the SHELL's own redirection error, and the liveness probe leaked one into every `Stop`](2026-07/2026-07-30-2-dev-null-on-a-command-does-not-cover-the-shell-s-own.md)
- **2026-07-30** — [A classifier outage is a DEGRADED session, not a broken box or a finished one — ruled, after it cost the architect seat six and a half hours of unwatched queue](2026-07/2026-07-30-a-classifier-outage-is-a-degraded-session-not-a-broken.md)
- **2026-07-30** — [A closing keyword beside a bare reference auto-closes on merge, the parser is not negation-aware, and FOUR instances in one night were each written by someone who knew](2026-07/2026-07-30-a-closing-keyword-beside-a-bare-reference-auto-closes.md)
- **2026-07-30** — [A counter answered two different questions in identical words, and it fooled the seat that had read the declaration and approved it — within the hour](2026-07/2026-07-30-a-counter-answered-two-different-questions-in-identical.md)
- **2026-07-30** — [A fix answered the right question about the wrong field, and the regression it caused was found by the seat that approved it — four hours later, on itself](2026-07/2026-07-30-a-fix-answered-the-right-question-about-the-wrong-field.md)
- **2026-07-30** — [A gate that containerises its work and prints an accounting line reported `clean` over a suite with fifteen failing assertions — and the accounting line was what swallowed the…](2026-07/2026-07-30-a-gate-that-containerises-its-work-and-prints-an.md)
- **2026-07-30** — [A ruling seven hours old went unread because only the issue BODY was fetched, and the tool caught it rather than the care](2026-07/2026-07-30-a-ruling-seven-hours-old-went-unread-because-only-the.md)
- **2026-07-30** — [A skill can carry its own fix and be unable to apply it: `/architect` §1 said "declare first, before anything reads or writes state", and §0 ran first and read state](2026-07/2026-07-30-a-skill-can-carry-its-own-fix-and-be-unable-to-apply-it.md)
- **2026-07-30** — [Branch-ownership suppression is role-dependent, and the fix for one direction opened its exact inverse](2026-07/2026-07-30-branch-ownership-suppression-is-role-dependent-and-the.md)
- **2026-07-30** — [`provision` mapped a ROLE to a FILE, the file stopped existing when the identity moved, and the private-layer section went inert on a live box — kept working only by an…](2026-07/2026-07-30-provision-mapped-a-role-to-a-file-the-file-stopped.md)
- **2026-07-30** — [Retirement record, runner `r4` — 11 PRs merged across both repos, five defects caught by the reviewer, six corrections made to the record in the other direction, and `0…](2026-07/2026-07-30-retirement-record-runner-r4-11-prs-merged-across-both.md)
- **2026-07-30** — ["Run it in the background" was not enough, and the reviewer's own correction to the fix is the better half of it](2026-07/2026-07-30-run-it-in-the-background-was-not-enough-and-the.md)
- **2026-07-30** — [Ten fixes in one overnight run, and the three that recur are all one shape: a check that reports on a scope narrower than the word it prints](2026-07/2026-07-30-ten-fixes-in-one-overnight-run-and-the-three-that-recur.md)
- **2026-07-30** — [The architect box's seat identity rested entirely on a credential its own code comment called luck, and the comment had been read and left standing](2026-07/2026-07-30-the-architect-box-s-seat-identity-rested-entirely-on-a.md)
- **2026-07-30** — [The channel that carries a ruling request was the one channel with no wake — a newly filed issue entered no watch at all](2026-07/2026-07-30-the-channel-that-carries-a-ruling-request-was-the-one.md)
- **2026-07-30** — [The first live instance of the prose-drift issue was created by the session that had spent the day fixing prose drift, four hours after a measurement declared the issue dormant](2026-07/2026-07-30-the-first-live-instance-of-the-prose-drift-issue-was.md)
- **2026-07-30** — [The identity had three spellings, the round trip silently discarded the field that mattered, and both were found by measuring rather than reading](2026-07/2026-07-30-the-identity-had-three-spellings-the-round-trip.md)
- **2026-07-30** — [The loop counted nothing about itself, and the counter's first version was erased by the very next tick](2026-07/2026-07-30-the-loop-counted-nothing-about-itself-and-the-counter-s.md)
- **2026-07-30** — [The one condition that flips whose turn it is with no event of its own — a PR you BLOCKED and the author has since answered](2026-07/2026-07-30-the-one-condition-that-flips-whose-turn-it-is-with-no.md)
- **2026-07-30** — [The privacy banner said how MANY patterns and never WHICH list, so two boxes swept with materially different matchers for hours and both printed `clean`](2026-07/2026-07-30-the-privacy-banner-said-how-many-patterns-and-never.md)
- **2026-07-30** — [The product is UNFROZEN — Operator ruling, taken on risks rather than on gates](2026-07/2026-07-30-the-product-is-unfrozen-operator-ruling-taken-on-risks.md)
- **2026-07-30** — [The wake filter has never suppressed anything on the architect seat, because ownership was read from a LOCAL registry while the branch namespace is GLOBAL](2026-07/2026-07-30-the-wake-filter-has-never-suppressed-anything-on-the.md)
- **2026-07-30** — [The wake reduction was measured and the answer is that one of the two arms cannot fire on the seat that built it](2026-07/2026-07-30-the-wake-reduction-was-measured-and-the-answer-is-that.md)
- **2026-07-30** — [Three designs for self-caused suppression each died on the backstop, and none of them was wrong — each was one arm of a two-arm mechanism, tested against the whole problem](2026-07/2026-07-30-three-designs-for-self-caused-suppression-each-died-on.md)
- **2026-07-29** — [A documentation issue about retired dev containers turned up three capability facts canon had wrong, and the doc fix is the smallest thing in it](2026-07/2026-07-29-a-documentation-issue-about-retired-dev-containers.md)
- **2026-07-29** — [A fail-safe that holds is exactly the condition under which a wrong message survives indefinitely — `owed` called an orphaned watch "the watch class could not be read (10)", and…](2026-07/2026-07-29-a-fail-safe-that-holds-is-exactly-the-condition-under.md)
- **2026-07-29** — [A guard that had no live coverage on either box, and a flag that vanished silently — which provisioned both boxes in one afternoon, by two sessions, the second of whom had just…](2026-07/2026-07-29-a-guard-that-had-no-live-coverage-on-either-box-and-a.md)
- **2026-07-29** — [A one-PR implementer retirement, kept for two numbers that contradict the retirement before it: zero idle cycles across ten arms, and four self-corrections against zero cross-seat…](2026-07/2026-07-29-a-one-pr-implementer-retirement-kept-for-two-numbers.md)
- **2026-07-29** — [Retirement record, runner `r2` — the session was wrong four times and caught three of them itself, which is the only number here that says whether two-seat review is working](2026-07/2026-07-29-retirement-record-runner-r2-the-session-was-wrong-four.md)
- **2026-07-29** — [The approving seat's identity guard was not merely absent — it was exercisable, and the boundary it was supposed to hold had been open since the implementer identity moved to an…](2026-07/2026-07-29-the-approving-seat-s-identity-guard-was-not-merely.md)
- **2026-07-29** — [The fifth wrapper had no boundary check at all, and the suspension everyone reasoned from stopped the credential working without stopping the message recruiting someone to…](2026-07/2026-07-29-the-fifth-wrapper-had-no-boundary-check-at-all-and-the.md)
- **2026-07-28** — [A reviewer session's own numbers, which exist nowhere on the forge: nine findings accepted, five corrections of the reviewer accepted, five errors caught before they were…](2026-07/2026-07-28-a-reviewer-session-s-own-numbers-which-exist-nowhere-on.md)
- **2026-07-28** — [Eight filed defects cleared in one overnight unit, and seven of the eight were the same bug: a claim whose evidence could not falsify it](2026-07/2026-07-28-eight-filed-defects-cleared-in-one-overnight-unit-and.md)
- **2026-07-27** — [A box that cannot run the privacy gate now refuses to start — and getting there took three review rounds, every one of which found a claim the change made about itself that it…](2026-07/2026-07-27-a-box-that-cannot-run-the-privacy-gate-now-refuses-to.md)
- **2026-07-27** — [A convention became a check, and building the check found an arbitrary-code-execution path in the obvious way to wire it](2026-07/2026-07-27-a-convention-became-a-check-and-building-the-check.md)
- **2026-07-27** — [A gate named in three skills could not be run in half the forge set, and had been complied with in words for as long as nobody tried it](2026-07/2026-07-27-a-gate-named-in-three-skills-could-not-be-run-in-half.md)
- **2026-07-27** — [A safety argument was checked in the one direction that could not fail — and it was checked *before* being ruled, by the seat that ruled it](2026-07/2026-07-27-a-safety-argument-was-checked-in-the-one-direction-that.md)
- **2026-07-27** — [A `Stop` hook told a session to kill a healthy watcher, and the fix is a fifth liveness class — but the record keeps the two instances nobody could explain](2026-07/2026-07-27-a-stop-hook-told-a-session-to-kill-a-healthy-watcher.md)
- **2026-07-27** — [A suite written to prove `preflight` refuses things was itself reading the box it ran on — and mutation testing, used three times that evening to earn confidence, could not have…](2026-07/2026-07-27-a-suite-written-to-prove-preflight-refuses-things-was.md)
- **2026-07-27** — [An empty queue is not a legitimate finish for the reviewer, and the tool that said otherwise was faithful to the prose that was wrong](2026-07/2026-07-27-an-empty-queue-is-not-a-legitimate-finish-for-the.md)
- **2026-07-27** — [An issue an open PR is *about* needs no declaration — and the tool found the bug in its own discovery rule by running as its author's live watch](2026-07/2026-07-27-an-issue-an-open-pr-is-about-needs-no-declaration-and.md)
- **2026-07-27** — [G1 had been run by nobody but its author, and the gate that fixed that shipped unable to see the suite shrink](2026-07/2026-07-27-g1-had-been-run-by-nobody-but-its-author-and-the-gate.md)
- **2026-07-27** — [`git -c` does not persist, so no box could ever pull the private layer — and the box that quietly worked was the one hiding it](2026-07/2026-07-27-git-c-does-not-persist-so-no-box-could-ever-pull-the.md)
- **2026-07-27** — [`preflight` now refuses a private layer that can never fetch — and the check that enforces freshness was twice caught refusing a machine that worked](2026-07/2026-07-27-preflight-now-refuses-a-private-layer-that-can-never.md)
- **2026-07-27** — [The break-glass host stopped being an unfinished lockout and became a decision — and the paragraph admits it is a norm no mechanism can hold](2026-07/2026-07-27-the-break-glass-host-stopped-being-an-unfinished.md)
- **2026-07-27** — [The channel that carries authority in this project is an issue, and nothing watched it](2026-07/2026-07-27-the-channel-that-carries-authority-in-this-project-is.md)
- **2026-07-27** — [The first canon PR the reviewer authored — and the finding that blocked it was its own false claim about the thing it was documenting](2026-07/2026-07-27-the-first-canon-pr-the-reviewer-authored-and-the.md)
- **2026-07-27** — [The gate that guards public history was proven to MATCH, not merely to compile — and the issue asking for it turned out to rest on a premise a measurement falsified](2026-07/2026-07-27-the-gate-that-guards-public-history-was-proven-to-match.md)
- **2026-07-27** — [The one control in this system whose correctness cannot be gated overstated its own reach twice, and both corrections cost a review cycle each — which is the argument for the…](2026-07/2026-07-27-the-one-control-in-this-system-whose-correctness-cannot.md)
- **2026-07-27** — ["The Operator approves canon" became a file instead of a sentence — and the deadlock everyone predicted turned out to rest on a premise nobody had checked](2026-07/2026-07-27-the-operator-approves-canon-became-a-file-instead-of-a.md)
- **2026-07-27** — [The privacy gate could report a clean sweep it had never performed, and the fix was not the three-line hardening but the twenty-seven fixtures that assert it now fails](2026-07/2026-07-27-the-privacy-gate-could-report-a-clean-sweep-it-had.md)
- **2026-07-27** — [The private layer became a property of the box, and the control protecting it had to be built in a different repository than the one it protects](2026-07/2026-07-27-the-private-layer-became-a-property-of-the-box-and-the.md)
- **2026-07-27** — [The reviewer stopped being a person — verdicts now render as `quince-review[bot]` — and the PR that wired it was the first to feel the change](2026-07/2026-07-27-the-reviewer-stopped-being-a-person-verdicts-now-render.md)
- **2026-07-27** — [The title lint was wired, proven on the trigger that justifies it, and then could not be merged — because the forge cannot tell two seats apart when they share a login](2026-07/2026-07-27-the-title-lint-was-wired-proven-on-the-trigger-that.md)
- **2026-07-27** — [Three documents described one tool's exits; none of them matched it, and they disagreed with each other about which parts they had wrong](2026-07/2026-07-27-three-documents-described-one-tool-s-exits-none-of-them.md)
- **2026-07-27** — [Two boxes measured the same property of the forge and disagreed by 4×, and one of the numbers moved while it was being reviewed](2026-07/2026-07-27-two-boxes-measured-the-same-property-of-the-forge-and.md)
- **2026-07-26** — [One `internal/backup` flake fixed and landed; the other's category fix was found INCOMPLETE in review, by a reproduction the implementer could not get — and the load that…](2026-07/2026-07-26-one-internal-backup-flake-fixed-and-landed-the-other-s.md)
- **2026-07-26** — [pr.2 LANDED — `devct`, the dev-container toolkit, as six bot-authored PRs across one night](2026-07/2026-07-26-pr-2-landed-devct-the-dev-container-toolkit-as-six-bot.md)
- **2026-07-26** — [pr.4 LANDED — `dev-deploy`: a PR now carries a working demo URL and a walked click list without anyone asking, as three PRs](2026-07/2026-07-26-pr-4-landed-dev-deploy-a-pr-now-carries-a-working-demo.md)
- **2026-07-26** — [pr.5 CODE LANDED — the runner exists, is provisioned, and reports honestly that it is waiting for the one thing no script can do](2026-07/2026-07-26-pr-5-code-landed-the-runner-exists-is-provisioned-and.md)
- **2026-07-26** — [The architect gets its own box, and the loop gets its event source — six PRs after pr.5's first three](2026-07/2026-07-26-the-architect-gets-its-own-box-and-the-loop-gets-its.md)
- **2026-07-26** — [The CI flake was the product lying about a failed backup, and reproducing it before fixing it is the only reason anyone knows that](2026-07/2026-07-26-the-ci-flake-was-the-product-lying-about-a-failed.md)
- **2026-07-26** — [The loop's event model was itself the bug — an enumeration is a claim about what can matter, and this one deadlocked two agents on each other for over two hours while both…](2026-07/2026-07-26-the-loop-s-event-model-was-itself-the-bug-an.md)
- **2026-07-26** — [The loop's sixth blind spot was in a justification, not in code: an approved PR whose CI then finishes is invisible, and that is where PRs spend most of their waiting](2026-07/2026-07-26-the-loop-s-sixth-blind-spot-was-in-a-justification-not.md)
- **2026-07-26** — [The public docs stopped reading as a lab journal, and no decision left with the voice](2026-07/2026-07-26-the-public-docs-stopped-reading-as-a-lab-journal-and-no.md)
- **2026-07-26** — [The revamp's session hosts are live, and the ceremony taught three gates the docs did not have](2026-07/2026-07-26-the-revamp-s-session-hosts-are-live-and-the-ceremony.md)
- **2026-07-26** — [The rewritten loop shipped a watch that could not wake anybody, and an arming step a session could simply skip — one mechanism defect and one honour-system defect, in the same…](2026-07/2026-07-26-the-rewritten-loop-shipped-a-watch-that-could-not-wake.md)
- **2026-07-25** — [(dm) qn.6b LAB LEGS RUN on real hardware — stories 9/10/11 validated; candidate C + liveness patience + kept-dirty-working RESUME-TO-COMPLETION all PROVEN; the bad-link `-4`…](2026-07/2026-07-25-dm-qn-6b-lab-legs-run-on-real-hardware-stories-9-10-11.md)
- **2026-07-25** — [(dn) ARCHITECT REVIEW of the qn.6b lab session ((dm)): validated and landed (`5e92a7b`); the (dh) story-9 contingency is formally DISCHARGED — the freeze is unblocked](2026-07/2026-07-25-dn-architect-review-of-the-qn-6b-lab-session-dm.md)
- **2026-07-25** — [(do) The 2026-07-24 storage-thread discussion BANKED (the space-scare's productive tail): the `zfs-native` lifecycle is now epic-(cl) candidate mode #8; the clone-promote/…](2026-07/2026-07-25-do-the-2026-07-24-storage-thread-discussion-banked-the.md)
- **2026-07-25** — [pr.3 LANDED — the agent instructions, the six workflow skills, and the layered permission allowlist, as three bot-authored PRs reviewed and rebase-merged the same day](2026-07/2026-07-25-pr-3-landed-the-agent-instructions-the-six-workflow.md)
- **2026-07-24** — [(cp) qn.5b BUILT (CI-proven) — atomic `latest` + the `working/` lifecycle redesign landed per the (co) ruling + both amendments](2026-07/2026-07-24-cp-qn-5b-built-ci-proven-atomic-latest-the-working.md)
- **2026-07-24** — [(cq) qn.5b post-build architect review: APPROVED + LANDED on main (`fc45ae7`, ff-only, pushed)](2026-07/2026-07-24-cq-qn-5b-post-build-architect-review-approved-landed-on.md)
- **2026-07-24** — [(cr) FINDING (Operator-caught on the staging UI, 2026-07-24): versions whose artifact is GONE are still listed as normal backups — `missing` is tracked everywhere except the one…](2026-07/2026-07-24-cr-finding-operator-caught-on-the-staging-ui-2026-07-24.md)
- **2026-07-24** — [(cs) HARDWARE FINDING + FIX (branch `claude/qn5b-seed-timeout-fix`): the 60 s ZFS metadata timeout was applied to the qn.5b `seed`, which is O(file count) — it SIGKILLed the real 34…](2026-07/2026-07-24-cs-hardware-finding-fix-branch-claude-qn5b-seed-timeout.md)
- **2026-07-24** — [(ct) qn.5b HARDWARE-VALIDATED end-to-end on the real pool + real iPhone/iPad over Wi-Fi — every owed lab leg now proven](2026-07/2026-07-24-ct-qn-5b-hardware-validated-end-to-end-on-the-real-pool.md)
- **2026-07-24** — [(cu) DEGRADED UX regression (Operator-caught on hardware): qn.5b made the gap between tapping "Back up now" and the on-device passcode prompt MUCH longer — proportional to device…](2026-07/2026-07-24-cu-degraded-ux-regression-operator-caught-on-hardware.md)
- **2026-07-24** — [(cv) ARCHITECT REVIEW of the qn.5b hardware session: branch approved + landed (main → `0f9eaff`, ff-only); all four routed findings adjudicated](2026-07/2026-07-24-cv-architect-review-of-the-qn-5b-hardware-session.md)
- **2026-07-24** — [(cw) Finding B CLOSED — the qn.5b `seed_in_progress` guard: a seed killed mid-clone is no longer silently resumed into (branch `claude/qn5b-finding-b-seed-guard`, gates-green)](2026-07/2026-07-24-cw-finding-b-closed-the-qn-5b-seed-in-progress-guard-a.md)
- **2026-07-24** — [(cx) (cu) ELABORATED with the Operator — the raw-latency mechanisms banked as a parked, evidence-gated roadmap block (Later/parked)](2026-07/2026-07-24-cx-cu-elaborated-with-the-operator-the-raw-latency.md)
- **2026-07-24** — [(cy) ARCHITECT REVIEW of the Finding B closeout ((cw), branch `claude/qn5b-finding-b-seed-guard`): APPROVED + LANDED (main → `b0a859a`, ff-only)](2026-07/2026-07-24-cy-architect-review-of-the-finding-b-closeout-cw-branch.md)
- **2026-07-24** — [(cz) (cu) latency bank AMENDED after a second Operator discussion — the GATE PATCH becomes candidate C and DOMINATES the stand-in scheme; in-process integration assessed and declined…](2026-07/2026-07-24-cz-cu-latency-bank-amended-after-a-second-operator.md)
- **2026-07-24** — [(da) qn.6a BUILT (CI-proven) — soak-ready UI (mobile + offline devices), the LAST rung under the current process](2026-07/2026-07-24-da-qn-6a-built-ci-proven-soak-ready-ui-mobile-offline.md)
- **2026-07-24** — [(db) ARCHITECT REVIEW of qn.6a ((da)): APPROVED + LANDED (main → `3a7b068`, ff-only). The rung chain is COMPLETE — the frontier is now the CODE FREEZE + PROCESS REVAMP, with the…](2026-07/2026-07-24-db-architect-review-of-qn-6a-da-approved-landed-main.md)
- **2026-07-24** — [(dc) CORRECTION to (db) deviation 1 (Operator clarified): the qn.6a push was NOT unprompted](2026-07/2026-07-24-dc-correction-to-db-deviation-1-operator-clarified-the.md)
- **2026-07-24** — [(dd) qn.6a SOAK-POLISH BATCH reviewed + landed (9 commits, main → `ef897eb`) — the soak's first real yield, delivered OUT of process and adjudicated honestly](2026-07/2026-07-24-dd-qn-6a-soak-polish-batch-reviewed-landed-9-commits.md)
- **2026-07-24** — [(de) qn.6b "transport patience" INSERTED pre-freeze — the LAST pre-freeze insert, with the bar made explicit](2026-07/2026-07-24-de-qn-6b-transport-patience-inserted-pre-freeze-the.md)
- **2026-07-24** — [(df) qn.6b BUILT (CI-proven) — transport patience: patched-from-source libimobiledevice + the `--gate` candidate-C seed overlap + the liveness retune + amendment A](2026-07/2026-07-24-df-qn-6b-built-ci-proven-transport-patience-patched.md)
- **2026-07-24** — [(dg) qn.6b SPEC REVIEWED — APPROVED WITH AMENDMENTS; build may start once they are folded in (no re-review needed pre-build)](2026-07/2026-07-24-dg-qn-6b-spec-reviewed-approved-with-amendments-build.md)
- **2026-07-24** — [(dh) qn.6b spec DELTA reviewed after a relay-ordering slip — the capture-driven item-3/item-4 edits are now ACTUALLY approved; the (dg) build-go stands](2026-07/2026-07-24-dh-qn-6b-spec-delta-reviewed-after-a-relay-ordering.md)
- **2026-07-24** — [(di) e2e story-4 FLAKE fixed under the soak-maintenance lane ((dd)) — a test-only change; two distinct bugs, diagnosed honestly, neither a UI defect](2026-07/2026-07-24-di-e2e-story-4-flake-fixed-under-the-soak-maintenance.md)
- **2026-07-24** — [(dj) ARCHITECT REVIEW of qn.6b ((df)): APPROVED + LANDED (rebased onto (dh) main, PR #2 CI fully green — gates/image/e2e — then ff-only to main `3720f84`)](2026-07/2026-07-24-dj-architect-review-of-qn-6b-df-approved-landed-rebased.md)
- **2026-07-24** — [(dk) ARCHITECT REVIEW of the story-4 flake fix ((di)): APPROVED + LANDED (PR #3 CI green, ff-only to main `a45a307`)](2026-07/2026-07-24-dk-architect-review-of-the-story-4-flake-fix-di.md)
- **2026-07-24** — [(dl) SPACE SCARE resolved — the reflink accounting trap's SECOND ambush, this time via the snapshot columns; no space is being wasted](2026-07/2026-07-24-dl-space-scare-resolved-the-reflink-accounting-trap-s.md)
- **2026-07-22** — [(ce) qn.4c LAB GATE 11 — the DAILY-DRIVER bar is met on real hardware; 6 of 8 legs passed, 1 mislabelled, 1 declared unrunnable](2026-07/2026-07-22-ce-qn-4c-lab-gate-11-the-daily-driver-bar-is-met-on.md)
- **2026-07-22** — [(cf) iMazing-opens PASSED — qn.4a's gate 15 is now FULLY hardware-proven](2026-07/2026-07-22-cf-imazing-opens-passed-qn-4a-s-gate-15-is-now-fully.md)
- **2026-07-22** — [(cg) `PROPOSED (gap)`: the `latest` swap is NOT atomic — the D5a offsite promise is broken today. `qn.5b` inserted (Operator-found)](2026-07/2026-07-22-cg-proposed-gap-the-latest-swap-is-not-atomic-the-d5a.md)
- **2026-07-22** — [(ch) `qn.6a` inserted before the freeze — soak-ready UI. Sequence: qn.5b → qn.6a → freeze + revamp (app soaking)](2026-07/2026-07-22-ch-qn-6a-inserted-before-the-freeze-soak-ready-ui.md)
- **2026-07-22** — [(ci) gate-11 findings — DURABLE disposition + rung distribution (bookkeeping)](2026-07/2026-07-22-ci-gate-11-findings-durable-disposition-rung.md)
- **2026-07-22** — [(cj) architect rulings on (ci)'s four PROPOSED rows + #9 (the audit itself: approved, and the #4/#5 "a redesign deletes the bug" subsumption is the model catch)](2026-07/2026-07-22-cj-architect-rulings-on-ci-s-four-proposed-rows-9-the.md)
- **2026-07-22** — [(ck) #9(a) REFRAMED by an Operator challenge ("does the `incremental` label bring any user value?") — it doesn't, and it mildly MISLEADS: drop it from the UI, keep it internal](2026-07/2026-07-22-ck-9-a-reframed-by-an-operator-challenge-does-the.md)
- **2026-07-22** — [(cl) Post-freeze EPIC captured: storage as a first-class entity (multi-storage)](2026-07/2026-07-22-cl-post-freeze-epic-captured-storage-as-a-first-class.md)
- **2026-07-22** — [(cm) Later idea banked: scoped per-device view + QR/link device enrollment](2026-07/2026-07-22-cm-later-idea-banked-scoped-per-device-view-qr-link.md)
- **2026-07-22** — [(cn) Spike banked: enable/disable Wi-Fi discoverability ("Wi-Fi sync") from inside quince](2026-07/2026-07-22-cn-spike-banked-enable-disable-wi-fi-discoverability-wi.md)
- **2026-07-22** — [(co) qn.5b spec APPROVED with amendments — two Operator-caught issues + the seven gate forks ruled](2026-07/2026-07-22-co-qn-5b-spec-approved-with-amendments-two-operator.md)
- **2026-07-21** — [(cb) qn.4c BUILT (CI) — netmuxd is co-supervised, and the three "it looks broken" defects are gone](2026-07/2026-07-21-cb-qn-4c-built-ci-netmuxd-is-co-supervised-and-the.md)
- **2026-07-21** — [(cc) qn.4c close review (architect): approved — and the terminal/slot-release race gets a rung home](2026-07/2026-07-21-cc-qn-4c-close-review-architect-approved-and-the.md)
- **2026-07-21** — [(cd) qn.4c GATE-11 LAB FINDING — the backup target stub must live on the storage filesystem; fixed as a lab-finding commit](2026-07/2026-07-21-cd-qn-4c-gate-11-lab-finding-the-backup-target-stub.md)
- **2026-07-20** — [(ar) qn.2 cleanup package: muxer gap ruled, qn.2b inserted, qn.5↔qn.4 swapped, worktree-init fixed](2026-07/2026-07-20-ar-qn-2-cleanup-package-muxer-gap-ruled-qn-2b-inserted.md)
- **2026-07-20** — [(as) plan-time discipline made structural](2026-07/2026-07-20-as-plan-time-discipline-made-structural.md)
- **2026-07-20** — [(at) coverage made a declared artifact; handoff review gets named dimensions](2026-07/2026-07-20-at-coverage-made-a-declared-artifact-handoff-review.md)
- **2026-07-20** — [(au) qn.2b BUILT (CI) — the in-container muxer has a lifecycle](2026-07/2026-07-20-au-qn-2b-built-ci-the-in-container-muxer-has-a-lifecycle.md)
- **2026-07-20** — [(av) qn.2b lab finding — managed-muxer USB needs a LIVE `/dev/bus/usb`, not `devices:`](2026-07/2026-07-20-av-qn-2b-lab-finding-managed-muxer-usb-needs-a-live-dev.md)
- **2026-07-20** — [(aw) qn.2b CLOSED; netmuxd-USB audition re-homed to qn.7](2026-07/2026-07-20-aw-qn-2b-closed-netmuxd-usb-audition-re-homed-to-qn-7.md)
- **2026-07-20** — [(ax) P1 accepted → qn.6](2026-07/2026-07-20-ax-p1-accepted-qn-6.md)
- **2026-07-20** — [(ay) one project, one dev host](2026-07/2026-07-20-ay-one-project-one-dev-host.md)
- **2026-07-20** — [(az) qn.3 BUILT (CI) — device ops + Devices page](2026-07/2026-07-20-az-qn-3-built-ci-device-ops-devices-page.md)
- **2026-07-20** — [(ba) qn.3 CLOSED — lab gate 8 PASSED on real hardware](2026-07/2026-07-20-ba-qn-3-closed-lab-gate-8-passed-on-real-hardware.md)
- **2026-07-20** — [(bb) qn.3 post-landing architect review: clean; docs-drift swept](2026-07/2026-07-20-bb-qn-3-post-landing-architect-review-clean-docs-drift.md)
- **2026-07-20** — [(bc) canon fix found by the qn.5 spec review: structural verification branches on encryption](2026-07/2026-07-20-bc-canon-fix-found-by-the-qn-5-spec-review-structural.md)
- **2026-07-20** — [(bd) qn.5 BUILT (CI) — the version store stands](2026-07/2026-07-20-bd-qn-5-built-ci-the-version-store-stands.md)
- **2026-07-20** — [(be) qn.4 split into qn.4a / qn.4b](2026-07/2026-07-20-be-qn-4-split-into-qn-4a-qn-4b.md)
- **2026-07-20** — [(bf) gate-12 gap RULED: the zfs mirror probes for MEASURED sharing, not FICLONE success](2026-07/2026-07-20-bf-gate-12-gap-ruled-the-zfs-mirror-probes-for-measured.md)
- **2026-07-20** — [(bg) the (bf) no-share verdict is PROVISIONAL — Operator challenged it, and there is a specific accounting trap that could fully explain the evidence](2026-07/2026-07-20-bg-the-bf-no-share-verdict-is-provisional-operator.md)
- **2026-07-20** — [(bh) (bg)'s discriminator RUN by the Operator on the host — CLONING WORKS; reflink REINSTATED](2026-07/2026-07-20-bh-bg-s-discriminator-run-by-the-operator-on-the-host.md)
- **2026-07-20** — [(bi) the Operator's layer ladder caught the THIRD layer: unprivileged userns blocks FICLONE (`EPERM`) — mirror strategy RULED as a ladder with a host-side hook verb](2026-07/2026-07-20-bi-the-operator-s-layer-ladder-caught-the-third-layer.md)
- **2026-07-20** — [(bj) probe semantics refined (fourth Operator challenge: "how can a hookless container run a pool-level probe?"): the sharing measurement governs REPORTING, never selection](2026-07/2026-07-20-bj-probe-semantics-refined-fourth-operator-challenge.md)
- **2026-07-20** — [(bk) (bj) corrected on the fifth Operator challenge ("hardlink seems better"): the measurement DOES inform selection — in exactly one direction](2026-07/2026-07-20-bk-bj-corrected-on-the-fifth-operator-challenge.md)
- **2026-07-20** — [(bl) qn.5 folds the mirror-ladder ruling into code + docs](2026-07/2026-07-20-bl-qn-5-folds-the-mirror-ladder-ruling-into-code-docs.md)
- **2026-07-20** — [(bm) qn.5 CLOSED (CI-proven); lab gate 12's remaining hardware legs RE-HOMED to qn.4a](2026-07/2026-07-20-bm-qn-5-closed-ci-proven-lab-gate-12-s-remaining.md)
- **2026-07-20** — [(bn) gate-12 legs REDISTRIBUTED by affinity (Operator-ruled, amending (bm)'s all-to-qn.4a; a separate qn.4c was considered and rejected as a hollow-goal rung)](2026-07/2026-07-20-bn-gate-12-legs-redistributed-by-affinity-operator.md)
- **2026-07-20** — [(bo) `rpool/userdata` DECLASSIFIED (Operator ruling), closing the qn.4a-reported pattern hit](2026-07/2026-07-20-bo-rpool-userdata-declassified-operator-ruling-closing.md)
- **2026-07-20** — [(bp) qn.4b spec APPROVED; the `auto`-when-absent edge RULED: refuse actionably](2026-07/2026-07-20-bp-qn-4b-spec-approved-the-auto-when-absent-edge-ruled.md)
- **2026-07-20** — [(bq) BUG (Operator-found, assigned to qn.4b): Dashboard DeviceCard "Pair" navigates without opening the pairing dialog](2026-07/2026-07-20-bq-bug-operator-found-assigned-to-qn-4b-dashboard.md)
- **2026-07-20** — [(br) qn.4b BUILT (CI) — Wi-Fi first-class + transport policy + job-history UI; M3's CI half closed](2026-07/2026-07-20-br-qn-4b-built-ci-wi-fi-first-class-transport-policy.md)
- **2026-07-20** — [(bs) qn.4a LAB GATE 15 — the engine legs PASSED on real hardware (iPad15,7, iOS 26.5)](2026-07/2026-07-20-bs-qn-4a-lab-gate-15-the-engine-legs-passed-on-real.md)
- **2026-07-20** — [(bt) qn.4a BUILT (CI) — the backup engine drives idevicebackup2 end-to-end](2026-07/2026-07-20-bt-qn-4a-built-ci-the-backup-engine-drives.md)
- **2026-07-20** — [(bu) decisions-log letter hygiene (two collisions in one review — a process fix)](2026-07/2026-07-20-bu-decisions-log-letter-hygiene-two-collisions-in-one.md)
- **2026-07-20** — [(bv) ownership resolved: qn.4a owns the deferred zfs-hook legs — and the plan ambiguity that caused the dispute is fixed](2026-07/2026-07-20-bv-ownership-resolved-qn-4a-owns-the-deferred-zfs-hook.md)
- **2026-07-20** — [(bw) qn.4a zfs half PROVEN on real hardware — the engine drives a committed, verified version on the real zfs-hook backend, end-to-end](2026-07/2026-07-20-bw-qn-4a-zfs-half-proven-on-real-hardware-the-engine.md)
- **2026-07-20** — [(bx) qn.4a close review (architect): clean + strong — two real bugs given a rung home](2026-07/2026-07-20-bx-qn-4a-close-review-architect-clean-strong-two-real.md)
- **2026-07-20** — [(by) DAILY-DRIVER TARGET set; qn.4b closed (CI); `qn.4c` inserted; netmuxd supervision pulled forward; gate 12c deferred past a planned code freeze](2026-07/2026-07-20-by-daily-driver-target-set-qn-4b-closed-ci-qn-4c.md)
- **2026-07-20** — [(bz) qn.4c spec APPROVED; three architect rulings + the netmuxd socket hazard](2026-07/2026-07-20-bz-qn-4c-spec-approved-three-architect-rulings-the.md)
- **2026-07-20** — [(ca) mDNS-across-the-container-bridge named as an unproven dependency (qn.4c) — and it is the Wi-Fi twin of accepted proposal P1](2026-07/2026-07-20-ca-mdns-across-the-container-bridge-named-as-an.md)
- **2026-07-20** — [(qn2-close) qn.2 closed](2026-07/2026-07-20-qn2-close-qn-2-closed.md)
- **2026-07-19** — [(aa) repo root = `~/iphone-backup-app` as-is (git init in place, qn.0)](2026-07/2026-07-19-aa-repo-root-iphone-backup-app-as-is-git-init-in-place.md)
- **2026-07-19** — [(ab) device scope widened in wording (Operator): iPhone AND iPad are first-class (same pairing/MobileBackup2 protocol, no extra code)](2026-07/2026-07-19-ab-device-scope-widened-in-wording-operator-iphone-and.md)
- **2026-07-19** — [(ac) dev environment ruled](2026-07/2026-07-19-ac-dev-environment-ruled.md)
- **2026-07-19** — [(ad) public/private doc split](2026-07/2026-07-19-ad-public-private-doc-split.md)
- **2026-07-19** — [(ae) dev box is Alpine + nerdctl via the house template flow](2026-07/2026-07-19-ae-dev-box-is-alpine-nerdctl-via-the-house-template-flow.md)
- **2026-07-19** — [(af) the dev host is a container host, not a toolchain host](2026-07/2026-07-19-af-the-dev-host-is-a-container-host-not-a-toolchain-host.md)
- **2026-07-19** — [(ag) qn.0 BUILT — the floor stands](2026-07/2026-07-19-ag-qn-0-built-the-floor-stands.md)
- **2026-07-19** — [(ag) the qn.0 usbmuxd `PROPOSED` gap is dissolved, not chosen between](2026-07/2026-07-19-ag-the-qn-0-usbmuxd-proposed-gap-is-dissolved-not.md)
- **2026-07-19** — [(ah) netmuxd is the single muxer for BOTH transports](2026-07/2026-07-19-ah-netmuxd-is-the-single-muxer-for-both-transports.md)
- **2026-07-19** — [(ah-qn1) qn.1 BUILT — the app frame stands](2026-07/2026-07-19-ah-qn1-qn-1-built-the-app-frame-stands.md)
- **2026-07-19** — [(ai) Operator recalled hard evidence against netmuxd-USB](2026-07/2026-07-19-ai-operator-recalled-hard-evidence-against-netmuxd-usb.md)
- **2026-07-19** — [(aj) the (ai) signature corrected against the lab log](2026-07/2026-07-19-aj-the-ai-signature-corrected-against-the-lab-log.md)
- **2026-07-19** — [(ak) RETRACTION of the "faulty probe" accusation in (ag)/(ah)](2026-07/2026-07-19-ak-retraction-of-the-faulty-probe-accusation-in-ag-ah.md)
- **2026-07-19** — [(al) new hard rule: "version pins are looked up, never remembered"](2026-07/2026-07-19-al-new-hard-rule-version-pins-are-looked-up-never.md)
- **2026-07-19** — [(am) the private layer is now version-controlled](2026-07/2026-07-19-am-the-private-layer-is-now-version-controlled.md)
- **2026-07-19** — [(an) privacy incident + new hard rule](2026-07/2026-07-19-an-privacy-incident-new-hard-rule.md)
- **2026-07-19** — [(ao) Go rewrite of the decryption library greenlit as a parallel independent project](2026-07/2026-07-19-ao-go-rewrite-of-the-decryption-library-greenlit-as-a.md)
- **2026-07-19** — [(ap) improvement-proposal channel added](2026-07/2026-07-19-ap-improvement-proposal-channel-added.md)
- **2026-07-19** — [(aq) domain parsing goes to a standalone sibling library — `ios-backup-parser` — and the repo-naming policy is ruled](2026-07/2026-07-19-aq-domain-parsing-goes-to-a-standalone-sibling-library.md)
- **2026-07-19** — [(qn1-review) qn.0/qn.1 post-build review + fixes. A read-only conformance review (specs + frozen contracts §1–§6 + design §6) found no blocker/major](2026-07/2026-07-19-qn1-review-qn-0-qn-1-post-build-review-fixes-a-read.md)
- **2026-07-19** — [(qn2-build) qn.2 code built. The `internal/muxd` plist protocol client (`howett.net/plist v1.0.1`, Listen handshake, per-connection DeviceID→UDID map, reconnecting dialer)…](2026-07/2026-07-19-qn2-build-qn-2-code-built-the-internal-muxd-plist.md)
- **2026-07-18** — [(a) vault seam made explicitly swappable](2026-07/2026-07-18-a-vault-seam-made-explicitly-swappable.md)
- **2026-07-18** — [(e) photos parked at lowest priority](2026-07/2026-07-18-e-photos-parked-at-lowest-priority.md)
- **2026-07-18** — [full planning pass (this docs set) from the feasibility lab (`../local/chatgpt-original-idea-chat.md`)](2026-07/2026-07-18-full-planning-pass-this-docs-set-from-the-feasibility.md)
- **2026-07-18** — [(k) PVE propagation](2026-07/2026-07-18-k-pve-propagation.md)
- **2026-07-18** — [Operator rulings](2026-07/2026-07-18-operator-rulings.md)
- **2026-07-18** — [(p) Intent model adopted lightweight](2026-07/2026-07-18-p-intent-model-adopted-lightweight.md)
- **2026-07-18** — [(r) the gap protocol](2026-07/2026-07-18-r-the-gap-protocol.md)
- **2026-07-18** — [(t) device-centric IA](2026-07/2026-07-18-t-device-centric-ia.md)
- **2026-07-18** — [the offsite model is whole-tree file-level sync](2026-07/2026-07-18-the-offsite-model-is-whole-tree-file-level-sync.md)
- **2026-07-18** — [the product model is ASSISTED backup](2026-07/2026-07-18-the-product-model-is-assisted-backup.md)
- **2026-07-18** — [(y) the project is named `quince`](2026-07/2026-07-18-y-the-project-is-named-quince.md)
- **2026-07-18** — [(z) full doc sweep against the conversation's decision history](2026-07/2026-07-18-z-full-doc-sweep-against-the-conversation-s-decision.md)
