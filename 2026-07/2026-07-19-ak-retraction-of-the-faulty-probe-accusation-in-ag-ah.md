# 2026-07-19 — (ak) RETRACTION of the "faulty probe" accusation in (ag)/(ah)

(ak) **RETRACTION of the "faulty probe" accusation in (ag)/(ah)**: the
authoritative per-branch APKINDEX check shows `usbmuxd` in **Alpine 3.24 community
ONLY** (absent 3.21–3.23) — the qn.0 session's original finding was CORRECT for its
3.21 base; the architect's all-branches "verification" was the flawed one (apk's
`--repository` appends to configured repos; all four queries were answered by the dev
box's own 3.24 repo). The build session's `ALPINE_VERSION=3.21 → 3.24` bump is
ratified — additionally right because 3.21 (Nov 2024) nears EOL while 3.24 is current
stable and matches the dev/lab CT line. Follow-up (non-blocking): align toolchain
images to 3.24-based tags where published. Lesson upgraded in D2: verify package
claims against the branch APKINDEX or a clean container of that branch.
