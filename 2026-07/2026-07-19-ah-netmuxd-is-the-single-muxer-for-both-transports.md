# 2026-07-19 — (ah) netmuxd is the single muxer for BOTH transports

(ah) **netmuxd is the single muxer for BOTH transports** (Operator-
identified, README-verified, superseding the two-daemon halves of (ag) and D2's
original wording): netmuxd v0.4+ handles USB natively via `nusb` — "no dependency on
a separate usbmuxd daemon"; the project outgrew its network-only name. Core's muxd
client targets N configured sockets with N=1 default; classic usbmuxd stays in the
image as a config-only fallback because netmuxd's USB path is young (v0.4.3 released
2026-07-14) vs usbmuxd's decades — lab gates in qn.2 (presence + fresh USB pairing)
and qn.4/qn.5 (sustained USB backup) decide whether the fallback is ever needed.
Protocol floor unchanged: fresh-device adoption requires a USB connection regardless
of which daemon serves it.
