# 2026-07-24 — (dg) qn.6b SPEC REVIEWED — APPROVED WITH AMENDMENTS; build may start once they are folded in (no re-review needed pre-build)

(dg) **qn.6b SPEC REVIEWED — APPROVED WITH AMENDMENTS; build may start once they are
folded in (no re-review needed pre-build).** Spec at `docs/specs/qn.6b/qn.6b.md` ((df) reserved
for the build entry). The spike's two corrections to the kickoff brief are ACCEPTED and the
looked-up rule vindicated against the architect's own stale figures: Alpine 3.24 ships
libimobiledevice `1.4.0-r0` (pin `LIBIMOBILEDEVICE_REF=1.4.0`), and `configure.ac` requires the
undocumented 4th dep `libtatsu` (≥1.0.3; Alpine has 1.0.5). The spike's `-5 RECEIVE_TIMEOUT`
finding is ENDORSED as the rung's load-bearing fact: idevicebackup2 never exits on pure silence
(the retry is PRINT_VERBOSE(2), suppressed), so quince's sampler is the SOLE authority for a
cleanly-idle dead link — and note the corollary: the UNPATCHED tool also loops `-5` forever (at
30 s intervals), so the 6a-soak hang was likely already this shape; the Operator's capture still
decides tuning-vs-bug exactly as item 4 forks. The 18-min `LivenessTimeout` (= tool's 15 m + 3 m
margin) + `toolReceiveTimeout` mirror constant + the mechanical guard test are approved as
specified. Candidate-C engine sequencing (gate → Info.plist capture/seed/restore → release)
approved; lab-owed device-tolerance leg + candidate-B fallback per (de) confirmed.
**AMENDMENT A (substantive): the 15-min default must not leak into non-backup device ops.**
Patch `0001` raises the DEFAULT receive timeout for every libimobiledevice-backed binary in the
image — and item 1 replaces the apk tools with the patched build, so pairing, enrichment reads,
and the live encryption re-read ((i)-B) all inherit 15-min patience. A wedged lockdown read
during preflight/pairing would then sit 15 minutes where it used to fail in 30 s — a UX
regression hiding inside a reliability rung. Required: an audit story asserting every non-backup
tool invocation runs under a Go-side context bound (≲60 s); any unbounded call found is bounded
IN THIS RUNG (direct consequence of item 1, in scope). CI-provable.
**Amendment B (minor, prose):** item 2 step-3 lists the Info.plist write after the `Backup`
request, but the spec's own line numbers (2242/2243 write < 2261 request) put it BEFORE — which
is *better* for the engine (the seed-wait target appears within ~1 s of launch, not gated on the
user's passcode); make the prose match the lines so the seed-wait timeout rationale is grounded.
**Amendment C (minor, one sentence):** state that a quince-daemon crash mid-gate cannot orphan a
forever-polling tool — the tool is a child in the same container and dies with it (container
lifecycle); the in-tool `quit_flag` covers the supervised-cancel path.
Item 4's capture remains the Operator's (staging is his box); stories 8–10 sequencing as
proposed. Contract stance (NONE) confirmed. Letters: (df) build, (dg) this review.
