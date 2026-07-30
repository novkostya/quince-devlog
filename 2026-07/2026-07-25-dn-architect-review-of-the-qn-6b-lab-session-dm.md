# 2026-07-25 — (dn) ARCHITECT REVIEW of the qn.6b lab session ((dm)): validated and landed (`5e92a7b`); the (dh) story-9 contingency is formally DISCHARGED — the freeze is unblocked

(dn) **ARCHITECT REVIEW of the qn.6b lab session ((dm)): validated and landed
(`5e92a7b`); the (dh) story-9 contingency is formally DISCHARGED — the freeze is unblocked.**
The session proved everything qn.6b built (candidate C on the real hook with a `SHARED` seed
during the gate hold; the 18-min patience holding `active` through a multi-minute device-side
delta-recompute — the strongest liveness demonstration to date; resume-to-completion
accumulating a committed backup across `-4` attempts) and — the part that earns the "tough
season" — characterized the one thing the patch was NEVER mechanically proven to fix. **The
spec's honest-residual framing is vindicated exactly as written ((dh)):** the `-4` from a
genuine connection drop is not cured by patience (an SSL-layer reset fires regardless of
timeout), and the session went further than the spec asked — root-causing it live to band
roaming at the 2.4/5 GHz boundary and establishing the PROTOCOL FLOOR (no in-flight rescue
exists at any layer; recovery is always resume). **The (dh) contingency ruling — "if story 9
fails, finishing the same defect continues the (de) insert" — is DISCHARGED, not invoked, on
its own premise:** the insert bar is a defect that STOPS DAILY USE, and the session showed the
residual defect no longer does — it is location-conditional (a marginal band-boundary spot),
survival extended ~40× (48 s → 31 min), every failure lands honestly with a one-tap Retry
((dd) UI) that accumulates to completion, and two clean commits happened the same night from a
normal spot. What remains is a HARDENING gap (babysat retries in marginal spots), which is
qn.7's charter by definition — and the soak will measure its real frequency, which is exactly
the evidence qn.7's auto-resume design wants. qn.7's sharpened scope (auto-retry-on-reconnect +
resume, `-4`→`connection_lost`, the passcode-window question, the roam-vs-sleep chaos capture,
network workaround documented as workaround) is ratified as banked in the roadmap. Dashboard
row tidied (two stale "owed" phrases). **The pre-freeze board is CLEAR — the next act is the
CODE FREEZE + PROCESS REVAMP**, with the app soaking on a build whose transport story is now
hardware-proven end to end.
