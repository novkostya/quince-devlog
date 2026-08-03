# 2026-08-03 — `qn.6d` shipped stories 1–8, and one Operator screenshot falsified two of its own ruled decisions

**Twelve PRs merged. The three sharpest findings of the day came from LOOKING at the running product,
not from the tests, the gates, or the review — and two of them overturned decisions this rung had
ruled hours earlier.**

Implementer session `r13`. Rung issue [quince#443](https://github.com/novkostya/quince/issues/443).

## What landed

Spec ([#573](https://github.com/novkostya/quince/pull/573)) → both gaps ruled and flipped
([#578](https://github.com/novkostya/quince/pull/578), which lifted the park) → wire fields and store
queries ([#580](https://github.com/novkostya/quince/pull/580)) → the card
([#581](https://github.com/novkostya/quince/pull/581)) → the details page
([#583](https://github.com/novkostya/quince/pull/583)) → scoped `Back up now`
([#584](https://github.com/novkostya/quince/pull/584)) → `Devices` → `Home`
([#587](https://github.com/novkostya/quince/pull/587)).

Plus four defect fixes and two Operator rulings delivered the same day they were filed.

## The screenshot

The Operator deployed nothing and asked for nothing unusual — they *looked at the page*, beside a
Proxmox Backup Server table and a Windows Explorer drive bar. Three findings in one message:

**1. The bar was inverted.** I had built it to fill with the FREE fraction, arguing the number is
then *derivable* from the `X free of Y` line above it. **That argument was about arithmetic; the
failure was about what a filled bar MEANS.** An empty storage rendered a completely full bar at
100% — the most alarming thing a capacity gauge can show, for the safest possible state. PBS and
Explorer both fill by usage. [#586](https://github.com/novkostya/quince/pull/586).

**2. zfs free was wrong, and it falsified a load-bearing claim in my own spec.** The spec said
*"`statfs` is ground truth on zfs, reflink, hardlink and copy alike"*. It is not: backups live in
**per-device child datasets**, and `statfs` on the parent counts none of them — `used = 256 K`
against seventeen backups, so the card read `431.4 GB free of 431.4 GB`.
[#585](https://github.com/novkostya/quince/issues/585) → ruled → built as
[#593](https://github.com/novkostya/quince/pull/593).

**3. `Counts as of  just now`.** Vacuous, and I had hidden it from myself: the card rendered the
timestamp **only when unreachable**, where *"as of just now"* on a disconnected disk reads
plausibly. The details page rendering it unconditionally is what exposed it.
[#588](https://github.com/novkostya/quince/issues/588) → ruled **dropped** →
[#589](https://github.com/novkostya/quince/pull/589), [#594](https://github.com/novkostya/quince/pull/594).

**A vacuous field is invisible exactly where it looks most meaningful.** That is the transferable
line and it is the architect's, not mine.

## The pattern under all three

Every one of them **passed every gate**. The tests were green, the reviews were thorough, and two
seats had read the code. What none of that could do was *look at it*.

`qn.7`'s row already records this — ten UI defects on the Operator's screen, all found by clicking,
none by CI. I had that citation available and still argued a deploy would add nothing over a green
e2e run. **The reviewer had to quote my own project's evidence back at me.**

## The rate, since instances are on the PRs and the rate is nowhere

**I was corrected eleven times** across seven PRs — five by review, three by the Operator, three by
myself before pushing. Roughly half were the same shape: **a pointer left behind by a change I had
just made.** Five separate instances of it in one rung:

1. the `contracts.md` block corrected, the devlog row pointing at it left stale
2. an open question renumbered, one of its two cross-references updated
3. `storage/:id` in three places after the route key was ruled `name`
4. story 4 still mandating the counts dating this rung removed
5. the slicing table describing a sequence that had not happened

Only #5 I caught unaided. **The countermeasure that worked was never care — it was auditing the
whole artifact rather than the reported line.** Fixing what was reported would have produced the next
instance every time.

## Three times an exit code was true and the claim was false

- `make … | tail` then `${PIPESTATUS:-$?}` reports **`tail`'s** exit under BusyBox `ash`.
- A wait-loop polled for a `toolchain` container while `gates-sh` runs in `alpine:3.24` — it
  announced *"gates finished"* mid-run.
- **`make gates SCOPE=<range>` on an uncommitted tree ran one of three suites and exited 0.** I
  reported *"full ladder green"* in good faith. This is
  [quince#531](https://github.com/novkostya/quince/issues/531), and I filed a duplicate before being
  pointed at it — the instance now lives there as second-occurrence evidence, which is the argument
  that issue was missing.

The reviewer disclosed the symmetric one: an `awk` window that returned `0` on a **correct** fix,
because the field sat outside the range they chose. **Theirs is the worse kind** — a false positive
about your own work has a reviewer behind it; a false negative about someone else's has nobody but
the author contradicting you.

## What no tool asked for

- **Comparing patch-ids before force-pushing.** The merging seat and I rebased the same branches
  simultaneously; `--force-with-lease` refused; the patch-ids were identical, so I reset to theirs
  rather than clobbering it. Nothing would have detected the clobber — the tree would have been
  correct and their commits gone.
- **Verifying "the feature is built" before writing IMPLEMENTED into canon.** Accepted-and-dropped
  looks identical at the handler; the engine half is what made it true.
- **Declining to test a field's absence.** Twice. A test pinning *"this is not rendered"* would
  become the obstacle if the open question it depends on rules the other way.
- **Not deploying between two fixes** so the URL churned once — and saying so rather than letting the
  deploy line imply currency.

## Still owed

**quince#594** awaits `@novkostya`. **Forget (PR 6)** is ruled and unbuilt; **`story7` e2e (PR 7)**
owes G1b–G4 end to end. **Staging runs `main@ee54ba8`** and is behind five merges — a successor
should redeploy and check the zfs figure against `zfs list` **by eye**, because every test in #593
fakes the hook and this defect's entire history is a measurement that looked right.
