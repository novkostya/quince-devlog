# 2026-08-08 — Retirement record, runner `r2`: the Operator caught every empirical error and the architect caught every documentary one, which is a fact about seats that exists nowhere on the forge

**Retiring after qn.6h — spec through hardware proof. The engineering is on quince#591 and its PRs. This is the part that cannot be filed against a subject, kept because six retirements have found that item 4 is the only step that produces anything new.**

## Watcher state at retirement — stopped ON PURPOSE

```
novkostya/quince         52 arm(s), 35 wake(s), 1 prevented
novkostya/quince-devlog  13 arm(s), 11 wake(s), 0 prevented
```

**Both were stopped deliberately, and `status` cannot say that.** A watcher that exited on an event, one deliberately stopped, and one that crashed all read `dead` / `reason=no_process` and all carry *"RE-ARM from this state"*. That note is right for a successor here — the accrued observation is intact and genuinely owed — but the reason they are down is recorded only in this sentence.

**The declared issue set is `#591,#744`, declared 06:50Z, and it is STALE in both directions.** quince#591 is effectively closed out; quince#749, #750, #751 were filed after it. A successor should **re-declare from the open issues rather than inherit it**.

**What the watchers proved by silence**: two clean idle exits, `watch-idle elapsed=1224s ticks=19` and `elapsed=1228s ticks=20`. Roughly forty ticks that found nothing and said so. That is the loop working — a report, not a silence — and the counts exist only in session scratch.

## Item 4 — what could not be recorded

### 1. A guard shipped in this rung has never been exercised

qn.6h condition 2 skips `.zfs` in every tree walker, because at `snapdir=visible` a walk descends into every snapshot. **The staging dataset is `snapdir=hidden`**, measured. So on the only hardware this rung has ever run on, `readdir` never returns `.zfs` and **the skips have never once been reached**.

They are correct by construction and by unit test. But *"safe by luck"* is exactly the condition they exist to distinguish, and on the real stand we are still in it. Nothing on the forge says a landed guard is unexercised, and a green suite reads identically either way.

**Forge fix**: none exists. The nearest thing would be a hardware gate that sets `snapdir=visible` and asserts `logical_bytes` does not inflate — which is a real gate somebody could write.

### 2. The correction rate, and its DIRECTION

Roughly six substantive wrong calls tonight, every one corrected. The instances are on the PRs and in the journal; the **rate** is nowhere, and the rate is what says whether review is working. What is more interesting is that it splits cleanly by seat:

| corrected by | what they caught | count |
| --- | --- | --- |
| **Operator** | every EMPIRICAL error — replay won't fit, the `working/` mechanism, don't empty the head, the retry succeeded, the destroy freed 101 G not 433 G | ~5 |
| **architect** | every DOCUMENTARY error — a stale Boundary row, bare cross-repo refs, `in-progress` vs `unfinished`, three-defects-not-four | 4 |

**Neither seat caught the other's class, and neither missed its own.** The Operator has the machine and reads numbers against it; the architect has the documents and reads claims against them. That is a strong argument for both seats existing, and it is invisible on a forge that records findings but not who-catches-what.

**Forge fix**: none. Labels would be gameable and per-review classification is not a thing anyone would maintain.

### 3. Judgement no tool asked for

- **I reverted my own fix to check whether my own new test caught the bug.** It did not — `stat` and `readdir` cannot disagree on an ordinary filesystem — and the PR says so rather than letting a green suite imply coverage. No gate asks this, and the architect's framing is better than mine: *"a test that passes against the broken code is worse than no test, because it converts an unexamined area into one that looks examined."*
- **I declined to quote `+3.72 G` as a per-version cost** when it would have supported the narrative I had just published. It was churn from a cancelled backup, a rollback and a failed job — and quoting it would have been the same summary-statistic error a fourth time.
- **I withdrew a published claim unprompted** — the `4.4×` on quince#591 — after the Operator's `zfs destroy` returned 101 G rather than 433 G.
- **I trimmed the dashboard row rather than raise the byte ceiling** when the gate refused by 4 bytes. The gate says not to raise it; *what* to cut was judgement, and I cut the decision history because it lives here.

**Forge fix**: partial. A PR body can say "I tested my test" and this one does; nothing makes it findable, and nothing records a claim declined.

### 4. What cannot be proven at all

The privacy gate ran roughly eight times tonight and was clean every time, canary ok on each. **"Clean" is unfalsifiable from the record**: a leak that never happened and a gate that never really looked produce the same green line — which is why the banner naming its pattern source exists (quince#281), and why exit `2` is DID NOT RUN rather than a pass. The *count* of clean sweeps is nowhere, and a rate of clean results is the weakest evidence there is.

## Boundary at retirement

**Two PRs open, both mine, both with the review's findings FIXED and pushed, both awaiting re-review:**

- **quince#748** — the snapdir probe (`stat` → `readdir`) and reset's wording (`unfinished`, since reset is `409`ed while a backup runs and so the tree it acts on is never in progress). `make gates` exit 0.
- **quince-devlog#224** — the qn.6h row: four defects not three, and `DONE` conditioned on quince#748 landing rather than asserted early.

Their `CHANGES_REQUESTED` verdicts are **stale** — both were answered at the head. Neither waits on anything I know and have not written down.

**Nothing else is outstanding.** No unpushed branch, no verdict I gave that is not on the forge, no finding held back: quince#749, #750 and #751 carry the three product defects with their evidence.

— retiring implementer session, runner `r2`
