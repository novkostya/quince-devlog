# 0000 — What counts as a decision

**Status:** report · **Date:** 2026-07-28 · **Issue:** [devlog#30](https://github.com/novkostya/quince-devlog/issues/30)

This is the first file in `decisions/`, and it is not a decision. It is the inventory that the
Operator's decision on devlog#30 said had to come first:

> **Decision-per-file therefore begins with identifying which decisions exist**, which is
> judgement, not `awk`. Whoever takes this should size that first and say what it found,
> rather than discovering it mid-migration.

So: what was found, and how the calls were made. Nothing has moved yet. `progress.md` is
untouched by this PR.

---

## 1. What was measured

```
$ grep -c '^- 202[0-9]-' progress.md
147
```

| | |
| --- | --- |
| dated entries | **147** (exact) |
| judged pure narrative — a build, a proof, a bug found and fixed | **~24** |
| carrying at least one ruling that constrains future work | **~123** |
| discrete rulings inside them | **≥150** |

The classification pass read the entries in five ranges. Four entries straddle a range
boundary and were seen twice, which is how the per-range counts reconcile to the exact
total: `53 + 33 + 28 + 16 + 21 = 151`, less 4 straddlers, is 147.

**The `147` is mechanical. The `~24` and the `~123` are judgement**, and §4 is where the
judgement is stated so it can be disagreed with.

## 2. The finding, which inverts the question

The issue and the Operator's decision both proceed from a measured `4`:

> lines carrying an explicit decision marker — **4**
> … 4 marker lines and 32 mentions of "decision" across 146 entries.

That number is correct and it measures a *marker string*. The thing itself is at the other
end of the range: **about 123 of the 147 entries carry at least one ruling that binds future
work.** The decisions log is not a sparse log with an indexing problem. It is a log in which
nearly every line is a decision and none of them are marked.

**This inverts what "one file per decision" costs.** Taken at face value it produces a
directory of **150-plus files** — the journal re-sharded, still in git, the bulk problem
intact, merge contention traded for directory sprawl, and no reader better off. That is not
what the Operator's table asks for; it is what the words would produce if applied without
the sizing step the same paragraph demanded.

Three structural facts drive it, and each one is visible in the entries themselves.

**Supersession chains.** One question — how a version tree is cloned — was ruled seven times:
`(m)` → `(bf)` → `(bg)` → `(bh)` → `(bi)` → `(bj)` → `(bk)`, across four days. Six of those
rulings are dead. A file per ruling is six live-looking files stating retired rules, in a
directory whose whole promise is that a file *is* the current answer.

**Most rulings are already in canon, and say so.** The entries announce it in their own
prose: *"Stack D5 amended"*, *"design §4 amended"*, *"`CLAUDE.md` gained a fourth identity
row"*, *"it is now a program-doc rule"*. The ruling did not stay in the journal; the journal
recorded that it left.

**Most of the remainder is rung-local and discharged.** *"Spec approved with amendment A"*,
*"finding #7 → qn.6a"*, *"gate 8 re-homed to qn.7"*. Each bound a rung. Each rung closed.

## 3. The criteria

A ruling earns a `decisions/NNNN-slug.md` file only if **all three** hold.

**(A) Live.** Not superseded by a later ruling; not discharged by the close of the rung or
gate it governed. A retired rule is history, and history's home after this issue is the
`journal` branch (quince-devlog#152; the ruling that chose Discussions was reversed on 2026-07-30).

**(B) Load-bearing.** A session doing *unrelated* work could get it wrong. This is the test
that separates a decision from a preference: if nothing downstream can violate it, writing
it down is filing, not governing.

**(C) Homeless.** Not already stated in canon — `CLAUDE.md`, `docs/quince.stack.md`,
`docs/quince.design.md`, `docs/contracts.md`, `docs/ui.design.md`,
`program/quince.program.md` — nor in `proposals.md` or `roadmap.md`, which are ledgers that
already exist for two of these shapes.

**(C) is the load-bearing criterion and the one to argue with.** Its claim is that **where
canon states a ruling, canon *is* the decision record**, and the journal entry is its
provenance. A `decisions/` file restating `D5` would be a second description of one reality,
maintained by nobody, drifting — which is this project's most-filed defect class, not a
hypothetical: [devlog#54](https://github.com/novkostya/quince-devlog/pull/54) was one
document contradicting another, and the `/kickoff` §6 case was one file asserting both the
pre- and post-fix behaviour of the same gate.

**This reverses the assumption this work started with** — that a canon-homed ruling should
get a file anyway, on the reasoning that a file records the *ruling* while canon records its
*enforcement*. That reasoning is not wrong in the abstract. It is wrong here, because
applying it manufactures roughly a hundred fresh instances of the exact defect the project
keeps filing. Recorded as a reversal, with its date, rather than presented as the plan all
along.

## 4. Applying (C): the canon check, and what it found

(A) and (B) are judgement. **(C) is evidence**, so it was measured rather than asserted:
every surviving candidate ruling was searched for in the canon files above, and recorded as
`STATED` (canon says it, with `file:line`), `PARTIAL` (canon says something weaker or
narrower — with the gap named), or `ABSENT`.

The result is one-sided enough to be the answer to §2:

**61 candidate rulings were checked** — those that survived cuts (A) and (B) in the reading
pass. The split is not close, and it splits by *domain* rather than by age or importance:

| | STATED | PARTIAL | ABSENT | |
| --- | --- | --- | --- | --- |
| **product** — storage, transports, contracts, UI, vault | 26 | 4 | **0** | 30 |
| **process and governance** — seats, gates, the loop, privacy | 20 | 6 | **5** | 31 |
| | 46 | 10 | 5 | 61 |

**Every product ruling tested has a canon home. Five governance rulings have none at all.**

That asymmetry has a cause, and the cause is the answer to what `decisions/` is for.
`docs/quince.stack.md` **is already a decision-record ledger**: `D<N>`, one per choice, each
carrying the alternatives considered and why they lost. Product rulings land there and stop
being homeless. **Process has no counterpart.** A governance ruling has only two possible
destinations today — a one-line rule in `CLAUDE.md` or a paragraph in a skill file — and
neither holds *why*, or *what was rejected*, or *who ruled and when*.

So the shape that fits the evidence:

> **`decisions/NNNN-slug.md` is the missing `D<N>` for process** — the reasoning, the
> alternatives, the attribution. It is the record of a decision. **It is not the enforcement
> of a rule.**

### The clause that keeps this safe, and it came from canon arguing against itself

`.github/CODEOWNERS:78-86` warns that skill files are safe-because-unowned **only** because
canon restates anything load-bearing, and that moving a ruling into an unowned file is the
failure mode. **`decisions/` in this repository is an unowned surface too** — `quince-devlog`
has no `CODEOWNERS`, no required checks, and until 2026-07-27 no `enforce_admins`.

So a live rule that binds behaviour must not have `decisions/NNNN` as its *only* statement,
or this work will have relocated governance from an owned file to an unowned one and called
it tidying. The rule:

- **ABSENT / PARTIAL** → the decision file records the reasoning **and names the canon gap
  as owed**, with an issue. It does not quietly become the enforcement.
- **STATED** → the decision file keeps the reasoning and the alternatives, and **points at canon**
  for the rule — it must stop restating it.

**These are a lifecycle, not a fork, and the first version of this passage got that wrong.** It
listed the two arms as a choice made when a file is created — where the STATED arm is
**unreachable by construction**, since criterion (C) admits only homeless rulings and all 13
survivors are ABSENT or PARTIAL. A clause governing a case that cannot occur, inside the file that
establishes the criteria, is the defect §6 convicts `(bu)` of. Caught in review of
[devlog#67](https://github.com/novkostya/quince-devlog/pull/67).

The arm is reachable **over time**, and that is where it does its work. Every file here names a
canon gap as owed, and closing that gap **is the point of naming it** — at which moment the ruling
becomes STATED and the file must stop restating the rule. Without that transition `decisions/`
becomes a second copy of canon one gap-closure at a time, arriving by exactly the drift these
criteria exist to prevent. So a decision file's relationship to canon is *expected to change*, and
its header records which state it is in.

### 4a. Two live canon contradictions, found by looking

The check was for coverage. It found two places where canon does not agree with itself, and
both are worth more than this exercise:

**The backup password's env channel.** `CLAUDE.md` states passwords reach the tool "over
stdin/pty only — never argv, env, or logs". `docs/quince.design.md:303` and `:87` allow a
third channel: *"via pty prompt or `BACKUP_PASSWORD` env (same-uid exposure, short-lived
process) — argv is forbidden"*. `docs/contracts.md:63` splits the difference: *"the
`BACKUP_PASSWORD` env fallback exists in the CLI but quince does not use it"*. Three canon
files, three positions, on a **secrets** rule.

**The default muxer topology.** `docs/quince.stack.md:82` rules the two-daemon default —
usbmuxd serves USB, netmuxd serves Wi-Fi — until the qn.7 audition passes.
`docs/quince.design.md:40` still carries the superseded framing: *"default: ONE, netmuxd
v0.4+ serving both USB and Wi-Fi … classic usbmuxd is a config-only fallback"*.
`roadmap.md:30` carries the old framing and `roadmap.md:33` carries the new one, three lines
apart.

Both are filed as issues rather than fixed here — this PR is a report and fixing canon inside
it would be exactly the mid-migration discovery the Operator said to avoid. **They are also
the strongest available evidence for criterion (C)**: canon is where these rulings live, and
canon is already the thing that drifts. Adding a fourth copy in `decisions/` would not have
caught either of these. Reading canon did.

## 5. What survives — the decision set

Applying (A) live · (B) load-bearing · (C) homeless leaves **13 decisions**. Five have no
canon statement whatever; eight are stated so partially that the binding part is missing.
Each becomes one `decisions/NNNN-slug.md` in PR2, and each names its canon gap.

### Absent from canon entirely — 5

| # | the ruling | source |
| --- | --- | --- |
| 1 | **The process gate set is FULL** — the next addition must *displace* an existing gate, never append to it. | `(at)` L631 |
| 2 | **Every bare `#N` in a PR title must resolve in the repository the PR is in.** | L3668 |
| 3 | **Do not probe whether the reviewer App can write branch protection** — a successful probe is itself an unreviewed change to how `main` is defended. | L4227 |
| 4 | **A mutation must be verified to have changed the file** before its result is believed; mutation testing is blind to what a suite reads from outside the code under test. | L3200 |
| 5 | **`preflight` runs the privacy gate's own validator and takes its exit code** rather than re-implementing the predicate — two implementations of one predicate is how the two answers diverge. | L3229 |

Number 1 is the sharpest: a rule whose whole purpose is to bound the growth of the process,
in a project that has added gates steadily for ten days, and it is written down nowhere. It
was ruled once, in a journal entry, and has been unenforceable ever since.

### Stated only in part — 8, with the missing half named

| # | the ruling | canon has | canon lacks |
| --- | --- | --- | --- |
| 6 | **A journal entry is annotated, never rewritten** — a log that edits itself breaks the citations resting on it. | that lettered ids are retired *as citations* | the rule itself; the words "annotate"/"never rewritten" appear in no canon file |
| 7 | **A control that can be deleted to disable itself is not a control** — the rationale for the committed pattern floor. | that the floor exists | the principle, that the floor is a *count*, and any consequence of its failing |
| 8 | **Lowering the pattern floor is a reviewed change, approved by somebody who is not the author.** | the generic approver ≠ author rule | any tie to the floor; nothing says the floor may not be lowered by its author |
| 9 | **A skill change governing the reviewer's seat needs the Operator only when it alters what the reviewer may DECIDE**; a factual correction carrying a drift test is the architect's. | that skills are not code-owned *at all* | the distinction — and canon's blunter rule arguably **conflicts** with it |
| 10 | **The architect rules properties, the implementer measures mechanisms** — and the measurement is owed even when the mechanism came from the architect. | the vocabulary, scoped to the watch loop | the durable seat boundary, and the third clause entirely |
| 11 | **`pr.6`'s root path reaches the runner only as a forced-command wrapper, never a general root key.** | the premise, in passing, as setup for the Mac's exemption | the rule as a rule; canon itself says this boundary "is owed a line" |
| 12 | **Repo-naming policy** — `quince-*` for app satellites only; standalone libraries take descriptive `ios-backup-*` names. | the two library names | the policy that produced them |
| 13 | **Network-level mitigation for Wi-Fi roaming is a documented workaround, never the primary answer** — auto-resume is the only path. | the protocol floor (a roam is unrescuable) | the workaround's status; nothing stops a future rung from treating AP tuning as the fix |

### What did NOT survive, and why that is most of it

- **Superseded** — the seven-ruling clone chain, `(ah)`→`(ai)` on muxer topology, `(bf)`→`(bh)` on reflink. Dead rules; history's home is the `journal` branch.
- **Discharged with its rung** — spec approvals, amendments, finding assignments, gate re-homings. They bound a rung that closed.
- **Already in canon and correct** — 46 of the 61 tested. Canon is the record; the journal entry is the provenance, and the `journal` branch is where it now lives.
- **Ledger-shaped** — proposal acceptances belong in `proposals.md`, which exists; roadmap and epic scope belong in `roadmap.md`, which also exists.

## 6. Borderlines, named rather than rounded off

**The canon check tested 61 rulings, not all ~150.** The 61 are those that survived cuts (A)
and (B) during a full read of all 147 entries. So the evidence in §4 is strong about the
candidates and silent about the rest — and *which rulings became candidates* is the judgement
this whole report rests on. Appendix B lists all 61 with their verdicts; a reviewer who thinks
something was filtered out too early can name it and it comes back.

**Where I could be wrong, specifically:**

- **Number 9 conflicts with canon rather than merely missing from it.** `.github/CODEOWNERS`
  rules that *no* skill change is code-owned, which is broader and blunter than the ruling's
  "only when it alters what the reviewer may decide". One of the two is wrong. **I am not
  ruling that** — it is a seat-authority question, and the two candidates are a journal entry
  and a canon file. Flagged for the architect; PR2 will carry it as `PROPOSED (gap)` unless
  ruled sooner.
- **The last-insert rule** — *a pre-freeze insert is justified only by a defect that stops
  daily use* — I judged **discharged**, because the freeze it governed has been entered and
  the rule was written for the run-up to it. If the intent was a standing bar on scope creep,
  it is live, load-bearing and absent, and it becomes number 14.
- **The roll-forward and never-mutate rules are STATED and I did not give them files**, even
  though they are the most load-bearing rules in the product. That is (C) working as designed,
  and it is also the outcome most likely to look wrong at a glance: *the decisions log will not
  contain the project's biggest decisions.* It contains the ones with nowhere else to live.
- **`(bu)`, the letter-collision rule, is dead** — killed by the later ruling that retired
  letters entirely. It reads as a live, careful process rule and it governs nothing. A good
  illustration that (A) is doing real work rather than trimming for tidiness.
- **Two candidates turned out to be canon contradictions rather than gaps**, and became
  [quince#159](https://github.com/novkostya/quince/issues/159) (three canon files, three rules,
  on the backup password's env channel) and
  [quince#160](https://github.com/novkostya/quince/issues/160) (`design.md` citing stack D2
  while stating its inverse). Neither is a decision to record; both are canon to repair.

**One thing I deliberately did not do.** For the five ABSENT rulings, the obvious alternative
is to skip `decisions/` and write them straight into `CLAUDE.md`. That would be simpler, and
it would also leave `decisions/` empty — which is not tidying, it is declining the Operator's
decision by implementing it into nothing. The split in §4 (file records the reasoning, canon
carries the rule) is my attempt to honour both; if it is wrong, it is wrong in a way that is
cheap to correct now and expensive after PR2.

## 7. What this report does not do

- **It does not move anything.** `progress.md` is byte-identical after this PR.
- **It does not rule on `decisions/` numbering, format, or ordering** beyond the
  `NNNN-slug.md` shape the Operator's table fixed. That is PR2.
- **It does not classify all 147 entries individually.** The unit of judgement here is the
  *ruling*, and entries carry between zero and five. Appendix A is the complete, mechanical
  entry index — every entry, its line, its date — and it is exact. The classification laid
  over it is not per-entry and does not claim to be.
- **It does not answer [devlog#58](https://github.com/novkostya/quince-devlog/issues/58)**
  (where a retirement record goes). Deliberately: the Operator's decision left it open.

## 8. How to reject this

The whole sequence rests on §3, which is why it is a PR of its own and lands before anything
moves.

- **If (C) is wrong** and canon-homed rulings should get files anyway, the inventory in
  Appendix A and the canon check in §4 are precisely the input needed. PR2 changes shape;
  the work does not repeat.
- **If (A) is wrong** and superseded rulings should be preserved as files with a `superseded
  by` header, that is a larger set and a different reading of what `decisions/` is for — an
  archive rather than a statement of what currently binds.
- **If the counts are wrong**, §1 shows the command and the arithmetic. An earlier version of
  this pass published `~145 of 147` alongside `~24 narrative`, which cannot both be true;
  it was corrected on the issue before this file existed. The derivation is shown here so
  the next reader can check the addition rather than trust it.

---

## Appendix A — the complete entry index

Every dated entry in `progress.md`, mechanically extracted. This is exact, and it is also
PR3's input: these 147 rows are what migrates.

| # | line | date | opening |
| --- | --- | --- | --- |
| 1 | 222 | 2026-07-18 |  full planning pass (this docs set) from the feasibility lab |
| 2 | 225 | 2026-07-18 | (Operator review): (a) vault seam made explicitly swappable — a future |
| 3 | 233 | 2026-07-18 | (Operator review 2): (e) photos parked at lowest priority — Operator's photo |
| 4 | 240 | 2026-07-18 | (external crosscheck review, `../local/chatgpt-planning-crosscheck-feedback.md`, |
| 5 | 259 | 2026-07-18 | (Operator clarification, second pass): the offsite model is whole-tree |
| 6 | 272 | 2026-07-18 | (Operator Q&A, third pass): (k) PVE propagation — recommended mount is a |
| 7 | 282 | 2026-07-18 | (crosscheck v2 adjudication + Operator's passcode correction): the |
| 8 | 299 | 2026-07-18 | (crosscheck v3 + Operator): (p) Intent model adopted lightweight — |
| 9 | 309 | 2026-07-18 | (Operator concern → process + first gap): (r) the gap protocol — |
| 10 | 322 | 2026-07-18 | (Operator rulings, product/UX round): (t) device-centric IA — one |
| 11 | 334 | 2026-07-18 | (naming, final): (y) the project is named `quince`. Vetted: GitHub |
| 12 | 342 | 2026-07-18 | (post-rename completeness audit, Operator-requested): (z) full doc sweep |
| 13 | 353 | 2026-07-19 |  (aa) repo root = `~/iphone-backup-app` as-is (git init in place, qn.0); |
| 14 | 357 | 2026-07-19 |  (ab) device scope widened in wording (Operator): iPhone AND iPad are |
| 15 | 361 | 2026-07-19 |  (ac) dev environment ruled (Operator, after the first qn.0 session |
| 16 | 369 | 2026-07-19 |  (ad) public/private doc split (Operator-spotted: the dev-env edit was |
| 17 | 376 | 2026-07-19 |  (ae) dev box is Alpine + nerdctl via the house template flow (Operator |
| 18 | 385 | 2026-07-19 |  (af) the dev host is a container host, not a toolchain host (Operator |
| 19 | 393 | 2026-07-19 |  (ag) the qn.0 usbmuxd `PROPOSED` gap is dissolved, not chosen between: |
| 20 | 403 | 2026-07-19 |  (ah) netmuxd is the single muxer for BOTH transports (Operator- |
| 21 | 413 | 2026-07-19 |  (ai) Operator recalled hard evidence against netmuxd-USB — an initial |
| 22 | 422 | 2026-07-19 |  (aj) the (ai) signature corrected against the lab log (Operator found |
| 23 | 430 | 2026-07-19 |  (ak) RETRACTION of the "faulty probe" accusation in (ag)/(ah): the |
| 24 | 440 | 2026-07-19 |  (al) new hard rule: "version pins are looked up, never remembered" |
| 25 | 446 | 2026-07-19 |  (am) the private layer is now version-controlled (Operator concern: |
| 26 | 455 | 2026-07-19 |  (an) privacy incident + new hard rule: early qn.0 commits carried LAN |
| 27 | 462 | 2026-07-19 |  (ao) Go rewrite of the decryption library greenlit as a parallel |
| 28 | 473 | 2026-07-19 |  (ap) improvement-proposal channel added (Operator-proposed, designed |
| 29 | 483 | 2026-07-19 |  (ag) qn.0 BUILT — the floor stands. Provisioned `quince-dev` |
| 30 | 507 | 2026-07-19 |  (ah-qn1) qn.1 BUILT — the app frame stands. Full `make gates` |
| 31 | 532 | 2026-07-19 |  (aq) domain parsing goes to a standalone sibling library — |
| 32 | 556 | 2026-07-19 |  (qn1-review) qn.0/qn.1 post-build review + fixes. A read-only conformance |
| 33 | 571 | 2026-07-19 |  (qn2-build) qn.2 code built. The `internal/muxd` plist protocol client |
| 34 | 581 | 2026-07-20 |  (qn2-close) qn.2 closed; muxer-startup gap surfaced + documented. qn.2's |
| 35 | 593 | 2026-07-20 |  (ar) qn.2 cleanup package: muxer gap ruled, qn.2b inserted, qn.5↔qn.4 |
| 36 | 619 | 2026-07-20 |  (as) plan-time discipline made structural (Operator correction to the |
| 37 | 631 | 2026-07-20 |  (at) coverage made a declared artifact; handoff review gets named |
| 38 | 644 | 2026-07-20 |  (au) qn.2b BUILT (CI) — the in-container muxer has a lifecycle. Cleared the |
| 39 | 671 | 2026-07-20 |  (av) qn.2b lab finding — managed-muxer USB needs a LIVE `/dev/bus/usb`, not |
| 40 | 683 | 2026-07-20 |  (aw) qn.2b CLOSED; netmuxd-USB audition re-homed to qn.7 (Operator ruling). Lab |
| 41 | 694 | 2026-07-20 |  (ax) P1 accepted → qn.6 (first proposal through the channel; Operator ruling, |
| 42 | 699 | 2026-07-20 |  (ay) one project, one dev host (Operator-ruled after an incident: a sibling |
| 43 | 708 | 2026-07-20 |  (az) qn.3 BUILT (CI) — device ops + Devices page. Cleared the pre-build |
| 44 | 740 | 2026-07-20 |  (ba) qn.3 CLOSED — lab gate 8 PASSED on real hardware. Deployed the qn.3 |
| 45 | 763 | 2026-07-20 |  (bb) qn.3 post-landing architect review: clean; docs-drift swept. All three |
| 46 | 772 | 2026-07-20 |  (bc) canon fix found by the qn.5 spec review: structural verification branches |
| 47 | 781 | 2026-07-20 |  (bd) qn.5 BUILT (CI) — the version store stands. Cleared the pre-build |
| 48 | 811 | 2026-07-20 |  (be) qn.4 split into qn.4a / qn.4b (Operator-ruled after a plan-shape review: |
| 49 | 826 | 2026-07-20 |  (bf) gate-12 gap RULED: the zfs mirror probes for MEASURED sharing, not FICLONE |
| 50 | 844 | 2026-07-20 |  (bg) the (bf) no-share verdict is PROVISIONAL — Operator challenged it, and |
| 51 | 864 | 2026-07-20 |  (bh) (bg)'s discriminator RUN by the Operator on the host — CLONING WORKS; |
| 52 | 878 | 2026-07-20 |  (bi) the Operator's layer ladder caught the THIRD layer: unprivileged userns |
| 53 | 898 | 2026-07-20 |  (bj) probe semantics refined (fourth Operator challenge: "how can a |
| 54 | 909 | 2026-07-20 |  (bk) (bj) corrected on the fifth Operator challenge ("hardlink seems |
| 55 | 920 | 2026-07-20 |  (bl) qn.5 folds the mirror-ladder ruling into code + docs. Implemented the |
| 56 | 936 | 2026-07-20 |  (bm) qn.5 CLOSED (CI-proven); lab gate 12's remaining hardware legs RE-HOMED to |
| 57 | 952 | 2026-07-20 |  (bn) gate-12 legs REDISTRIBUTED by affinity (Operator-ruled, amending (bm)'s |
| 58 | 963 | 2026-07-20 |  (bo) `rpool/userdata` DECLASSIFIED (Operator ruling), closing the qn.4a-reported |
| 59 | 972 | 2026-07-20 |  (bt) qn.4a BUILT (CI) — the backup engine drives idevicebackup2 end-to-end. |
| 60 | 1009 | 2026-07-20 |  (bp) qn.4b spec APPROVED; the `auto`-when-absent edge RULED: refuse actionably. |
| 61 | 1023 | 2026-07-20 |  (bq) BUG (Operator-found, assigned to qn.4b): Dashboard DeviceCard "Pair" |
| 62 | 1034 | 2026-07-20 |  (br) qn.4b BUILT (CI) — Wi-Fi first-class + transport policy + job-history UI; M3's |
| 63 | 1075 | 2026-07-20 |  (bs) qn.4a LAB GATE 15 — the engine legs PASSED on real hardware (iPad15,7, iOS 26.5). |
| 64 | 1146 | 2026-07-20 |  (bu) decisions-log letter hygiene (two collisions in one review — a process fix). |
| 65 | 1154 | 2026-07-20 |  (bv) ownership resolved: qn.4a owns the deferred zfs-hook legs — and the plan |
| 66 | 1172 | 2026-07-20 |  (bw) qn.4a zfs half PROVEN on real hardware — the engine drives a committed, |
| 67 | 1201 | 2026-07-20 |  (bx) qn.4a close review (architect): clean + strong — two real bugs given a rung |
| 68 | 1214 | 2026-07-20 |  (by) DAILY-DRIVER TARGET set; qn.4b closed (CI); `qn.4c` inserted; netmuxd |
| 69 | 1238 | 2026-07-20 |  (bz) qn.4c spec APPROVED; three architect rulings + the netmuxd socket hazard. |
| 70 | 1269 | 2026-07-20 |  (ca) mDNS-across-the-container-bridge named as an unproven dependency (qn.4c) — |
| 71 | 1283 | 2026-07-21 |  (cb) qn.4c BUILT (CI) — netmuxd is co-supervised, and the three "it looks broken" |
| 72 | 1330 | 2026-07-21 |  (cc) qn.4c close review (architect): approved — and the terminal/slot-release race |
| 73 | 1352 | 2026-07-21 |  (cd) qn.4c GATE-11 LAB FINDING — the backup target stub must live on the storage |
| 74 | 1382 | 2026-07-22 |  (ce) qn.4c LAB GATE 11 — the DAILY-DRIVER bar is met on real hardware; 6 of 8 legs |
| 75 | 1434 | 2026-07-22 |  (cf) iMazing-opens PASSED — qn.4a's gate 15 is now FULLY hardware-proven. The |
| 76 | 1451 | 2026-07-22 |  (cg) `PROPOSED (gap)`: the `latest` swap is NOT atomic — the D5a offsite promise is |
| 77 | 1499 | 2026-07-22 |  (ch) `qn.6a` inserted before the freeze — soak-ready UI. Sequence: qn.5b → qn.6a → |
| 78 | 1528 | 2026-07-22 |  (ci) gate-11 findings — DURABLE disposition + rung distribution (bookkeeping). |
| 79 | 1547 | 2026-07-22 |  (cj) architect rulings on (ci)'s four PROPOSED rows + #9 (the audit itself: approved, |
| 80 | 1578 | 2026-07-22 |  (ck) #9(a) REFRAMED by an Operator challenge ("does the `incremental` label bring |
| 81 | 1597 | 2026-07-22 |  (cl) Post-freeze EPIC captured: storage as a first-class entity (multi-storage). |
| 82 | 1618 | 2026-07-22 |  (cm) Later idea banked: scoped per-device view + QR/link device enrollment. Full |
| 83 | 1629 | 2026-07-22 |  (cn) Spike banked: enable/disable Wi-Fi discoverability ("Wi-Fi sync") from inside |
| 84 | 1643 | 2026-07-22 |  (co) qn.5b spec APPROVED with amendments — two Operator-caught issues + the seven |
| 85 | 1677 | 2026-07-24 |  (cp) qn.5b BUILT (CI-proven) — atomic `latest` + the `working/` lifecycle redesign |
| 86 | 1714 | 2026-07-24 |  (cq) qn.5b post-build architect review: APPROVED + LANDED on main (`fc45ae7`, |
| 87 | 1733 | 2026-07-24 |  (cr) FINDING (Operator-caught on the staging UI, 2026-07-24): versions whose artifact |
| 88 | 1768 | 2026-07-24 |  (cs) HARDWARE FINDING + FIX (branch `claude/qn5b-seed-timeout-fix`): the 60 s ZFS |
| 89 | 1788 | 2026-07-24 |  (ct) qn.5b HARDWARE-VALIDATED end-to-end on the real pool + real iPhone/iPad over |
| 90 | 1826 | 2026-07-24 |  (cu) DEGRADED UX regression (Operator-caught on hardware): qn.5b made the gap between |
| 91 | 1850 | 2026-07-24 |  (cv) ARCHITECT REVIEW of the qn.5b hardware session: branch approved + landed |
| 92 | 1892 | 2026-07-24 |  (cw) Finding B CLOSED — the qn.5b `seed_in_progress` guard: a seed killed mid-clone |
| 93 | 1908 | 2026-07-24 |  (cx) (cu) ELABORATED with the Operator — the raw-latency mechanisms banked as a |
| 94 | 1932 | 2026-07-24 |  (cy) ARCHITECT REVIEW of the Finding B closeout ((cw), branch |
| 95 | 1947 | 2026-07-24 |  (cz) (cu) latency bank AMENDED after a second Operator discussion — the GATE PATCH |
| 96 | 1970 | 2026-07-24 |  (da) qn.6a BUILT (CI-proven) — soak-ready UI (mobile + offline devices), the LAST rung |
| 97 | 2015 | 2026-07-24 |  (db) ARCHITECT REVIEW of qn.6a ((da)): APPROVED + LANDED (main → `3a7b068`, |
| 98 | 2052 | 2026-07-24 |  (dc) CORRECTION to (db) deviation 1 (Operator clarified): the qn.6a push was NOT |
| 99 | 2069 | 2026-07-24 |  (dd) qn.6a SOAK-POLISH BATCH reviewed + landed (9 commits, main → `ef897eb`) — the |
| 100 | 2098 | 2026-07-24 |  (de) qn.6b "transport patience" INSERTED pre-freeze — the LAST pre-freeze insert, |
| 101 | 2123 | 2026-07-24 |  (dg) qn.6b SPEC REVIEWED — APPROVED WITH AMENDMENTS; build may start once they are |
| 102 | 2154 | 2026-07-24 |  (dh) qn.6b spec DELTA reviewed after a relay-ordering slip — the capture-driven |
| 103 | 2184 | 2026-07-24 |  (df) qn.6b BUILT (CI-proven) — transport patience: patched-from-source |
| 104 | 2239 | 2026-07-24 |  (dj) ARCHITECT REVIEW of qn.6b ((df)): APPROVED + LANDED (rebased onto (dh) main, |
| 105 | 2266 | 2026-07-24 |  (di) e2e story-4 FLAKE fixed under the soak-maintenance lane ((dd)) — a test-only |
| 106 | 2312 | 2026-07-24 |  (dk) ARCHITECT REVIEW of the story-4 flake fix ((di)): APPROVED + LANDED (PR #3 CI |
| 107 | 2326 | 2026-07-24 |  (dl) SPACE SCARE resolved — the reflink accounting trap's SECOND ambush, this time |
| 108 | 2348 | 2026-07-25 |  (dm) qn.6b LAB LEGS RUN on real hardware — stories 9/10/11 validated; candidate C + |
| 109 | 2394 | 2026-07-25 |  (dn) ARCHITECT REVIEW of the qn.6b lab session ((dm)): validated and landed |
| 110 | 2419 | 2026-07-25 |  (do) The 2026-07-24 storage-thread discussion BANKED (the space-scare's productive |
| 111 | 2438 | 2026-07-25 |  pr.3 LANDED — the agent instructions, the six workflow skills, and the layered |
| 112 | 2482 | 2026-07-26 |  pr.2 LANDED — `devct`, the dev-container toolkit, as six bot-authored PRs across one |
| 113 | 2530 | 2026-07-26 |  pr.4 LANDED — `dev-deploy`: a PR now carries a working demo URL and a walked |
| 114 | 2573 | 2026-07-26 |  pr.5 CODE LANDED — the runner exists, is provisioned, and reports honestly that it |
| 115 | 2613 | 2026-07-26 |  The architect gets its own box, and the loop gets its event source — six PRs after |
| 116 | 2653 | 2026-07-26 |  The revamp's session hosts are live, and the ceremony taught three gates the docs |
| 117 | 2671 | 2026-07-26 |  The public docs stopped reading as a lab journal, and no decision left with the |
| 118 | 2697 | 2026-07-26 |  One `internal/backup` flake fixed and landed; the other's category fix was found |
| 119 | 2774 | 2026-07-26 |  The loop's event model was itself the bug — an enumeration is a claim about what can |
| 120 | 2888 | 2026-07-26 |  The CI flake was the product lying about a failed backup, and reproducing it before |
| 121 | 2943 | 2026-07-26 |  The rewritten loop shipped a watch that could not wake anybody, and an arming step a |
| 122 | 2999 | 2026-07-26 |  The loop's sixth blind spot was in a justification, not in code: an approved PR whose |
| 123 | 3062 | 2026-07-27 |  The privacy gate could report a clean sweep it had never performed, and the fix was |
| 124 | 3117 | 2026-07-27 |  G1 had been run by nobody but its author, and the gate that fixed that shipped |
| 125 | 3163 | 2026-07-27 |  A suite written to prove `preflight` refuses things was itself reading the box it ran |
| 126 | 3211 | 2026-07-27 |  A box that cannot run the privacy gate now refuses to start — and getting there took |
| 127 | 3263 | 2026-07-27 |  The private layer became a property of the box, and the control protecting it had to |
| 128 | 3324 | 2026-07-27 |  The one control in this system whose correctness cannot be gated overstated its own |
| 129 | 3358 | 2026-07-27 |  Three documents described one tool's exits; none of them matched it, and they |
| 130 | 3405 | 2026-07-27 |  The channel that carries authority in this project is an issue, and nothing watched |
| 131 | 3463 | 2026-07-27 |  An issue an open PR is *about* needs no declaration — and the tool found the bug in |
| 132 | 3516 | 2026-07-27 |  An empty queue is not a legitimate finish for the reviewer, and the tool that said |
| 133 | 3550 | 2026-07-27 |  A gate named in three skills could not be run in half the forge set, and had been |
| 134 | 3584 | 2026-07-27 |  Two boxes measured the same property of the forge and disagreed by 4×, and one of the |
| 135 | 3623 | 2026-07-27 |  A safety argument was checked in the one direction that could not fail — and it was |
| 136 | 3668 | 2026-07-27 |  A convention became a check, and building the check found an arbitrary-code-execution |
| 137 | 3728 | 2026-07-27 |  The title lint was wired, proven on the trigger that justifies it, and then could not be |
| 138 | 3770 | 2026-07-27 |  The gate that guards public history was proven to MATCH, not merely to compile — and |
| 139 | 3825 | 2026-07-27 |  A `Stop` hook told a session to kill a healthy watcher, and the fix is a fifth |
| 140 | 3875 | 2026-07-27 |  `git -c` does not persist, so no box could ever pull the private layer — and the box |
| 141 | 3921 | 2026-07-27 |  The reviewer stopped being a person — verdicts now render as `quince-review[bot]` — |
| 142 | 3955 | 2026-07-27 |  `preflight` now refuses a private layer that can never fetch — and the check that |
| 143 | 3988 | 2026-07-27 |  "The Operator approves canon" became a file instead of a sentence — and the deadlock |
| 144 | 4037 | 2026-07-27 |  The break-glass host stopped being an unfinished lockout and became a decision — and |
| 145 | 4075 | 2026-07-28 |  Eight filed defects cleared in one overnight unit, and seven of the eight were the |
| 146 | 4187 | 2026-07-27 |  The first canon PR the reviewer authored — and the finding that blocked it was its |
| 147 | 4227 | 2026-07-28 |  A reviewer session's own numbers, which exist nowhere on the forge: nine findings |

---

## Appendix B — the candidate rulings and their canon verdicts

All 61 candidate rulings that survived cuts (A) and (B), with the canon verdict that decides
(C). `STATED` = canon says it, cited. `PARTIAL` = canon says something weaker or narrower,
with the gap named. `ABSENT` = no canon file states it.

**The `file:line` references below are a dated measurement, not durable pointers — they were
accurate on 2026-07-28 and will decay.** `CLAUDE.md` alone moved by +25 lines the same day
(quince#161). They are kept as numbers here, and dropped in favour of quoted anchors in the
decision files, because the two are different artifacts: a decision file makes a *durable* claim
about canon and must survive canon moving, while this appendix records *where the evidence was
found* and is only reproducible if it says where. Read a stale line here as "search near this",
not as a broken citation — every row names the ruling in full, which is what `grep` needs.

### Product — storage, transports, contracts, UI, vault (30)

| ruling | verdict | canon |
| --- | --- | --- |
| Vault seam swappable behind `vault.Vault` + conformance suite | STATED | stack.md:185,189; contracts.md:298 |
| Only quince-created snapshots count; host auto-snapshot tooling not relied on | STATED | stack.md:317 |
| No persistent backup-content index; lazy session-scoped reads | STATED | stack.md:484,490,494 |
| Photos parked lowest; thumbnails spike first if revived | STATED | CLAUDE.md:22; roadmap.md:520 |
| Plex-grade setup, one hand-editable `config.yml`, no secrets | STATED | stack.md:547,553,561 |
| Wi-Fi is the PRIMARY use case | STATED | stack.md:581; CLAUDE.md:17 |
| ASSISTED model: no unattended backups, no auto-retry ladder | STATED | stack.md:579,596 |
| Offsite = whole-tree rclone from `latest/`; one dataset per device; destroy human-only | STATED | stack.md:363,371,217,319 |
| `latest/` is a real directory on every backend, never a symlink | STATED | design.md:216 |
| Roll-forward: recovery never unwinds a verified artifact | STATED | design.md:261 |
| **Backup passwords: stdin/pty only, never env** | **PARTIAL — contradiction** | CLAUDE.md:312 vs design.md:303 vs contracts.md:63 → **quince#159** |
| iPhone + iPad first-class; no iPhone-string-specific code | STATED | design.md:69 |
| Device-centric IA — Devices + Settings only | STATED | ui.design.md:41 |
| Frontend stack: Tailwind v4 + vendored shadcn/Radix + Zustand | STATED | stack.md:466-473 |
| **Default USB topology = usbmuxd until the audition passes** | **STATED, but drifted** | stack.md:82 vs design.md:40 → **quince#160** |
| Go vault rewrite is a sibling project; subprocess boundary kept | STATED | stack.md:197-206 |
| **Repo-naming policy: `quince-*` satellites, `ios-backup-*` libraries** | **PARTIAL** | names stated (roadmap.md:507); policy absent → **decision 12** |
| Domain adapters keyed on detected schema, never a version string | STATED | design.md:344-347 |
| `transport: auto` resolves on presence; absent → 422, no job minted | STATED | design.md:180-185; contracts.md:88 |
| `last_backup` derives from newest committed version; means last success | STATED | contracts.md:173-181 |
| No `full`/`incremental` label on the version card; `kind` stays internal | STATED | contracts.md:238-241 |
| Multi-storage epic: UUID in storage, backend immutable, no unattended queuing | STATED | roadmap.md:649-712 |
| **Enrollment: short-TTL secret, never a bearer token in a URL; restore re-auth'd** | **PARTIAL** | roadmap.md:607-610; restore clause hedged ("likely") |
| **Roam is unrescuable; network mitigation is a workaround, not the answer** | **PARTIAL** | roadmap.md:440-444; workaround status absent → **decision 13** |
| `zfs-native` lifecycle → the epic, never a pre-freeze pivot | STATED | roadmap.md:673,690 |
| Structural verify branches on `Manifest.plist.IsEncrypted` | STATED | design.md:144-155 |
| One project, one dev host; idle boxes stopped, not deleted | STATED | program.md:39-44 |
| Dev host is a container host, not a toolchain host | STATED | program.md:56-61 |
| A rung's goal is provable at rung close | STATED | program.md:212-217 |
| Specs carry a `Rule check`; spec review precedes any code | STATED | program.md:93-99, 12-16 |

### Process and governance — seats, gates, the loop, privacy (31)

| ruling | verdict | canon |
| --- | --- | --- |
| The gap protocol: rung-local decided in-spec, architectural stops for a ruling | STATED | program.md:101-119; CLAUDE.md:321 |
| Version pins and interface facts looked up live, never remembered | STATED | CLAUDE.md:290-294 |
| Proposals: one per rung, rung-end, never pre-built; declined stay with reasons | STATED | proposals.md:5; program.md:125-145 |
| Coverage is a declared artifact; undeclared-untested is a finding | STATED | CLAUDE.md:317-320 |
| Review runs four named dimensions | STATED | program.md:290-298 |
| **The process gate set is FULL — the next addition must displace** | **ABSENT** | nothing → **decision 1** |
| Privacy gate exit codes 0/1/2; a `2` is never a pass | STATED | CLAUDE.md:272-284 |
| **A control that can be deleted to disable itself is not a control** | **PARTIAL** | CLAUDE.md:355-359 names the floor only → **decision 7** |
| **Lowering the pattern floor is reviewed by a non-author** | **PARTIAL** | generic rule only; no tie to the floor → **decision 8** |
| **A journal entry is annotated, never rewritten** | **PARTIAL** | only the retired-letters citation rule → **decision 6** |
| A forge ruling is overridden only on the forge, cited by URL and role | STATED | program.md:151-168 |
| A timestamp says WHEN, never WHO | STATED | program.md:189 (f) |
| A check whose positive answer is produced by asking is not a check | STATED | program.md:190 (g) |
| A message naming a condition nobody checked is a defect | STATED | program.md:171-173,195 |
| Self-caused events are deliberately not suppressed | STATED | loop-protocol.md:81 |
| **Reviewer-seat skill changes: Operator only when the verdict scope moves** | **PARTIAL / conflicts** | CODEOWNERS:76-77 rules broader → **decision 9, flagged** |
| **Architect rules properties, implementer measures mechanisms** | **PARTIAL** | vocabulary exists, scoped to the loop → **decision 10** |
| **Bare `#N` in a PR title must resolve in-repo** | **ABSENT** | nothing → **decision 2** |
| A watch is armed LAST, after a foreground catch-up tick | STATED | loop-protocol.md:67; kickoff:162 |
| One direction of a two-directional property is not a check | STATED | loop-protocol.md:103 |
| An empty queue is not a legitimate finish for the reviewer | STATED | architect:408; loop-protocol.md:264 |
| Devlog sweep: work clone's script, no `--patterns`; read the coverage line | STATED | report:38-57,71-84 |
| Do not reseed a watcher's state file | STATED | loop-protocol.md:25 |
| A successor re-declares the watch set from open issues | STATED | retire:101-103 |
| **Do not probe whether the App can write branch protection** | **ABSENT** | nothing → **decision 3** |
| Lettered ids retired; entries date-anchored, citing PR/issue numbers | STATED | CLAUDE.md:241,249 |
| **`pr.6` root path is a forced-command wrapper, never a general root key** | **PARTIAL** | premise only, as setup for the Mac exemption → **decision 11** |
| Deploy URL in PR text is the convention name; never an address | STATED | CLAUDE.md:104-105 |
| The six-leg Definition of Done | STATED | CLAUDE.md:102-103 |
| **A mutation must be verified to have changed the file** | **ABSENT** | nothing → **decision 4** |
| **`preflight` runs the gate's own validator, not a second predicate** | **ABSENT** | canon says the opposite about reading gates → **decision 5** |
