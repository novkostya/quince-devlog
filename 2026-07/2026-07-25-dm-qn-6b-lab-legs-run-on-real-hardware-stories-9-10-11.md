# 2026-07-25 — (dm) qn.6b LAB LEGS RUN on real hardware — stories 9/10/11 validated; candidate C + liveness patience + kept-dirty-working RESUME-TO-COMPLETION all PROVEN; the bad-link `-4`…

(dm) **qn.6b LAB LEGS RUN on real hardware — stories 9/10/11 validated; candidate C +
liveness patience + kept-dirty-working RESUME-TO-COMPLETION all PROVEN; the bad-link `-4` resilience
characterized live and routed to qn.7. qn.6b's lab debt is CLEARED.** Session on staging (zfs HOOK
mode, the lab iPhone over Wi-Fi/netmuxd), redeployed to the qn.6b image; two full committed backups
produced. **Story 11 (candidate C / gate) PASS:** the on-device passcode fired in ~1–2 s (Operator-
confirmed), the seed ran DURING the gate hold (`hook-reflink`, verdict `SHARED`, zero-space), and the
device tolerated the ~20 s gate hold on the real hook backend — the zfs-hook candidate-C path (only
proven-by-equivalence in CI, its input to the hook being identical to the landed non-gated seed) works
for real. **Story 10 (15-min patience) PASS, twice:** (a) a near-AP backup rode out an app_limited
pause → committed; (b) the winning resume rode through a MULTI-MINUTE DEVICE-SIDE pause — the tool
blocked with zero transfer while the device recomputed the delta of a 61 % partial against the
~133 k-file base (netmuxd heartbeats stayed healthy → device alive, just busy) — and quince held
`active`, NO false kill, then it resumed. Strongest liveness demonstration yet: a 30 s tool timeout
(pre-patch) during that device-side pause is exactly what would have tripped a spurious `-4`.
**Story 9 (the bad-link `-4`) — the HONEST BOUNDARY, characterized:** in a marginal bedroom spot the
backup `-4`'d repeatedly with WILD variance (48 s/0 %, 31 min/61 %, 34 s/0 %) — the variance itself is
the tell (an unstable link, not a deterministic bug; (ct)'s "failure timing varied" again). The patched
receive timeout does NOT cure a `-4` from a genuine connection drop (a `-4` is an SSL-layer error that
fires immediately on the reset, independent of the timeout) — BUT it dramatically extended survival
(48 s → 31 min) AND the kept-dirty-working RESUME accumulated progress ACROSS attempts to a complete,
committed 13-min backup once the phone was stationary. **Resume-to-completion proven end-to-end** (fail
→ resume → 61 % → resume → success), dataset clean (`latest/` only) after. **Root cause diagnosed live
(Operator + implementer): band roaming.** The bedroom sits at the 2.4/5 GHz range boundary, so band-
steering FLAPS the phone between bands (confirmed BOTH directions via the router's client list — band +
a ~2-min reconnect age coinciding with each failure); each flap resets the mux TLS connection → `-4`.
Corroborated by netmuxd reconnect bursts at each failure and `Heartbeat(SleepyTime→Timeout)`. Phone-
sleep (`SleepyTime`, the nightstand doze) is a secondary contributor. **THE PROTOCOL FLOOR (analyzed,
canon for qn.7):** a dropped mobilebackup2 session CANNOT be rescued in-flight at ANY layer — TLS
session state is bound to the dead connection (netmuxd re-announces but a fresh mux channel can't carry
the old TLS session; TLS has no mid-stream reconnect), and mobilebackup2 has no session-reattach.
Recovery is ALWAYS a new backup request that resumes the on-disk snapshot (kept-dirty-working, no
re-transfer) + an iOS per-backup passcode re-prompt. "Survive a roam in-flight" is off the table for
everyone (us, libimobiledevice, netmuxd); "auto-resume after it" is the only path. **quince behaved
correctly throughout:** honest `-4` messages (never "exit status"), kept-dirty-working with the
last-good version noted, `active` liveness through every legitimate pause (no false kill), clean commit
→ `latest/`-only. **qn.7 items surfaced, now well-characterized:** (1) AUTO-retry on drop/reconnect so
the accumulate-to-completion is automatic, not babysat; (2) `-4`→`connection_lost` reclassification
(#8) so a Wi-Fi drop reads honestly, not as a hard `failed`; (3) the passcode-window question — does a
retry inside iOS's recent-unlock window skip the prompt? (decides seamless-vs-one-tap for auto-retry);
(4) a definitive netmuxd-DEBUG + pcap of roam-vs-signal-vs-sleep as qn.7 chaos input (offered, not
taken tonight); (5) network mitigation (stable band for backups) documented HONESTLY as a workaround,
NOT the primary answer (band-steering is standard; the product must survive it via auto-resume). **NET:
qn.6b delivers on real hardware** — fast passcode (C), pause-tolerance + extended survival (the
timeout), device-pause patience (the retune), and resume-to-completion (kept-dirty-working). The
bad-link `-4` is a well-scoped qn.7 problem, not a qn.6b defect. Lab debt CLEARED; next is the CODE
FREEZE + PROCESS REVAMP, with qn.7 (Wi-Fi hardening) carrying the auto-resume + reclassification work.
