# 2026-07-20 — (aw) qn.2b CLOSED; netmuxd-USB audition re-homed to qn.7

(aw) **qn.2b CLOSED; netmuxd-USB audition re-homed to qn.7** (Operator ruling). Lab
gate 7 (managed in-container usbmuxd brings USB up via `compose up` + UI **Rescan** re-detects a
re-plugged device) **PASSED on hardware** (Operator-confirmed on staging, after the (av) deploy
fix). Lab gate 8 (the netmuxd-USB audition on v0.4.3) is **moved to qn.7** — it answers a
netmuxd-viability question that pairs with qn.7's netmuxd co-supervision, qn.2b's goal doesn't
depend on it (default topology stays usbmuxd-for-USB; the single-muxer flip is config-only either
way), and it's the risky one (`idevicepair unpair` destroys the pairing record). **Re-assignment
with a named owner, NOT a silent defer** — the audition procedure is preserved verbatim in the
qn.2b spec (gate 8) for the qn.7 session to inherit, and the qn.7 roadmap row now lists it, so the
no-orphan-gate rule qn.2b was created to enforce stays intact. qn.2b's goal (managed usbmuxd
supervision + rescan) is proven end-to-end (CI + hardware); the rung closes. Frontier → **qn.3**.
