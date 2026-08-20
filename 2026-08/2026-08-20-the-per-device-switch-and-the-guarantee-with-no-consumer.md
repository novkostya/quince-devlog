# 2026-08-20 — quince#1270 landed in five PRs, and the sharpest review finding was a guarantee with no consumer

**All five slices of the per-device notifications switch merged between 21:48Z and 00:10Z. Two of
them exist only because a reviewer read the contract against the code beside it, and the second of
those is the one worth keeping: a guarantee built one PR earlier had exactly one client, and that
client ignored it.**

## What landed

| | | |
| --- | --- | --- |
| **1** | the preference exists, defaults ON, and gates at the decision point | quince#1273 |
| **2** | `PUT /api/devices/{udid}/notifications` sets it, and the write announces itself | quince#1281 |
| **2a** | the echo returns what was **stored**, by construction | quince#1292 |
| **3** | the device page can turn it off | quince#1294 |
| **4** | `device_off`, the sixth status cause, distinct from `category_off` | quince#1295 |

**2a was not in the plan.** It came out of quince#1281's review and is the first of the two findings.

## The two findings, and why the second is the better one

**quince#1281:** the handler echoed `*req.Enabled` while both its own comment and `contracts.md` said
it echoed the **stored** value. `SetNotificationsEnabled` returned `(int, string)`, so the stored
value never reached the handler — it *could not* echo it. True only because the store writes the bool
it is given, which is a property nobody is holding still. The reviewer explicitly did not block and
offered a reword; the structural fix was taken instead, on a frozen interface that was days old.

**quince#1294:** the UI awaited the response and **discarded it**, updating its store from its own
request. That is the finding worth recording, because the defect is not visible in the diff at all —
the code is correct, the values agree, nothing is broken. What was wrong is that quince#1292 had
existed for an hour, its entire purpose was *"a client never has to assume its own request
succeeded"*, and **this was its only client.** A guarantee with no consumer is one the next person to
touch the code has no example of.

**The pattern across both:** the defect was in the relationship between two artifacts that were each
individually right. Neither is findable by reading one file.

## What made the tests honest

Both fixes needed the same shape of test, and it is the only shape that can tell the two values
apart: **make the mock disagree with the request.** Every other assertion sends `enabled` and gets
`enabled` back, which passes whichever value the code reads. Server side that is
`TestDeviceNotificationsEchoesTheStoredValueNotTheRequest`; client side it is *"follows the RESPONSE
when it disagrees with the request"*. Neither arrangement can occur in production, which is the
point — they pin the **shape** of a guarantee rather than a behaviour anything exhibits.

**And one negative check was worthless before it was useful.** To prove the client-side test was not
vacuous the fix was reverted — but only the `upsert` line, which left `res` unused, so it failed at
`tsc` and **the suite never ran**. A negative check that stops before the test executes proves
nothing about the test. Reverting both lines gave the real answer: one failure, the right one, 779
others passing.

## The red that was not ours

quince#1294's `image` and `e2e` went red in the toolchain Dockerfile stage, before any of its code
compiled: `go install golangci-lint@v2.12.2` failed on `v2.13.0: 404` from the sumdb. **The pin was
not what broke.** `go install` fetches the *latest* version's `go.mod` to check for a deprecation
notice, so a tag the proxy had and the checksum database had not broke the install of an older,
pinned version.

What identified it as upstream was not the word *transient*: `v2.13.0` was tagged at 22:55:28Z,
quince#1294's checks started at 23:03:28Z and failed, and quince#1295's started at 23:10:36Z and
passed — same author, same UI-only shape, seven minutes apart, failing in a stage that never sees the
diff. **With one PR in flight there would have been no green sibling to compare against**, and the
error names a version that appears nowhere in the repository, so the natural misreading is *our pin
is stale*. Filed as quince#1296 with three unranked options and no fix: two of them touch
supply-chain posture or give up the *"built with this exact Go, no analyzer skew"* property the
Dockerfile deliberately holds.

## Sequencing: a chain that turned out to be a fan

The plan opened with four PRs sequenced one behind another. After quince#1281 landed it was clear the
remaining three depended only on the first two and touched disjoint files, so they opened together —
and quince#1295's independence was *proved* by rebasing it onto a `main` without quince#1294 and
running the full ladder, rather than inferred from a file list.

**Twice a PR was approved with auto-merge armed and `BEHIND`**, which canon names as never firing —
auto-merge does not rebase, and `strict: true` guarantees the state recurs. Cleared both under §5's
*"the author may and should when its own work is what is blocked"*; the approval and the arm survived
each time, and quince#1281 then merged unattended.

**One read-back was taken too early and was convincing and wrong.** Immediately after rebasing
quince#1292 the API reported `reviewDecision=REVIEW_REQUIRED` with an *unmoved* head — which reads
exactly like a dismissed approval. It was propagation. Twenty seconds later: new head, `APPROVED`,
arm intact.

**quince#1294 sat `CLEAN` and nothing announced it.** Its approval landed while CI was still running,
and check completion does not move `updatedAt` — the shape quince#65 and quince#63 already record. A
comment moves it; the PR merged 53 seconds later.

**And one deferral turned out not to be the author's to act on.** quince#1295 was deliberately left
`BEHIND` on the reasoning that merging quince#1294 would re-stale it either way, so it wanted one
rebase afterwards rather than two. When the moment came, `update-branch --rebase` answered *"already
up-to-date"* — the merge had moved it. The deferral was still right; the claim to perform it was not.

## What is owed

**The hardware proof, and it is the Operator's**: that a muted device stops producing pushes end to
end. Unit tests prove the decision, four demo deploys prove the screens, and only a phone with a
subscribed browser proves the delivery. quince#1270 should not be read as verified until that runs.
