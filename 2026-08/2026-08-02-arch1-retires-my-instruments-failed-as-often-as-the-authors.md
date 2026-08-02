# 2026-08-02 — arch1 retires: my instruments failed as often as the authors', and the review worked anyway

**Twelve of my own errors in one architect session, most of them the same class as the ones I was
catching. The review held — but not because the reviewing seat is more careful. It held because
reading is a different instrument from grepping, and the two seats fail at different moments.**

Session `arch1`, 2026-08-02. 39 PRs merged, 8 rulings relayed, 7 issues filed. The instances are on
the PRs; this entry is the **rate**, which is nowhere else.

## The count, because the instances are already recorded and the rate is not

1. **Quoted a redacted privacy finding into a review body** — re-publishing a private LAN range twice,
   in an artifact its author could not edit (quince#564, quince#565).
2. **Armed the watch with `&` inside a compound command, twice.** First time it died with the tool
   call; second time it left an **orphan** — running, ownerless, able to wake nobody.
3. **Passed abbreviated oids to `--commit-id` and `git fetch`, three times.** One `422`, one clean
   `exit=1`, one `couldn't find remote ref` — quince#243's documented trap.
4. **`awk -F: '{s+=$2}'` over `git grep -c` summed the PATH field**, printing `2026` — the year from
   a filename — as a hit count.
5. **`"a\|b"` under `grep -E`** searched for a literal backslash. Returned zero, which read as
   *the content is missing*.
6. **`grep -c "quince#539"` → 0**, and I nearly reported a follow-up as dropped from a dashboard row.
   It was present twice, written `#539`.
7. **A literal grep that could not match `only ever *upgrade*`** — markdown emphasis inside the
   phrase. The same blind spot as the author's, found while checking the author's.
8. **Named the wrong file** for a trust-semantics change — `contracts.md`, which documents shapes,
   where design §6 holds semantics. The implementer pushed back instead of complying.
9. **Told the Operator a PR would merge itself** when its approval had been dismissed.
10. **Reported a PR as never announced** when the watch had announced it into an output file I never
    read.
11. **Over-escalated a privacy incident** from a description, before reading the leaked bytes.
12. **Presented a one-line correction as a four-option ruling**, and the Operator's *"why is it so
    hard? I don't know"* was the correct response to a badly-framed question.

## What that rate actually shows, which is not what it looks like

The tempting reading is *the reviewer was sloppy*. The useful one is that **items 4–7 are the same
defect the session spent all day naming in others**: a check that ran, returned confidently, and
answered a narrower question than the one asked.

**It is not a seat property. It is a property of using tools to check claims.**

## The thing that actually caught the errors

**Every author-side finding I made today came from reading, not from a pattern.**

The ninth `only ever upgrade` site: found by *reading* the file after the count looked wrong — my
grep could not have matched it. The `#539` false alarm: killed by *looking*, after a count said zero.
The stale `qn.6f` slice table, the `FOUR SLICES MERGED` self-contradiction, the `#570` six-minute
race — all read, none grepped.

**That is why two seats work even when both seats' instruments are the same and equally broken.** The
second seat is not more accurate. It arrives at a different moment, with a different question, and it
reads. quince#565 and quince#552 are both about that failing: a verdict tool that exits `0` on
refusal, and a review body with no gate — the two places where the second seat's *output* is
unchecked.

## What has no forge fix, stated plainly

**The rate has nowhere to live.** Each instance above is on a PR or an issue; nothing counts them,
and nothing would have told a successor that the reviewing seat erred roughly as often as the
authoring one. A gate cannot compute this — it is a judgement about which corrections were the same
class.

**And "nothing was missed" remains unprovable.** `unreconciled … basis=state-diff`
(quince-devlog#196) recovers anything whose end state differs and nothing that opened and closed
inside a gap. Six or seven idle windows today reported `watch-idle elapsed≈1230s ticks=18` —
genuinely quiet — but *quiet* and *nothing happened* are the same output, and only one of them is a
measurement.

## Cited

quince#552, quince#561, quince#565, quince-devlog#191, quince-devlog#193, quince-devlog#196 — every
one filed because a tool reported success for something narrower than what was meant.
