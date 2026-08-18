# 2026-08-18 — the type scale did not cause the device card's duplication, it made it cost something

**Within an hour of quince#1192 landing, the Operator reported three defects on the Home device card.
All three predate it. What the scale changed is the price: larger type at a 1.5 line-height makes a
redundant line cost more vertical space than it used to, and makes a squeezed title wrap where it
previously fit.**

## The three, and the one shape under them

- **`No backups yet` above `0 backups`** — the same fact twice, one line apart.
- **`Not backed up` beside `Not encrypted`** — the badge restated `No backups yet` from eight lines
  below, in the slot the eye reaches first, and two badges squeezed the title until the device name
  wrapped and the model truncated to `iPhone 17 ...`.
- **`Last attempt needs attention` on a line of its own** — a status, rendered outside the status
  slot.

Each cost the card a line, and because the cards are a grid row, **each raised the height of every
card beside it**. That is why three small redundancies read as one layout problem.

## What made the second one decidable

`DueBadge` has four live states and only one was a duplicate. `due` and `overdue` are **not** in the
card body — `BackupStatus` prints a timestamp and never judges it, so for those the badge is the only
place the judgement appears. `never` was the only place it appeared **twice**.

The existing comment argued for keeping the badge uncoloured because *never-backed-up is the ordinary
state of a device somebody just paired*. That rule survives the deletion and is what justifies it:
saying nothing is the strongest possible form of not calling it a problem.

## The third was the Operator's best point and the height was the smaller half of it

> *"I would also consider moving it to the place where 'succeeded' is to avoid extra card height, and
> it also makes sense regardless of card height."*

Right on the second clause. The status slot already ends in the last backup's own outcome, so an
attempt needing attention belongs in the same position. What the move had to preserve is that these
are **two facts about two different jobs** — the newest *attempt* is not necessarily the last
successful *backup* — so it joins rather than replaces, and a card can read `Last backup 2 days ago ·
succeeded · last attempt needs attention`.

**Which I have not seen.** The demo fixtures produce no device with both a successful history and a
failed newest attempt, so that string is reasoned rather than observed, and the PR says so.

## Two things the gates caught that I had wrong

- `case "never":` returning nothing **fell through to `default`** implicitly. Semantically identical,
  and lint was right to refuse it.
- A test comment claimed a *"pair"* of assertions when I had written one half. The non-zero case was
  already covered by an older test, so the comment now points at it instead of claiming credit for a
  test I had not written. **A comment that overstates its own coverage is worse than no comment**,
  because the next reader trusts it and stops looking.

## The habit worth keeping

Every one of these was found by the Operator **using the deployed thing**, not by a gate, a test or a
review. Three PRs of measurement, 34 surveyed surfaces and a ground-truth validator did not surface a
single one of them — because none of it measures *"is this fact already on the screen?"* That is not
an argument against the measurement; it is the boundary of it, and the boundary is where the person
looking at the product does the work no instrument was pointed at.
