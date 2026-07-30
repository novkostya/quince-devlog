# 2026-07-24 — (de) qn.6b "transport patience" INSERTED pre-freeze — the LAST pre-freeze insert, with the bar made explicit

(de) **qn.6b "transport patience" INSERTED pre-freeze — the LAST pre-freeze insert,
with the bar made explicit.** Chain: the Operator proposed pulling ALL of qn.7 pre-freeze (two
reasons from the first soak day: a Wi-Fi backup hang — "probably WiFi drop, I don't know" — and
the Backup-now→passcode wait being "really annoying" even WITH the seeding narration); architect
counter-proposed a split (full qn.7 = weeks of chaos-suite/audition/tuning work that delays the
overdue revamp — today alone produced three letters of process-deviation evidence); Operator
ruled the split and named the pre-freeze half **qn.6b** (consistent with the insert convention;
qn.7 keeps its name and stays post-freeze). **Why pre-freeze at all:** the soak's premise is
daily use; a hanging Wi-Fi backup is what makes the Operator quietly stop using the app, killing
the soak and the freeze plan with it. **qn.6b scope (small, coherent):** (1) the patched
libimobiledevice build — 30 s → 15 min receive timeout (upstream #1413), as an IN-TREE PATCH
FILE applied to the pinned upstream tag at image build (no hosted fork); (2) **the gate patch —
candidate C — on the same fork**, which SETTLES the (cx)/(cz) evidence gate (the Operator's
complaint is the raw wait despite the narration = exactly the evidence the gate demanded);
spike-first per (cz), with candidate B (pre-seed) as the in-rung fallback so the rung cannot
stall; (3) liveness thresholds retuned to the 15-min reality — inseparable from (1), else "fails
too fast" becomes "looks hung forever"; both (ct) sides held: no panic on legitimate pauses,
honest eventual dead-link classification; (4) **the 6a-soak hang as the acceptance case** —
Operator to capture the job row/log/wait duration BEFORE a redeploy loses it; whether the
sampler fired decides tuning-vs-bug. **qn.7 keeps:** chaos suite, netmuxd-USB audition,
restart-policy tuning, #2, full #8, #9b, #10-percent, UX copy. **The last-insert rule:** a
pre-freeze insert is justified ONLY by a defect that stops daily use; qn.6b is the fourth insert
((by)/(cg)/(ch)/(de)) and the final one — nothing else on the books meets the bar. Roadmap: qn.6b
block added before M4; qn.7 block amended; the Later/parked seed-latency block flipped to
GATE-MET/SETTLED→C (decision record retained).
