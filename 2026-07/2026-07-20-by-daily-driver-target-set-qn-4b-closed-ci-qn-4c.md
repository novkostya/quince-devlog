# 2026-07-20 — (by) DAILY-DRIVER TARGET set; qn.4b closed (CI); `qn.4c` inserted; netmuxd supervision pulled forward; gate 12c deferred past a planned code freeze

(by) **DAILY-DRIVER TARGET set; qn.4b closed (CI); `qn.4c` inserted; netmuxd
supervision pulled forward; gate 12c deferred past a planned code freeze** (Operator ruling).
The Operator is heading for a **code freeze + process revamp**, but wants a *personally
usable* quince first, defined as: **full backup cycle over BOTH transports + live progress
without a page refresh + the major bugs fixed.** Mapping that to work exposed one unassigned
piece — **netmuxd co-supervision**. It is genuinely required for *usable* (not merely for the
proof): nothing starts netmuxd on `compose up`, so Wi-Fi is silently dead after every restart
and unrecovered on any crash — precisely the qn.2b-for-usbmuxd situation. It is also a modest
lift: `internal/muxsup` is hardware-proven and structurally generic, needing its hardcoded
`usbmuxd -f -S <socket>` + **unix-socket** probe generalized to netmuxd's argv + **TCP** probe.
**Ruled:** (1) **qn.4b CLOSED (CI half landed, complete)** — no session work remains; its
**gate 11 re-homes to qn.4c** with a named owner (the qn.2b-gate-8→qn.7 pattern), which is
*more correct*, not merely convenient: gate 11's Wi-Fi leg then runs on **supervised** netmuxd
— the shape actually deployed — instead of a hand-started one proving a topology nobody runs.
(2) **New rung `qn.4c`** = netmuxd co-supervision (moved out of qn.7) + qn.4a findings
(i)/(iv)/(v) (re-pointed from qn.4b), inheriting gate 11. (3) **Gate 12c DEFERRED past the
freeze** — the destructive hardlink matrix gates a backend the Operator does not run (zfs
deployment); the hardlink tier stays disabled-to-copy and surfaced, which is already the safe
interim ((bn)). (4) qn.7 keeps the patched-timeout build, restart-policy tuning, chaos suite,
liveness thresholds, and the audition — all deferred past the freeze. **No handover session
was needed for qn.4b:** its worktree was verified to hold ZERO uncommitted work and its branch
was identical to `main` — the repo (spec + rung report + dashboard + log) *is* the handover,
which is what the documentation discipline was for. Remaining path to the freeze point:
**one fresh session (qn.4c) + one hardware day.**
