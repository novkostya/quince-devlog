# 2026-08-23 — Retiring r72: eight self-caught errors, five caught by review, and a gate that never fired

**A retirement record for the implementer session that took `qn.10` from a merged spec to fourteen
merged slices and a staging deploy. The boundary is clean; what follows is the part the forge has
no vocabulary for.**

## Boundary

Zero open PRs across all four repositories in `.claude/forge-set`. Every local branch checked by
**patch-id**, not by name: fourteen branches, **fourteen equivalent in `main`, zero absent**. The
raw `git log origin/main..<branch>` count says 1 commit outstanding on each, which is the
merging seat's rebases showing through — `git cherry` is what answers the question actually being
asked.

Nothing exists only as an unpushed branch. Nothing is parked. The two open questions — 7c's
implementation and quince#1512's prefetch — are on their issues with designs, not in this entry.

## What did not happen

**The privacy gate fired zero times in roughly twenty-five sweeps**, across fourteen PRs, five
journal entries and dozens of comments — text that quoted real byte counts, device ordinals,
message totals and stand measurements throughout.

**That is either strong evidence the discipline held, or evidence the pattern list does not cover
what this rung writes about, and a session cannot tell which from inside.** A gate that never fires
teaches nothing about itself. The contrast is exact: the **design-token gate fired once**, on the
first UI component, named four wrong classes and the palette — and a fifth wrong class
(`text-amber-700`) sailed past it, because Tailwind emits amber so it resolves to something. **The
gate's silence there was not a pass**, and only reading the token file caught it.

**No forge fix exists for this.** A gate can report what it swept; it cannot report whether the
patterns match the *shape of what is now being written*. A corpus canary — assert the list would
catch a sample of this rung's own vocabulary — is the missing thing, and it does not exist.

**The watch reported one idle bound in twenty-eight arms.** Twenty-seven ended on real events. That
single `watch-idle elapsed=1850s ticks=27` is the only positive evidence in the record that the loop
distinguishes *quiet* from *broken*, and it exists nowhere but session scratch.

## How often was I wrong

**Eight errors caught by myself, five by review, across fourteen merged slices.**

Self-caught: a row count extrapolated from synthetic rows a quarter the real size; a build cost that
counted the scan and omitted the write; a hash that hashed nothing and passed; a guard counting the
filesystem when the property was about the vault; a test searching for a word absent from its
fixture; a design-doc reading that would have made every sentence a card title *while looking like
compliance*; an ERROR count that matched a JSON field name; and a muxer read that took one array
element for the whole.

Caught by review: an unconditional scan charged to every unlock; a gap in `CountingFS` the reviewer
had **declared and not chased**; a cost model that might have been a fact about one sampled file;
`ui.design.md` never checked; and D9 asking for the feature D2 forbids — that last one the
architect found in a spec they had approved.

**The instances are on the PRs. The rate is nowhere**, and the rate is what says whether two seats
are worth their cost. Every self-caught one was found by **running a check that could fail** —
never by re-reading. That is the whole of the method, and it is not recorded anywhere a tool can
count it.

## What I did that no tool asked for

**Made checks fail on purpose before trusting them**: the never-mutate hash against a changed byte
and an added file; the materialize guard against an off-key call injected into the real scan path;
the vault counter against a disabled memo. One probe still came back broken — an `awk` edit that
silently did not apply, and a suite returning `ok` while proving nothing — caught by grepping for
the edit rather than reading the result.

**Measured instead of shipping an estimate**, twice: the lock-contention arms that dissolved a
design question into a non-question, and `enrich`'s **73.5%** share of the scan, which replaced the
central guess in quince#1512 with a number.

**Declined a piece for a stated reason** — the WS scope classifier at 3am, a confinement control,
with the mechanical error rate of the preceding hours as the argument. That judgement leaves no
trace except that it was written down.

**Did not push to a PR with auto-merge armed, three times.** Filed as quince#1514: the hazard is
real, nothing warns, and I avoided it only by generalising from a paragraph about the opposite
failure.

## A record that existed and was not found

quince#1512 says I treated `ios-backup-parser` as external and deferred an optimisation on that
basis. I attributed the correction to the Operator saying so in conversation.

**It was in `.claude/forge-set`, committed three days earlier**, as a comment justifying an entry:
*"consider ios-backup-crypt part of quince, follow the same practices. if we need changes - we make
them."* A ruling in a watch-set config, where nobody greps for a ruling — and the `qn.9` spec used
the word *"upstream"*, which is what I reused. Filed as quince#1513.

## The unreconciled window

The last watcher died at `03:14:19Z`; this retirement ran at `07:49`. **Four and a half hours
unwatched.** A successor re-arming gets what accrued by state-diff — but a PR opened *and* closed
inside that window leaves no trace in a diff of current state, so *"nothing was missed"* is not
provable, only likely. Stated because the shape of that hole is invisible from the record.
