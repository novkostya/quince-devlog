# quince — improvement proposals ledger

> The non-blocking sibling of the gap protocol — rules in
> [`program/quince.program.md`](program/quince.program.md) ("Improvement proposals").
> At most one per rung, filed at rung end, never implemented before an `accepted`
> ruling. Declined entries stay here with their reason — **read them before filing;
> they are the project's accumulated taste.**

Entry format:

```
## P<N> — <short title>            [proposed: qn.X, YYYY-MM-DD] [status: proposed]
Problem:   <one line>
Sketch:    <one line>
Value:     <one line — which of correctness/reliability/security/UX/maintenance, and how much>
Cost:      S | M | L
Ruling:    <filled by Operator: accepted → qn.Y / declined: <why> / parked>
```

---

## P1 — onboarding/health check for broken container USB access   [proposed: qn.2b, 2026-07-20] [status: accepted → qn.6]
Problem:   with `manage_muxer: true` the muxer reports `running` while unable to OPEN any device (frozen container `/dev`, missing cgroup perms) — silent until the user wonders why no device appears; exactly the qn.2b staging bug, subtle and hours to diagnose.
Sketch:    when a USB device is present in `/sys/bus/usb` but usbmuxd logs `LIBUSB_ERROR_NO_DEVICE` / enumerates zero, surface an actionable `/api/health` + onboarding warning ("USB muxer can't open devices — compose needs a LIVE /dev/bus/usb bind + privileged/device_cgroup_rules") linking the deploy docs.
Value:     reliability/UX — turns a silent, copy-the-wrong-`devices:`-line failure into a one-line guided fix at setup; the D12 Plex-bar promise (§9 onboarding "usbmuxd reachable" check) depends on catching exactly this.
Cost:      M — needs usbmuxd enumeration/log parsing + a health/onboarding surface; the onboarding framework (§9) isn't built until qn.6, so it lands naturally there.
Ruling:    accepted → qn.6 (Operator, 2026-07-20; architect-recommended). Lands as a
           story in qn.6's §9 guided onboarding checks: deepen "usbmuxd reachable" to
           "usbmuxd can OPEN devices", with the actionable live-/dev-bind warning in
           both onboarding and /api/health. Roadmap M5 updated.


## P1b — the Wi-Fi twin of P1: netmuxd runs but sees nothing   [proposed: qn.4c, 2026-07-21] [status: recorded beside P1 → qn.6]
Problem:   netmuxd discovers Wi-Fi devices ONLY by mDNS, which does not cross a bridged container network — so a supervised netmuxd reports `running` (it is) while enumerating **zero devices forever**, and Wi-Fi (the primary use case) looks broken with nothing anywhere saying why. Same silent shape as P1, other transport.
Sketch:    when a managed netmuxd has been up past a grace period with zero Wi-Fi devices ever seen — or no mDNS responses at all — surface an actionable `/api/health` + onboarding warning ("Wi-Fi muxer sees no devices — the container needs LAN multicast: `network_mode: host` or macvlan") linking `deploy/compose.nas.yml`.
Value:     reliability/UX — the deployment constraint is real and invisible; without this the user's only symptom is an empty device list, and the fix is one compose line they have no way to guess.
Cost:      M — needs a "has this muxer ever produced a device" signal + the same health/onboarding surface P1 builds; near-zero marginal cost if built WITH P1.
Ruling:    recorded beside P1 by the architect ((ca), 2026-07-21) — lands with P1 in qn.6 rather than as a separate rung. qn.4c supervises netmuxd and reports its state honestly; it does not diagnose the transport (out of scope, and gate 11(b) settles whether the deployed shape needs host networking at all).


## P2 — a corollary for the derived signal: read the thing that carries the answer   [proposed: pr.6, 2026-07-26] [status: proposed]
Problem:   five instances across two nights, by both parties, all one shape — a *derived* signal was read in place of the one carrying the answer. Two shell pipelines read for the wrong command's exit status (recorded on the quince#43 entry, "twice, by both parties"); tonight the architect verified fixture teeth through `tail` and read `tail`'s exit code under a banner about non-zero meaning teeth; an implementer `status | head -2` manufactured a "could not read watch state" error out of SIGPIPE; and a mid-CI read of `mergeStateStatus=BLOCKED` on a PR whose *previous* head was green nearly became the canon claim "CLEAN is never reached". The existing corollaries cover claims that cannot fail and messages that collapse two conditions; none names this one, so it has been rediscovered five times and written up five times as five separate confessions.
Sketch:    one corollary in the program doc — *a signal computed from the answer is not the answer; name which command, which field and which head you read, and prefer the one that cannot be produced by the act of asking.* Its enforcement is prose, deliberately: the three mechanical instances already have mechanical defences (`forge-watch` documents split-never-piped in two places), and what recurs is the reading, not the writing.
Value:     maintenance — this project's corollaries are its accumulated taste, and their value is that a session recognises a shape it has not personally hit. Five instances is well past the threshold where the pattern is cheaper named than rediscovered; quince#65 itself is the same shape one level up (a *justification* read in place of the behaviour it justified).
Cost:      S — one corollary, plus the citations already written on quince#62/#65/#67.
Ruling:    <Operator>
