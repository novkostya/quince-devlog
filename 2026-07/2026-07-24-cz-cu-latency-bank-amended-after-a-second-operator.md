# 2026-07-24 — (cz) (cu) latency bank AMENDED after a second Operator discussion — the GATE PATCH becomes candidate C and DOMINATES the stand-in scheme; in-process integration assessed and declined…

(cz) **(cu) latency bank AMENDED after a second Operator discussion — the GATE PATCH
becomes candidate C and DOMINATES the stand-in scheme; in-process integration assessed and
declined as a candidate.** The Operator asked whether the dead air is a consequence of running
idevicebackup2 as a subprocess and whether tighter integration is the ideal fix. Diagnosis
sharpened: the cause is BLACK-BOX-ness, not subprocess-ness — idevicebackup2's sequence has
exactly one point where waiting is free (after the `Backup` request = passcode already fired,
before the message loop), and every workaround is a contortion around not controlling that point.
**Candidate C (new): patch a `--gate <path>` pause into idevicebackup2 at that point** — quince
launches immediately (prompt ~1–2 s), seeds in parallel, touches the gate file; deterministic, no
stand-in, clean-snapshot invariant kept, and it RIDES THE FORK qn.7 ALREADY CARRIES (the #1413
receive-timeout patch), while every subprocess-supervision property (crash isolation, kill
matrix, liveness, cancel, transcript parsing) survives untouched. It strictly dominates candidate
A (stand-in + `exch`): the same overlap with none of the lost-race machinery — A demoted to a
historical note, resurfacing only if carrying the patched build becomes untenable. **In-process
(cgo libimobiledevice / Go mobilebackup2) declined as a candidate:** crash isolation lost (the
kill-matrix hardening assumes a disposable external process), protocol correctness becomes ours
(against the ruled "hope idevicebackup2 does its job well" posture), and **go-ios verified NOT to
implement mobilebackup2** — no pure-Go crib exists, we would be first. If ever, it is a
post-freeze epic justified by accumulated soak + qn.7 chaos evidence that subprocess supervision
is a persistent tax, never by (cu) alone. **Live fork if the soak indicts the raw wait: B
(pre-seed — zero external code, costs the clean-snapshot invariant) vs C (gate patch — keeps the
invariant, costs one more patch on an existing fork). Settle THEN, on soak evidence.** Roadmap
Later/parked block restructured accordingly (live candidates first, A demoted, in-process note).
