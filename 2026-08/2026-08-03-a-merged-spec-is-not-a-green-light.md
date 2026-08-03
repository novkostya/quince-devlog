# 2026-08-03 — a merged spec is not a green light: the `qn.6d` park survived its own PR merging

**The code-owner approval arrived with an EMPTY body and no ruling, and the rung is still parked.
Approving a PR that CONTAINS `PROPOSED (gap)` blocks is not ruling on the questions they ask** — and
the whole point of a marker surviving a merge is that it keeps saying *stop* from inside `main`.

quince#573 merged at `0e0cf46`, `2026-08-03T05:13:01Z`, by `app/quince-review`. It carries
`docs/specs/qn.6d/qn.6d.md` and **two live `PROPOSED (gap)` blocks in `docs/contracts.md`**.

## The trap, stated plainly because it is easy to walk into

A session that finds a merged rung spec on `main` will reasonably read it as *the rung is open, start
building*. Here that is wrong. The spec's own PR slicing table says **PR 3 is blocked on gap A and PR
6 on gap B**, `contracts.md` carries both markers, and quince-devlog#197 has both live on the
dashboard as open questions 2 and 3.

**What the approval established:** the questions are well posed and the rung is correctly scoped.
**What it did not:** either answer.

Reading it the other way has a specific failure mode the architect named before it could happen — a
block would *quietly become its own recommendation*, and once merged that is unfalsifiable, because
nothing distinguishes *the Operator agreed with this* from *nobody ever said*.

## How it was checked rather than assumed

Both seats looked, independently, before concluding no ruling existed: the review body is empty; no
`@novkostya` comment on quince#573 since the previous evening; none on quince#443; none anywhere in
the repository's recent issue-comment activity.

That mattered because **three outcomes had been pre-agreed on the PR hours earlier**, and they differ
in what gets edited:

| outcome | what happens |
| --- | --- |
| rulings before merge | flip both blocks **in this PR**, and rewrite the slicing table, because a slicing table is a status table (quince#409) |
| **rulings absent at merge** | **blocks stay live, table stands, PRs 3 and 6 flip — and SAY SO at merge** |
| partial ruling | flip the ruled one, leave the other, and describe the **mixed** sequence honestly |

The middle one happened, and both seats recorded it in as many words so it reads as chosen rather
than forgotten. **Agreeing the branches in advance is what made a five-hour stall cost nothing** —
neither seat had to re-derive anything when the approval finally landed at `05:09:58Z`.

## The smaller lesson underneath

`qn.6c`'s sequence — spec merges carrying live blocks, rulings arrive after, each implementing PR
flips its own — was inherited here **by circumstance rather than by choice**, and nearly by
accident: the reviewer's landing note had assumed the opposite, and I had the contradicting clause
sitting in my own slicing table without noticing the two disagreed. Catching that cost one comment.
Not catching it would have produced a merged spec describing a sequence that did not happen, which is
this project's most-filed defect and the fourth instance of it in that single PR.

## What is owed

**Two Operator rulings, and they are the only thing between `qn.6d` and code:**

- **Gap A** — `Storage` gains space and counts. Sharpest sub-question: `statfs` reports the
  **filesystem**, so two storages that are two directories on one disk each claim the same free space
  unless the field names say otherwise. That is `qn.6c`'s own G1 fixture, not a hypothetical.
- **Gap B** — Forget's shape: resource-delete versus config mutation, restart question folded inside.
  The addressing key is **already** ruled (`{name}`, quince#570) and is not part of it.

`qn.6d`'s PR 2 — `Devices` → `Home` — is **not** blocked by either; it is held at the Operator's
direction and rests on an IA ruling already taken on quince#443.
