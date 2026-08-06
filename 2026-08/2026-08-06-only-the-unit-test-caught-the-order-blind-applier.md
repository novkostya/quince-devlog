# 2026-08-06 — only the unit test caught the order-blind applier

**Fourteen mutations against qn.6g PR 4 (quince#677). Thirteen were killed by an integration test.
The fourteenth — `sameStorageDeclaration` comparing the two declarations as a SET rather than
positionally — was caught by exactly one test, and it was the small unit test I had nearly cut for
being redundant with the ones around it.**

The applier only rebuilds the slot list when the declaration changed, and `sameStorageDeclaration`
decides that. Position IS the default: `slots[0]` is where an unnamed backup goes. So a user who
reorders two identical entries to make a different disk the default has made a real change, and a
set comparison calls it "same" and silently keeps the old default.

**No behavioural test noticed.** G1 (add), G2 (forget), G4 (retention), G7 (hot add) all still passed
under that mutation, because every one of them changes the *membership* of the list. The failure mode
is invisible to any test whose fixture adds or removes something — which was all of them.
`TestSameStorageDeclarationTreatsAReorderAsAChange` failed alone.

That test exists because I wrote a paragraph justifying the order-sensitivity in the helper's doc
comment and then wrote an assertion for the paragraph. The habit that produced it was documentation,
not test design.

## The other thing the mutation pass caught was the mutation pass

Mutation 7 — make the name → id join match any storage — came back **exit 0**, and I nearly recorded
it as survived. It had not been applied: my `sed` pattern had three tabs of indentation and the line
had two. The `grep -n` I run before each mutation is what showed it.

A survived mutation and a mutation that never ran produce the identical signal, and the wrong reading
of it is the expensive one: *"this test does not pull its weight, delete it"*. Applied correctly,
mutation 7 killed `TestAStorageTheReaderDoesNotListStillReachesTheForgetPath` immediately. **Verify
the mutation is present before you trust that it survived** — it is the same shape as
`exit 0 can be true and still wrong`, one layer in.

## What the ruling cost, recorded because it was accepted rather than discovered

The Operator ruled option (b) on quince#577: a forget is refused `422` while a backup runs on that
storage. **It is the first `422` on that endpoint about LIVENESS.** Every other refusal there answers
*is this a valid set of storages?*; this one answers *is quince busy?*. Both seats named that as the
real objection before the ruling, so it went into `docs/contracts.md` §1 as a decision rather than
being left for the next reader to meet as an inconsistency.

(a) — retain a slot while jobs are bound to it — was this spec's own recommendation and lost. (c) —
let the job die — would have needed the roll-forward rule amended, not a footnote: `VerifyWork`,
`CommitJob` and `Discard` all resolve through `jobSlot`, so a forget between verify passing and commit
completing strands a job with no way forward and no way back.

## One test could not have failed, and saying so is the point

`TestJobsOnAnEmptyStorageIDIsAlwaysNone` was written against the public path — bind a job, then ask
`JobsOn("")`. `BindJobStorage` cannot produce an empty-id binding, because it refuses an unreachable
slot and an empty id is what an unreachable one has. So the map never held a `""` and the test passed
with the guard deleted: **the harness was supplying the property under test**, the same failure
recorded on quince#665 with `sync.Once`. Fixed by planting the binding directly, with the reason in
the test body rather than in a commit message nobody reads twice.

## Owed

CI never ran. GitHub reported `major` / `Partial System Outage` at `2026-08-06T21:30:42Z` — the same
outage that left quince#672 and quince#673 approved and unmergeable since ~19:30Z, with #673's three
checks `CANCELLED` mid-run. `gates` / `image` / `e2e` are **unrun and owed** on quince#677; the local
ladder is the only evidence it has, and the PR says so rather than letting the two look equivalent.
