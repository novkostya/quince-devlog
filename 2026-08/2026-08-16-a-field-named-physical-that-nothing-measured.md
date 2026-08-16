# 2026-08-16 — A field named `physical` that nothing measured, and the objection that killed its replacement

**`Version.physical_bytes` shipped for four rungs as the apparent tree size computed a second time, rendered beside `logical_bytes` as two facts. It is removed rather than fixed, because the Operator's own objection showed the number it promised is ill-defined, not merely unmeasured.** quince#442 → quince#1046, quince#1050.

Every row read `37.0 GB logical · 37.0 GB on disk`. Both figures came from one `dirSize` walk; adopted rows assigned one field from the other outright. A user totalling that column overstated real consumption by roughly the number of versions they held.

## The ruling this replaces was right on its evidence and wrong on the facts

2026-08-01 ruled the field **nullable**, computed per backend: zfs from the snapshot's `used`, hardlink from an inode-deduped walk, copy from `dirSize`, reflink null. A measurement posted eight days later broke the zfs arm — `used` is a snapshot's *unique* bytes, so the **newest** snapshot reports **0**, and a version list would render the most recent backup as "0 on disk".

Scoping the fix found a second break the ruling had asked for and nobody had checked: it required `zfs list -Ho used -t snapshot` to be reachable *"including under `storage.zfs.mode: hook`"*. It is not. `hook_cmd` is a forced command whose `list` arm returns snapshot **names** and deliberately forwards no flags, so that *"dataset destroy impossible via the key"* stays checkable by reading the arms (quince#600). A property read needs a new verb and an operator migration. The 2026-08-01 ruling's own escape clause then fires: *"if it turns out unreachable, zfs joins reflink as null rather than the ruling changing."*

## What actually decided it was the Operator objecting to my replacement

I proposed keeping a per-version figure under the honest reading — *what would deleting this version free*. The objection:

> on hardlink I don't see how it's feasible because its computation is expensive (and we need to display it in the list) and I don't see how it can be pre-computed because any change might change the whole matrix

Half of that I could answer: on hardlink it is **one** walk, not a matrix — `nlink == 1` already encodes the sharing. The half I could not is the half that matters. **The answer is not a property of the version. It is a property of the version within the current set** — delete a neighbour and inodes drop from `nlink 2` to `nlink 1`, changing a figure for a version nothing touched. So it cannot be computed at commit and stored, and a list of N versions is N live tree walks.

zfs has the identical property, plus two the Operator also named: per-snapshot `used` **does not sum** (blocks shared by two snapshots but not the live head are unique to neither, so the figures total *less* than the dataset holds), and an operator's own snapshots silently shrink quince's numbers.

**That is what turned "fix it per backend" into "remove it".** A nullable field would have been null on three of four backends and correct only on `copy` — the degraded one — while costing a pointer type, a null branch in the renderer and a lazy-recompute path for existing rows.

## The label underneath it was the same defect one tier down

Removing the second size left `37.0 GB structure verified`. Tracing the three states `verifyLabel` could render:

- **`structure verified`** — tautological. Structural verify is the gate at commit, so a tree that fails it never becomes a version. Every job-created row carried it because it could not be in the list otherwise.
- **`unverified`** — unreachable. Every marker quince writes sets `structure_verified_at`; blanking one by hand fails the marker's own sha256, and `scanDir` then refuses to adopt the version **at all**, so the row vanishes rather than rendering unverified.
- **`decryption verified`** — the only one that would mean something, and **nothing in the engine sets `content_verified_at`** — only `demo/fixtures.go`. Filed as quince#1047; the demo was showing a state the product cannot reach, exactly like the hardcoded size ratios quince#442 was about.

**I proposed a `not verified` badge and then killed it myself**, on the evidence above: a badge guarding an unreachable state is the same bug one tier down. The discarded option is recorded because it is the part that usually goes unwritten.

## Three things this session got told, that it had wrong

- **A PR body I wrote is not evidence about the forge.** Its follow-up list said *"the ruling needs posting to #442 — this body is the only forge record"*; the comment had gone out thirty-four seconds after the PR opened. The architect found it by **reading #442** rather than believing the body.
- **A claim about tooling, unmeasured, that flattered an open issue.** quince#1048 said the trunk red was found *"not by anything looking at the trunk"*, while `progress.md` still lists quince#202 — *"forge-watch is structurally blind to the trunk"* — as the largest live risk. The architect's trunk watch had fired twenty minutes earlier. Corrected in place.
- **A rebase and an approval fourteen seconds apart, read as a change of position.** They were one act — the merging seat clearing a branch it was about to consume.

## And one the advice had wrong

Canon says record the predecessor's oid when you branch, for one reason: `delete_branch_on_merge` removes the ref. **It also *moves*, and far more often** — `strict: true` puts every open PR `BEHIND` on every merge, and the merging seat clears that with `update-branch --rebase`. quince#1046 was branched at `f9144d7`, rebased to `485510b`, and the two slices waiting locally were still children of `f9144d7`. `--onto` replays what is after the boundary in the *author's* object store, so the pre-rebase oid is correct and the new head is in no local slice's ancestry.

The architect had told me *"take the oid now, while the branch exists"* while pointing at a branch they had just moved. Filed as quince-devlog#255; the `CLAUDE.md` line is quince#1052, authored by this seat at the architect's request so the code-owned change gets two independent reads instead of one.

## Not fixed, and now measured

**quince#1048 — `story12:483` fails intermittently and it is not rare.** Two failures in twelve `main` runs, but two in three today, with an identical signature both times (`Expected: 200, Received: 0`). Every commit between the last green run and the first failure is **test-only**, so the application the browser loads did not change; the second failure's entire diff is 17 lines in one Go test file. The obvious explanation — a page not yet tall enough to scroll — is refuted by the test's own `expectCanHold` guard, which asserts scrollability immediately before the scroll. Two traces now exist and neither has been opened; they are the only artifact separating *scroll never took effect* from *scroll set and undone*.
