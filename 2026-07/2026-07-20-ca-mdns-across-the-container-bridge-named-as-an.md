# 2026-07-20 — (ca) mDNS-across-the-container-bridge named as an unproven dependency (qn.4c) — and it is the Wi-Fi twin of accepted proposal P1

(ca) **mDNS-across-the-container-bridge named as an unproven dependency (qn.4c) —
and it is the Wi-Fi twin of accepted proposal P1.** netmuxd discovers Wi-Fi devices ONLY by
mDNS; both shipped compose examples run bridged with a published port, multicast does not
cross that bridge, and **no gate has ever proven Wi-Fi device presence inside the container**.
So supervising netmuxd may be **necessary but not sufficient** on the shipped deployment shape.
The session named it rather than assuming it (host networking as the deploy answer, macvlan as
the alternative) and gate 11(b) settles it on hardware in minutes — the right call. Two
additions: (a) whatever the gate finds, the Wi-Fi networking requirement is a **first-class
deployment constraint** in `deploy/`, not a footnote — and if host networking is the answer,
its security tradeoff (shared network namespace vs. the hardened-profile story) is documented
honestly; (b) "netmuxd running" ≠ "Wi-Fi works" — a netmuxd that runs while multicast never
reaches it sees zero devices forever, which is **exactly the shape of accepted proposal P1**
(a muxer that runs but cannot open devices → actionable onboarding/health warning). The Wi-Fi
twin should land with P1 in qn.6, or at minimum be recorded beside it.
