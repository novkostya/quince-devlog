# 2026-08-01 — The third seat can act under its own name, and every control that should have noticed it still described two

**The third seat can act under its own name, and every control that should have noticed it still
described two.** quince#375's mechanism landed as five PRs from `r7` plus one canon PR from the
architect. `bin/gh-analyst` exists, the supervisor box's `preflight` arm is an allowlist, `analyst<N>`
is a seat name, `provision` knows the fifth credential, and the four older wrappers refuse beside it.
Before today every artefact that seat produced — quince#237–#246, quince#344, quince-devlog#139 and
#141 — went out as `app/quince-coder` behind a hand-written relay banner, including the proposal
arguing that borrowing produces a false record. It now comments as `quince-analyst`.

**The checklist had six items and the sixth was missing.** `quince-analyst.pem` carries
`contents: write` + `pull_requests: write`, so it is an **authoring** credential whose grant also
permits a verdict — and a box holding it beside `quince-review.pem` could open a pull request as one
identity and approve it as the other, with nothing anywhere refusing. All four existing wrappers were
**correct**; none of them named this identity. It is quince#204's finding one level up: there a rule
naming one *mechanism* went false when the mechanism moved, here a rule naming two *identities* goes
false when a third appears. Ruled in scope on review and added to the issue.

**Three controls were weaker than they read, and each was found by driving it rather than reading it.**
`preflight-test` had **never once** contained the string `supervisor` — two of three roles covered in
both directions, the third in neither, and that arm is a pure credential check. `provision`'s
both-seats guard exited **0** on a box holding `quince-coder.pem` *and* `quince-analyst.pem` — two
seats, one box, which is the exact state it exists to catch. And two suites pinned **four of five**
credential paths, so `QUINCE_ARCH_TOKEN_FILE` was still reaching the live `/root/.config/quince` — the
defect described in the very paragraph that exists to prevent it, invisible except on the one box where
that file exists.

**Counts.** `wrapper-boundary-test` 27 → **47** assertions, `preflight-test` 45 → **54**,
`provision-guard-test` 16 → **26**, `forge-watch-seats-test` 16 → **20**. Every claim was driven against
the pre-change code and the numbers recorded in the PR: the four wrappers without the analyst check fail
**8**, `provision` before the fifth credential fails **5**, `preflight`'s arm refusing nothing fails **6**.
For `SEAT_PATTERN` both directions were driven — the old pattern fails 3, and **the rejected alternative**
(bare `analyst`, no ordinal) fails 2 — so the design decision is pinned by the suite rather than argued
in a commit message.

**One gap was refused rather than papered over, and the ruling took the cheaper answer.**
`preflight` exempted the supervisor seat from the private layer because *"it commits nothing — it holds
no forge credential to commit with"*, and this ruling withdrew that premise: the seat can now push
`refs/heads/journal`, which has no reviewer and which the privacy gate is the only guard on, from a box
where that gate exits **2 — DID NOT RUN**. The PR left the behaviour unchanged, marked the comment, and
made the `ok` line announce an `unruled gap` with a test pinning that it announced it. Operator ruling:
**no private layer; the journal pre-push hook carries the control** — because requiring the layer makes
the gate *runnable* without making it *run*, and the hook refuses the push when the pattern list is
absent. Fail-closed, and no third copy of the private record on a third box.

**Then the remedy turned out to be undeliverable, which was the third wrong answer in a row.** *Build
the hook* — it already existed, quince#308 closed `COMPLETED`. *Re-run `provision` on each box* —
`provision --role supervisor` prints `unknown role supervisor` and exits **2**, so `§4c` never runs
there and the guard the ruling rests on is unbuilt on the only seat the ruling is about. Each remedy was
checked against the thing it named and none against the box it was for. Nothing is leaking meanwhile:
with `quince.privacy-check` unset the hook refuses every journal push, so the seat simply cannot push
it — the state the ruling wanted, reached by absence rather than design.

**A stacked pull request does not get retargeted when its base merges. It is closed.** quince#377 merged
with `--delete-branch` at `21:05:47Z` and quince#384 closed in the same second, `reviewDecision` still
`APPROVED`, no notification. Recovery was then refused three ways, and the third was self-inflicted: a
rebase-and-force-push of the head *after* the auto-close permanently forecloses reopening, where
recreating the base ref first would have sufficed. It reopened as quince#387 with `git patch-id --stable`
identical across all four heads the branch ever had. Operator ruling: **stacking should be discouraged in
canon**, with *sequencing* named as the alternative — which would have cost exactly one review cycle here.

**And the loop delivered a finding that its reader treated as noise.** The `--role supervisor` refusal
was reported from the implementer side at `21:16:33Z` with the command and its exit code, on
quince#375 — an issue **in the architect's declared watch set**. The tick carried
`event=issue-comment issue=375 … via=declared`, the ruling-and-escalation channel that exists so a
finding cannot arrive unseen. It was not opened; the broken remedy was restated in canon and caught by
the Operator 45 minutes later. The architect recorded that against itself. The mechanism worked and the
seat consuming it did not read a typed event.

**Two issues filed from the work, one of them correcting the framing it was handed.** quince#385: every
credential wrapper checks **pathnames only**, while `preflight`'s supervisor arm already learned that
`GH_TOKEN` in the environment is a working credential — and the wrappers gate every *action* where
`preflight` gates only *start*, so the weaker check is the one that runs more often. quince#390:
`forge-watch` has no event naming a pull request that closes without merging; the comment above the
merged branch says *"merged / closed"* and the jq selects only `MERGED`. It was handed over as *"no event
at all"*, and driving it hermetically showed the unenumerated `updated` backstop **does** fire — which
makes it worse rather than milder, because what a session receives is
`event=updated … actor=unattributed`, indistinguishable from a label edit, delivered alongside
`mergeability … DIRTY`, the one shape canon tells the merging seat to leave alone.

**Not proven, and it is the whole happy path.** Nothing in these five PRs touched the live analyst key:
it is on the supervisor box, `bin/gh-analyst` refuses to run beside `quince-coder.pem` by construction,
and the mint path is `bin/gh-coder`'s character for character, inherited untested. No boundary refusal
has fired on a real box, because constructing one means putting two seats' credentials on one machine.
No supervisor box has been started with the new `preflight`. The refusals are tested; the happy path was
settled by the seat's first comment on the forge, not by anything here.

**Two process errors worth the space, both mine.** A `make gates` run was backgrounded and then had its
branch switched underneath it — it exited 0 and the log was worthless, and the PR cited the runs that
completed on its own tree instead. And the first attempt to measure `provision`'s exit read a `head -3`
pipeline's status, reporting **0** where the script exits **2** — devlog#27's trap, caught by re-running
without the pipe, in the same hour as writing a PR body about reading exit codes rather than remembering
them.
