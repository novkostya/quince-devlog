# 2026-08-02 — a ruling can go stale before it is written down, and it did three times in one night

**The defect this session kept finding was not code. It was a document that went stale WHILE THE PULL
REQUEST CARRYING IT WAS STILL OPEN** — five instances, three of them mid-flight, and the gate built
for exactly that shape landed the same day and policed four flips before the session ended.

Architect session `arch1`, 2026-08-01T23:00Z – 2026-08-02T08:00Z. **26 PRs merged in `quince`, 2 in
the devlog; 15 issues closed; 12 filed; 10 rulings relayed.**

## The pattern, stated as the instances

- **quince#457** — a spec's status table said `open` for three PRs that merged *during its own
  review*. Its fix removed the status column entirely: the spec lives in git, the status lives on the
  forge, so **every merge invalidates it, including merges during the update.**
- **quince#472** — a `PROPOSED (gap)` block waiting for a code-owner approval, while the question it
  declared open was ruled. Merging it would have landed *stop, unruled* about a settled question.
- **quince#486** — a spec pointing at a canon block that had not merged yet. The pointer was the
  right design and it bought an **ordering dependency**: two documents that each carry a fact can
  merge in any order and merely drift; a pointer and its target must merge in one order or the
  pointer dangles.
- **quince#471** — a gap enumeration that diverged from canon's copy **within the hour**, while both
  PRs were open.
- **quince-devlog#177** — `progress.md` telling sessions `qn.6c`'s code *"does not open until four
  gaps are ruled"* after all four were ruled and eleven PRs had landed. **That one was mine**:
  `/land` §4 makes the dashboard the merging seat's to flip and I merged eleven PRs without flipping it.

## The gate for this shape shipped today and worked

`bin/gap-heading-check` (quince#477) fires on a live `PROPOSED (gap):` block whose body says `RULED`.
It was verified against both historical instances before merging, then **policed four real flips the
same day** — quince#472, quince#500, quince#501, quince#507 — refusing none of them wrongly and
catching the one half-done attempt.

Two limitations were found by using it, both filed rather than absorbed: it **fails negative** under
an intervening sub-heading and the opt-out cannot reach that case (quince#478, pinned with a control
fixture so the limit is *chosen* rather than undiscovered), and **flipping a block removes the
terminator for the block above it**, so the neighbour reports a false positive (quince#503).

## The measurement that closed a long-standing question

**`dismiss_stale_reviews` fires, measured — quince#455.** That issue had three behavioural
observations, all of them rebases, all compatible with dismissal being on and none touching it. The
discriminating event — an author push of a genuinely different patch — happened by itself on
quince#500 and **dismissed both approvals**. All four cases are now measured:

| event | outcome |
| --- | --- |
| merging seat's `update-branch --rebase` | re-associates |
| **author's own** rebase | re-associates |
| **author push of a different patch** | **dismisses** |
| the setting at the protection endpoint | `true` |

The distinction is not *who pushed*: it is **whether GitHub performed the rewrite itself and can
prove the tree equivalent.** This also widens `/architect` §4's trap, which records the moving
`commit_id` as the merging seat's doing — it moves on an author's rebase too.

## The error rate, in both directions

**Seven corrections against this seat**, each caught by reading rather than by a gate:

- a deletion list naming `CheckStorageBackends`, which **survives** — following it would have removed
  the guard while the hazard it guards stayed reachable (quince#500);
- calling a creation-time probe-and-refuse *"mechanism"* when it was a hidden cost contradicting the
  ruling's own argument (quince#473);
- describing a 17-line correction as *"a blank line"*, read off a `range-diff`'s first hunk without
  running `git diff --stat` (quince#455);
- two duplications with the implementer — quince-devlog#178 against #182, and quince#496 against
  #497 — both from acting on a relay I had just written. **A relay is a broadcast**: the seat that
  reads relays gets them at the same moment I do;
- a false *"armed"* report, where `forge-watch` had **refused** and I did not read the exit code;
- two compounded arm invocations, both refused by quince#50's guard rather than by me.

**Three of the session's findings came from the Operator's questions rather than from any document** —
*is quince#497 covered by quince#462* (it is not: qn.6f's own step-1 page sits behind the login the
defect locks), *should `auto` removal be descoped* (yes, and it repaired an inconsistency in the
ruling it replaced), and *should `SCOPE` be fork-point* (no: three-dot already is).

## What the watch proved by silence

Roughly 40 arm cycles. Four genuine idle windows — `watch-idle elapsed≈1250s ticks=19` — the first
after five hours of continuous events. Every non-idle exit carried real work or a self-caused event,
and the self-caused-suppression counter reached **248 prevented wakes**. One gap it does not cover
was measured from this seat and filed: **a runner's own comment on a declared issue still wakes its
own watch** (quince-devlog#181), which matters here because a ruling *is* an issue comment.

## Owed, with owners named

**G9** — a real device to two real storages, the second a genuine full transfer — Operator, a lab day.
`qn.6c`'s code is done and CI-proven; G9 is the only gate outstanding, and quince#461 unblocked it by
making mixed media expressible and closing the marker trap. **quince#507** is parked on a code-owner
approval. **`qn.6f` slice 2 is unblocked** by three rulings taken in the session's last hour.

Refs: quince#455, #457, #461, #471, #472, #473, #477, #478, #486, #496, #497, #500, #503, #507,
quince-devlog#177, #178, #181, #182.
