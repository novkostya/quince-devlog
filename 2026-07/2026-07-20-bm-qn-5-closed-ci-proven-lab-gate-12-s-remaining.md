# 2026-07-20 — (bm) qn.5 CLOSED (CI-proven); lab gate 12's remaining hardware legs RE-HOMED to qn.4a

(bm) **qn.5 CLOSED (CI-proven); lab gate 12's remaining hardware legs RE-HOMED to
qn.4a** (Operator ruling — session cut off after the five-round mirror investigation). Landed on
`main` in four commits: `285c40b` (storage backends + reconciliation) + `9a4511b` (docs (bd)/(be))
+ `7e34034` (mirror ladder + lab harness) + `3ce5bb1` (docs (bf)→(bl)). **Proven at close:** the
whole storage subsystem in CI (11 stories + the reconciliation kill-matrix + the D5a anchored-
filter contract; `make gates`/image/e2e green; coverage storage 78.7% / clonetree 71.4% / store
80.1% / httpapi 71.8%), plus the real-zfs commit + encrypted `Verify` + the reflink/EPERM/EXDEV
facts exercised on hardware during the gate-12 investigation ((bf)→(bk)). **NOT proven on
hardware (re-homed, NOT silently dropped — the qn.2b→qn.7 no-orphan-gate precedent):** the
host-side `mirror` verb on the real rpool, iMazing-opens, syncoid mid-write, and the 12c
destructive hardlink-safety matrix. **Owner = qn.4a**, whose first real-backup hardware session
runs qn.5's storage `Commit` on real traffic (the natural home); the legs are preserved verbatim
in the qn.5 spec's gate-12 section. Interim note: the `hardlink` mirror/backend tier is
matrix-unproven until 12c runs (the Operator's rpool uses the reflink hook path, so it isn't hit
there); the pushed staging image is pre-mirror-ladder and needs a re-push before the qn.4a
hardware session. Frontier → **qn.4a**.
