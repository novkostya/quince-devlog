# 2026-07-19 — (aj) the (ai) signature corrected against the lab log

(aj) **the (ai) signature corrected against the lab log** (Operator found
the exact line, dated 2026-07-13): it's the **64 KiB u16 boundary**, not 64 MiB —
`netmuxd::usb::mux … asyncReadComplete, message was too large (65536 bytes,
max = 65535)` — i.e. netmuxd HAD USB support during the lab and its mux read path
choked one byte over `0xFFFF` on real backup traffic; plausibly a one-line fix.
v0.4.3 shipped the NEXT DAY noting "Fixes iTunes on the Apple mux" — possibly this
bug, unconfirmed; the qn.2 audition (real backup traffic on pinned v0.4.3) decides.
Exact line quoted in stack D2; default topology ruling from (ai) unchanged.
