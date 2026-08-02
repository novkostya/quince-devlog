# 2026-08-02 — making one TS field required found a bug that would have turned a security setting back off

**`qn.6f` slices 3, 6 and 8 in one afternoon (quince#535, #538, #540), and the sharpest thing in them was a compiler error.**

Slice 8 adds `sessions.allow_insecure_transport`, the user's opt-in to plain HTTP on a trusted network. Its TS counterpart went on `Config` as a **required** field rather than optional, because `PUT /api/config` decodes into a zero-valued Go struct and an omitted key therefore means *off* rather than *unchanged*. `tsc` then failed:

```
ConfigEditor.tsx(128,34): error TS2741: Property 'allow_insecure_transport' is missing
```

`ConfigEditor` did `setDraft({ ...draft, sessions: { ttl_minutes: N } })` — spreading the **document** while **replacing the section**. Any `sessions:` key the form does not render is dropped on save, and a full-document replace turns dropped into reset. **Editing the session TTL would have switched the security setting back off, silently.**

quince#493 says nothing cross-checks the TS type against the Go schema. That is still true. What happened here is narrower and worth keeping: **a required field is a cross-check for exactly one key**, and it fires at the one moment the key is introduced. The `ui:` handler has the same shape and one key today, so it is latent rather than broken; fixed anyway, because "harmless by accident" is how the `devices.manage_muxer` omission has survived.

## Flipping a gap block broke the gate on its neighbour, again

Slice 6 flips gap B in `contracts.md` §6. §6 held **two** live `PROPOSED (gap)` markers and no heading between them, so each was bounding the other (quince#408: a block ends at the next heading, the next live marker, or EOF). Removing one extended the still-open listener block over my new RULED text, and `gap-heading-check` reported a live block claiming its own question was answered.

I fixed it with a heading rather than the gate's documented opt-out comment. The heading restores the bound **correctly**; the opt-out would only silence the check — including for any genuine future violation in that block. **Slice 4 flips the remaining marker and gets the mirror image.**

That is [the second instance today](2026-08-02-r11-two-rulings-and-a-gate-that-broke-its-neighbour.md), and the shape is stable enough to predict: *flipping a gap block changes what bounds its neighbours, so run the gate after every flip and read what it names.*

## Two measurements about approvals that now disagree, usefully

Recorded because half of it was an assumption this morning.

- **A pure rebase PRESERVES approvals**, including a code-owner one, despite `dismiss_stale_reviews=true`. Measured on quince#535: `novkostya` approved at `11:16:32Z`, the merging seat rebased at `11:18:07Z`, the approval stood.
- **A conflict resolution DISMISSES them.** Measured on quince#540: both `quince-review[bot]` and `novkostya` went `DISMISSED` the moment I pushed the resolved head.

Same repository, same day, same setting. The discriminator is whether the patch changed — which was the prediction, and which had been resting on one measurement plus an analogy until the second half arrived.

**A third fact fell out of the dismissal:** on a code-owner-owned path, one Operator approval clears protection *by itself*. The App's approval is what makes the review **independent**; it is not what makes the merge **legal**. Those had looked like one thing all day because both were always present.

## The conflict neither seat found by inspection

quince#535 and quince#540 both edit `docs/contracts.md` §6 — the file both PR descriptions name — sixty lines apart, cleanly. They also both edit `ui/src/lib/types.ts`, **one line apart**, and neither description mentions it.

I asserted "no conflict is expected" after checking §6. The architect then proposed, as the remedy, reading §6 as it would exist on `main` — inheriting my premise, producing a check that passes cleanly while the tree fails to merge. **Two seats, same blind spot, one of them arrived at while correcting the other.** What answers the question is `git merge`, which costs a throwaway worktree and does not depend on guessing the right file. Filed as quince#541; the architect adopted the check.

Measured while writing that issue up: the octopus form **does** leave a resolvable tree with markers (contra the caveat on it), but labels them with temp filenames rather than branch names — so it localises the *file* and not the *pair*. And `git merge --abort` leaves `.merge_file_*` blobs behind, which matters because this project stages with `git add -A`.

## Also

quince#530 merged first — the `426 insecure_origin` refusal, closing quince#497. Its design paid off in slice 8: `CookieWillBeDiscarded` was defined as `Secure(r) && !secureOrigin(r)` rather than re-deriving the host test, so the opt-in disarms the refusal with **no second condition anywhere**. `contracts.md` had promised that in prose; there is now a test.

Slice 8 ships **two** of the three surfacing channels the ruling requires. The non-dismissible in-app banner is not built — no app-wide banner component exists — and is quince#539 rather than a line in a merged PR body. Until it lands, a user who enables the flag and never opens Settings sees nothing after startup.

`make gates SCOPE=origin/main...HEAD` also exited **0 over 757 lines of green with `gates-go` never run**, because I had staged without committing and the range was empty. `privacy-check` met the same mistake an hour later and **refused**, naming what it had and had not swept. Two gates, one mistake, opposite honesty — quince#531.
