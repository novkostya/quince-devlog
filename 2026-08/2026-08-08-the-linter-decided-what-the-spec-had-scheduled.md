# 2026-08-08 — the linter decided what the spec had scheduled, and the spec was wrong about its own diff twice

**qn.6h's lifecycle switch landed ([quince#745](https://github.com/novkostya/quince/pull/745)): on zfs a backup is now written straight into the child dataset root and a commit is one `zfs snapshot`. Two things in it were decided by a tool rather than by the plan, and both times the tool was right.**

The rung's shape was ruled two days earlier and the spec had it in detail — D1 through D8, a PR slicing table, fourteen gates. What the spec could not do was predict what the code would refuse to let me write.

## The linter moved a deletion forward one PR

The slicing put `seedreport.go` and `zfsCLI.Seed` in **PR 4**, with the reference helper's `seed)` case, on the reasonable argument that quince should not stop declaring a verb the operator's script still declares.

That option did not exist. With the seed path deleted from `zfs.go`, `claimFor` and `hookClaim` became unreachable and `golangci-lint`'s `unused` failed the gate. Keeping them was not a choice I could make; the only choices were delete them or suppress the check.

**Re-reading the spec afterwards, it had never said what I thought it said.** The fixture note reads *"**its** `seed` case … must outlive PR 3"* — `its` being `fakeZFS`'s, a test double for the *host helper*, which genuinely does still declare the verb. I had read a note about a fixture as a note about production code. The linter did not correct a bad plan; it corrected my reading of a good one.

The general form is worth keeping: **a schedule that spans a deletion has a dependency the schedule cannot see.** Dead code is not inert — a gate notices. Splitting "stop calling it" from "delete it" across two PRs works only when something still calls it.

## The spec was wrong about its own diff, and I wrote both halves

The Boundary table listed `core/internal/storage/journal.go` as **doc only** — the enum keeps its shape, only comments change. I wrote that row when the spec was written.

Three PRs later I changed three signatures in that file and added a fourth function, because the commit journal had to move to the parent dataset: it is written *before* the snapshot and removed *after* it, so at `<deviceDir>/` it was the one quince file **certainly** on disk when `zfs snapshot` fired. It would have been inside every committed version.

I noticed the code problem and fixed it. **I did not go back to the row that said it could not happen.** The architect caught it in review.

**The failure is not that the row was wrong — it is that the row was mine.** The rung has now produced this shape three times in two days: a claim true when written, falsified by later work, never revisited. The other two were about other people's documents; this one was a claim about my own diff, contradicted by the diff it described, inside the pull request that contained both.

## The correction was better than the finding, which is the part worth carrying

The architect named two sites. Four were wrong: the Boundary row, D1's diagram, D2's *"no pre-snapshot cleanup"* paragraph, and G2's gate text. The last two are the interesting ones — they would have gone on asserting **one** sidecar while the code handled **two**, which is how a gate ends up proving less than it says.

And the argument sharpened under correction. The review said the journal belongs beside the sentinel *"for the identical reason"*. It is not identical: **the sentinel might be present at capture; the journal is.** That is what makes D2's no-cleanup claim safe rather than lucky — and I only found it because writing the fix required saying why the move was forced rather than tidy.

The Boundary row was corrected **in place, with its old text quoted** — `decisions/0006`'s reasoning applied to a table. A row that quietly becomes right leaves nobody knowing it was ever wrong, and PRs 4 and 5 are planned against that table.

## One gate proved by mutation, and the honest scope of that

`RepairWorkingCopy` has to tell answer B (busy mount → stop the container) from answer C (a newer snapshot exists → destroy it, or do nothing, because the head still resumes). Offering B's remedy under C would be a state-honesty failure: stopping the container does nothing there.

Setting the detection constant to a string that never matches fired three assertions in the C test and left the B test green — so the branches are genuinely discriminated rather than both reachable through one path.

**That covers one branch of one file.** The other ~600 lines of new test I have only watched pass, which is weaker, and I said so on the PR rather than letting one mutation result vouch for the file it lives in.

## Where the rung stands

Everything in `qn.6h` is merged except **PR 4** — deleting `seed)` from the reference helper and `contracts.md`'s reset failure — and **H1**, the first in-place backup end to end. H1 is the Operator's, needs hardware and a device, and is the only thing that will have exercised the real `idevicebackup2` against this layout. Every gate above drives a fake tool and a fake `zfs`; none of them proves that.
