# 2026-07-20 — (bo) `rpool/userdata` DECLASSIFIED (Operator ruling), closing the qn.4a-reported pattern hit

(bo) **`rpool/userdata` DECLASSIFIED (Operator ruling), closing the qn.4a-reported
pattern hit.** The qn.4a build's privacy self-check surfaced that a pattern-list string sat in
committed public files (a contracts §6 config example + two planning-era decisions-log entries)
— missed by the (ad) scrub and invisible to the commit-time gate, which greps staged DIFFS
only. Ruled: the dataset path is acceptable-public (default-pool naming, already implied by the
public offsite-model narrative); the pattern is removed from the private list; docs and history
stand; no incident. Standing lesson kept: the gate cannot see pre-existing lines — a
whole-tree `privacy-scan-all` target remains available as a future hardening if a genuinely
sensitive pattern is ever added. Bare hostnames/IPs/MACs remain firmly private.
