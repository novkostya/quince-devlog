# 2026-07-20 — (bv) ownership resolved: qn.4a owns the deferred zfs-hook legs — and the plan ambiguity that caused the dispute is fixed

(bv) **ownership resolved: qn.4a owns the deferred zfs-hook legs — and the plan
ambiguity that caused the dispute is fixed.** Operator-flagged: qn.4a's session read the zfs work
as "deferred to a later session, not mine," while the architect read gate 15(a) ("commit on the
real zfs backend") as qn.4a-owned. **Both defensible — the plan conflated two things:** gate
15(a) demanded a zfs-backend commit, but the session validly proved the engine on the `hardlink`
backend and bundled everything zfs-specific into a deferred pile that enumerated only the
mirror/iMazing/syncoid extras — never listing **engine→commit-on-zfs** itself, leaving it in a
seam owned by no named rung ("a later dedicated session" ≠ a rung). **Ruling (Operator): qn.4a
owns the whole zfs half** (it already holds the topology details — cheaper than re-teaching a
fresh session); deferred ≠ reassigned, the rung finishes its own gate. **Ambiguity fixed:** the
pending zfs half is now enumerated explicitly — **engine→commit on the real zfs-hook backend**
(the implicit item) + host `mirror` verb + `bclonesaved` live + iMazing + syncoid — in the qn.4a
spec status, the dashboard row, and here. Low risk (both halves independently hardware-proven —
qn.5's lab harness committed a real 34 GB backup through the zfs backend, qn.4a proved the
engine→backend handoff on hardlink; only their composition on zfs is unrun). Blocks nothing;
runs when the Operator stands up the rpool hook topology (likely with qn.4b's gate 11/12c —
one hook-topology setup serves both). Also fixed en route: the qn.4a dashboard row was stale
("Not committed") — reconciled to reflect the landed CI half + the hardware-proven engine legs.
