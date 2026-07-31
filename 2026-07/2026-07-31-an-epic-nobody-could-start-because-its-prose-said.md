# 2026-07-31 — An epic nobody could start, because its prose said "redesign" where the code said "parameter"

**The multi-storage epic sat unnumbered for nine days with an instruction above it telling somebody
to number it, and the spec that finally did — `qn.6c`, quince#381 — found that the single sentence
making the work sound large was measurably wrong.** The epic says *"the `latest/`/`working/`
lifecycle (which qn.5b reworks) becomes per-(device, storage)"*. `core/internal/storage/layout.go:30`
says:

```go
func deviceDir(backupsRoot, udid string) string { return filepath.Join(backupsRoot, udid) }
```

`backupsRoot` is a **pure parameter**, never package state, and every other path function funnels
through that one. `latest/` and `working/` are already per-`(root, device)`. So multi-storage is
*multiple roots* and falls out of root **resolution** — `layout.go` does not change at all. What
changes is that three callers holding a single `backups string` field become a set with a lookup in
front.

**The epic sentence reads as a redesign of the thing `qn.5b` had just spent a rung unifying.** That
is the most expensive kind of wrong a roadmap can be, because it is not falsifiable by reading the
roadmap — only by opening the code, which is the step the sentence discourages. quince#378 caught
it (*"recorded because it was overstated first"*) and the spec carries the measurement; the
`roadmap.md` entry now carries it too, so the correction sits where the discouraging sentence is
rather than only in the rung that escaped it.

**A rung nobody starts because it sounds like a redesign is a rung that does not get built**, and
nine days is the evidence. *"Scope this epic into rungs after the freeze"* had been sitting above
the epic since 2026-07-22 as an instruction with no owner. It was citable and not workable, which
is why quince#378 had to open by observing that no rung numbers existed before it could scope one.

---

**The second measurement went the other way, and it is the one that mattered more.** quince#378
asked a genuinely open question: can `quince-storage.json` be added to today's `/backups` without
perturbing committed versions? The answer on the read paths is **yes, by measurement** — the storage
root is enumerated in exactly two places and both skip non-directories (`scanJournals`
`journal.go:96-98`; `reconcileUDIDs` `reconcile.go:156-161`, double-guarded by `IsDir()` *and*
`validUDID`), `Scan` starts a level deeper, and `Verify` has no notion of a foreign entry at all —
no allowlist, no rejection of unknown names.

**Four clean answers, and then the fifth path nobody had asked about.** `AnchoredFilterRules`
(`offsite.go:16-21`) returns exactly two rules:

```
- /<subdir>/*/working/**
- /<subdir>/*/versions/**
```

Neither matches a root-level file. **The identity marker would have been synced offsite** — and a
replica would then carry its source's UUID, with two places asserting one identity. That is
precisely the question the marker exists to answer, so shipping it would have broken the feature at
the exact point it was introduced to fix.

**The question was well-posed and its scope was one path too narrow.** *"Does this perturb committed
versions?"* is a question about the read walks, and every read walk answered cleanly. Offsite is not
a read walk; it is a **write** to somewhere else, and it was the only path where the answer was no.
Being asked a precise question is not the same as being asked the whole question, and the four
reassuring answers arrived first — which is the order that makes a fifth check feel unnecessary.

---

**What the rung is NOT allowed to decide, and why that is four blocks rather than a paragraph.**
`qn.6c` touches contracts §1, §2 and §6 and design §5 — all frozen. Per the gap protocol the
proposals are **committed into canon in the `PROPOSED` state** and tracked as open questions 2–5 in
the dashboard (quince-devlog#174); no code opens until they are ruled. Each carries options and a
recommendation, and the spec says in its own text that **a recommendation is not a decision.**

The sharpest of the four is the one quince#378 raised without answering: *where does a
config-declared storage get probed?* The epic wants the backend selected at creation and immutable,
**and** checked before each backup — but a storage arriving from `config.yml` has no creation event,
so *immutable after creation* and *probed at startup* disagree about a dataset remounted as
something else.

**They only disagree while "creation" means a UI event.** Define it from the storage's own contents
and the contradiction dissolves: *the first startup that finds a reachable path with no
`quince-storage.json` at its root IS that storage's creation moment.* Probe then, write the marker,
never probe for selection again; every later check **reads and compares**. That yields all three of
the epic's requirements at once, with no creation UI — which `qn.6c` had already ruled out of scope
because add-a-storage is a spike before a spec.

---

**One thing declared rather than discovered.** The program doc forbids a spec whose acceptance gates
depend on a future rung's deliverable, and a multi-storage rung's gate wants two storages. It is not
blocked: **two directories on one filesystem are two storages.** No second disk, provable at rung
close. The hardware leg that genuinely cannot be faked — a real second full transfer of tens of
gigabytes — is declared **owed, Operator, a lab day**, and no PR in the rung claims it until it has
run.
