# 2026-07-20 — (ar) qn.2 cleanup package: muxer gap ruled, qn.2b inserted, qn.5↔qn.4 swapped, worktree-init fixed

(ar) **qn.2 cleanup package: muxer gap ruled, qn.2b inserted, qn.5↔qn.4
swapped, worktree-init fixed** (Architect adjudication + Operator rulings). (1) Open
question 2 RULED as option (a): quince supervises the in-container muxer — Go subprocess
in its own process group under the serve context, restart-on-crash with capped backoff,
killed on shutdown, **refuse-loudly if the socket is already served** (no silent
adoption) — behind `devices.manage_muxer` (true = simple profile; false =
hardened/external, making the staging socket-bind topology a supported mode), plus
`POST /api/devices/rescan → 202|409` + UI Rescan reusing the reset/replay reconcile.
Contracts §1/§6 and design §2 updated (the architect landed the contract-change ahead of
the rung, per program rule). (2) **New rung `qn.2b`** (M1, before qn.3): MINIMAL
supervision scope + rescan + **ownership of qn.2's deferred lab gates 6–7** (plug/unplug
≤1 s + the netmuxd-USB audition) — one physical-presence session; FULL muxer work stays
qn.6/qn.7. Deferred-without-owner is how gates evaporate; qn.3's "fresh container via UI
only" gate also depends on this. (3) **New hard rule: "a rung's goal is provable at rung
close"** (program doc) — the Operator-requested self-containment audit of qn.3–qn.12
found exactly one more violation: qn.4's `succeeded` needs qn.5's `Commit()` → **order
swapped, qn.5 before qn.4** (qn.5 proven on fixture trees + a manually-produced
`idevicebackup2` tree; qn.4 closes M3 with the true e2e gate); rung numbers stay
(labels, not order — qn.7-before-qn.6 precedent). (4) **Worktree init**: worktrees
materialize only tracked files, so sessions there lacked the private `local/` layer —
mandatory first step now documented: `ln -s ../../../local local` (symlink sits on the
gitignored path, uncommittable; privacy-check + environment.md pointers work unchanged).
Also noted: qn.2's out-of-scope moment was handled correctly by the gap protocol (code
scope held; design captured as PROPOSED, not built) — the process worked. Frontier →
**qn.2b** (spec to be written by its session from the roadmap outline + the qn.2 spec
appendix).
