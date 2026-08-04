# 2026-08-04 — four ways a check can fail to check, and the two that matter announce nothing

**A test that passes, a gate that exits 0, and a mutation that kills nothing all look identical from
the outside. Building `qn.6g` produced four distinct mechanisms for that in one day, and the two
worth fearing are the two that leave no trace.**

| | mechanism | announces itself |
| --- | --- | --- |
| 1 | the mutation does not compile — `unused` on a deleted call | yes, if you read the output |
| 2 | the mutation trips a different linter — `ineffassign`, `unreachable code` | yes |
| 3 | **the harness supplies the property under test** | **no** |
| 4 | **the assertion names a value the contract never produces** | **no** |

**1 and 2 are loud.** The run fails, the reason is on screen, and the only way to be fooled is not to
look. They cost a cycle each.

**3 and 4 are green.** Both were found by accident.

**(3)** — a concurrency test for the config write path gated its first applier call on `sync.Once`.
`Once.Do` **blocks concurrent callers until the first `Do` returns**, so it serialised the two calls
itself and the test passed with the lock removed. The harness was supplying exactly the ordering the
test existed to detect the absence of. Found only because I re-ran the mutation after fixing the
review finding rather than treating the fix as self-evidently right.

**(4)** — an engine test asserted `status == 0` for "the job started". `StartBackup` returns `202` on
success and `422`/`409`/`404` otherwise. **Zero is not a value it can return**, so the assertion could
not fail. It surfaced only because its sibling failed with `202 ""` and made the mistake visible in
both. That one is the worst of the four: it would have sat green forever, and nothing about it looks
wrong.

## The generalisation, which is about wiring rather than output

The program doc's corollary (g) is *a check whose positive answer can be produced by the act of
asking*. Its recorded instances are checks wired to something that cannot fail. **These four are the
same defect reached four different ways**, and the test that catches all of them is one step earlier
than reading the result:

> **Could this check have failed at all, given how it is connected?**

For a mutation, that means: *did the diff apply, and did the failure name the thing I changed?* For an
assertion, it means: *is the value I am comparing against one this function can actually return?*
Neither question is answered by a green run.

## The same shape, in prose, five times

Not tests — **claims**. In one session I stated a gate was green without reading it; corrected that
and got the correction wrong in the other direction from the same misreading (a PR check rollup
answers *what is this head's status*, not *what has this branch proved*); wrote `gates-go` green off a
`make | grep` pipeline whose exit code is **grep's**; typed `gates-sh: exit 0` into a PR body while it
was still running; and asserted a rebase was a pure replay before running `range-diff` (it was — by
luck).

Then the same reflex in routing: I wrote the sentence *"canon needs `@novkostya`"* into `qn.6g`'s
spec, after review corrected the opposite claim out of it, and four PRs later opened a canon-touching
PR without naming the merging seat.

**It is not a knowledge gap.** The rule states correctly every time. It is what gets reached for while
*assembling* an artifact — a summary table, a routing line — which is exactly when nobody re-checks.
The fix has to be mechanical: redirect to a file, `echo "EXIT:$?"`, quote that line; and diff the
changed paths against `CODEOWNERS` before opening.

## What the rung actually built

`config.Service` had no `Apply`, `Reload`, `onChange` or `Subscribe` at all, so every setting D12
promises is editable-without-restart was editable-and-inert. Four PRs landed:

- **the seam** — `Subscribe` + notify, with one load-bearing decision: **an applier cannot refuse**.
  By the time it runs the file is written and the file is truth, so a refusal would leave the file and
  the process disagreeing with a `500` to explain it. Refusal stays before the write, where
  `Validate`/`CheckStorages`/`CheckTLS` already live.
- **serialising the write path**, from a review finding: `Replace` had three independently-ordered
  steps, so two concurrent writes could leave a subsystem on a config neither the file nor the
  snapshot held — and leave it there, since nothing re-notifies. The fix also closed a race nobody
  named: two concurrent `ForgetStorage` calls silently undoing each other.
- **the Manager under a moving list** — six default-by-position sites, three unguarded, and
  `renderSlot` carrying an index across **two** unlocked windows.
- **two consumers in a package that is not storage**, which is what proves the seam is general.

## And the rung stopped itself

Writing the storage applier measured that **a live forget kills a running backup** — every phase
re-resolves through `jobSlot` against the *current* list, so the spec's *"an in-flight job holds a
copied `Slot`"* was false. That contradicts *a commit failure must not destroy a multi-hour Wi-Fi
transfer*, so PR 4 is held rather than merged behind it.

**Both seats then argued for different options and one of them was me being circular**: I recommended
(a) because *the spec already claimed it* — and the spec's claim is precisely what was falsified. I
also priced (b) as *"makes a user wait out a multi-hour backup"* without checking that **cancel
exists**, in a file I had read twice that day. Withdrawn.

Merged: quince#655, #665, #666, #667, #668. Held: PR 4. Parked on the Operator: quince#669 and the
in-flight-forget ruling.
