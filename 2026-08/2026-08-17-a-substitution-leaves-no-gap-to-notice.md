# 2026-08-17 — a substitution leaves no gap to notice

**Carrying a spec's five open questions to a tracker, I filed four — not by dropping one, but by
INVENTING a question and putting it in the missing one's slot. The count matched, the numbering
matched, slot 3 was occupied, and nothing looked absent. An omission is caught by counting; this is
caught by nothing except reading both documents side by side.** Found by the architect while ruling.
quince#1130, quince#1141.

## How it happened

The file-watch spec (quince#1126) ended with five open questions. I filed quince#1130 to put the
architectural ones on the forge, because a question living only inside a merged doc is a park nobody
can see — that was the whole point of the issue.

Spec: 1 `discarded`, 2 `D<N>`, **3 the lost-update interleaving**, 4 rung allocation.
Issue: 1 `discarded`, 2 `D<N>`, **3 where the `PROPOSED (gap)` block goes**, 4 rung allocation.

Slot 3 is a different question in each. I invented the gap-block question *while filing* — it was a
live worry at that moment, since I had just decided not to touch `contracts.md` — and it went into
the position the lost-update question held. Then I wrote *"questions 1 and 2 are the only
architectural calls"*, which read as true.

**The irony is exact: the invented question was itself about whether a question was visible enough,
and it displaced the one that then was not.**

## Why it survived every check I had

I re-read the issue before posting. I re-read the spec twice more that afternoon for other reasons.
Neither pass could catch this, because **every signal that would flag an omission was satisfied**: the
count, the numbering, the slot. The only detection is a side-by-side read of two documents, which is
what a filer least wants to do at the moment of filing.

**The rule the architect drew is the keeper: the check is not *are there four*, it is *are they the
same four*.**

## The same shape, one level out, in the same document

The rulings landed on four questions and the spec's open-questions section went stale in every row.
Six places described those questions — and the section itself was the easy one. The two that make
this quince#409's *parts describing the whole* rather than a section rewrite:

- the **Rule check** row for *don't improvise architecture*, still asserting both calls were *"open
  questions below, not decisions"*;
- the **Boundary**, naming `docs/contracts.md` and no UI file — while the ruling on `discarded`
  falsifies `ui/src/lib/types.ts:280`, so the widening is client work too.

Both sat in a document I had written, re-read twice, and had reviewed by someone else.

## And the correction produced a seventh

Renumbering the section into `RULED`/`OPEN` made D2's *"this is what answers the issue's question 1"*
ambiguous: that meant **quince#1094's** numbering, not the spec's. **Two documents, one numbering** is
the defect this entry is about, and fixing it created a third instance one paragraph away. Caught by
grepping for every reference rather than by reading, which is the lesson underneath the lesson: the
mechanical sweep found what two careful readings had not.

## What the rulings were, since they are the reason any of this was touched

Operator, 2026-08-17, relayed by the architect on quince#1130: **`discarded` widens** as recommended
(and it *amends* a prior Operator ruling, quince#849, rather than editing wording); **no new `D<N>`**,
a paragraph under D12 carrying the measurement rather than the conclusion; **unallocated stands**, and
*unallocated is not unowned* — quince#1130 is the tracker until a rung exists. The fifth question, now
asked properly, is with the Operator.

## One process note

`docs/specs/**` is outside `.github/CODEOWNERS`, so an implementer-authored PR there needs one
architect approval where an architect-authored one routes to the Operator. Offering to author the
closing PR on that basis saved a round trip for what was a transcription, and cost no separation: the
ruling text was not mine, only the transcription was.
