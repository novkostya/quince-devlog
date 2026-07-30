# 2026-07-24 — (cv) ARCHITECT REVIEW of the qn.5b hardware session: branch approved + landed (main → `0f9eaff`, ff-only); all four routed findings adjudicated

(cv) **ARCHITECT REVIEW of the qn.5b hardware session: branch approved + landed
(main → `0f9eaff`, ff-only); all four routed findings adjudicated.** Code verified, not just the
report: the (cs) fix's mechanism (a distinct `zfsSeedTimeout` via `seedCtx()`; the metadata verbs
keep 60 s), the regression test's discrimination (it inspects the deadline the hook verb actually
receives and the old code gives *exactly* 60 s), and the hook `chown` reasoning (`cp -a` preserves
ownership; only the mkdir'd parent needs it). (cr)'s mechanism confirmed in code (`wire.Version`
has no `missing` field; `toWire` never maps `store.VersionRow.Missing`), as was Finding B's
(`WorkDir` resumes ANY non-empty `working/<udid>`; `writeWorkState` runs only after the seed).
Privacy sweep clean (no LAN IPs in the diff; the pcap fixtures stay local-only). **Rulings:**
**(1) (cr)(a) → qn.6a, CONFIRMED,** with the contract shape ruled: add `missing: bool` to
`wire.Version` (contracts §2) and render dead versions **explicitly dead, NOT omitted** — no size
claim, no `Unlock`, an "artifact gone — remove?" action on the existing `DELETE`. Omission would
silently shrink history and mask exactly the drift a soak exists to surface; the dead row is also
the user's only record the backup ever existed. **(2) (cr)(b) → banked as constraint #7 on the
multi-storage epic (cl),** not qn.6a, not a near-term patch: no background sweep or
revalidate-on-read until "storage unreachable" and "artifact gone" are distinguishable states —
the implementer's do-not-build-a-sweep-that-cannot-tell-them-apart caution is adopted as a hard
sequencing rule. **(3) (ct) Finding B → a qn.5b CLOSEOUT PATCH (owner: the qn.5b implementer),
CI-provable, no hardware needed — before or alongside qn.6a.** It is a gap in qn.5b's own design
(sentinel timing), and the soak makes mid-seed crashes realistic (restarts, OOM, power). Spec
accepted with three refinements verified against the code: **(a)** the sentinel already lives in
the device dir OUTSIDE `working/<udid>` (survives the hook's `rm -rf` + `cp -a`), so
write-before-seed needs no restructuring; **(b)** the completeness flag must be **legacy-safe**:
an EXISTING sentinel without the new field was written post-seed under the old code and is
therefore COMPLETE — absent-field must read as valid, or the patch would discard a resumable
34 GB `working/` on the soak box's first restart after upgrade (shape it accordingly, e.g.
`seed_in_progress: true` written pre-seed and cleared on success, absent = complete); **(c)** the
guard applies to BOTH models (`zfs.go` and `namespace.go` share the resume-any-non-empty
pattern), and the discard path re-seeds with a log line. CI leg: a partial tree with an
in-progress/absent-complete sentinel must be discarded and re-seeded, never resumed; a dirty
working from a FAILED BACKUP (complete seed, real sentinel) must still resume — the guard has to
discriminate the two. **(4) (cu) → option (1) in qn.6a, CONFIRMED,** with the contract shape
ruled: a `seeding` job phase between `preflight` and `backing_up` (contracts phase-enum
addition); UI narrates "Preparing — cloning from your last backup…". **Options (3) and (2)
DECLINED for now:** (3) trades away the clean-snapshot invariant qn.5b just paid for — revisit
only with soak evidence that the RAW latency, not its visibility, is the complaint; (2) is
transport-adjacent complexity that would belong near qn.7's audition if ever. (4)-faster-seed is
already harvested by (cs). **(5) qn.7 evidence — accepted as banked** (roadmap block reviewed);
the legitimate-idle-pause finding is load-bearing for the liveness-threshold tuning, and the
session's own on-the-record correction of its two live misreads (a pause is not a deadlock) is
the process working as designed. Roadmap updated: qn.6a homings flipped to confirmed with the
ruled contract shapes; epic (cl) gains constraint #7.
