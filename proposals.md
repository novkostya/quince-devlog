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
Source:    [quince-devlog#27](https://github.com/novkostya/quince-devlog/issues/27) — the architect's proposal, raised first by the implementer on [quince#67](https://github.com/novkostya/quince/pull/67). **That issue's table is the enumeration of record**; this entry exists to put the proposal in the ledger, not to restate it.
Problem:   reading a signal *derived from* the answer instead of the one that carries it — five instances on 2026-07-26, by both parties, in both the tooling and the reviewing. `updatedAt` read for "something happened to this PR"; `statusCheckRollup` read for a commit's check state; the exit code of `replay | tail` read for the harness's; `status | head -2` manufacturing an error out of SIGPIPE; `mergeStateStatus` read while a newer head was building. **Not corollary (g).** (g) is a *vacuous* check — one whose positive answer can be produced without the thing being true. These are *displaced*: the check runs, reads something real, and answers a neighbouring question that usually agrees. The remedies differ, which is the architect's argument for minting rather than extending: a vacuous check you make fail is fixed; a displaced check you make fail is still displaced.
Sketch:    see quince-devlog#27 for the proposed wording. Its operational half is the part worth keeping: when a narrowing is justified by *"the other channel carries it"*, that justification is **a claim with a scope**, and the scope goes stale silently — so write down which cases it covers.
Value:     maintenance — corollaries are this project's accumulated taste, and their worth is that a session recognises a shape it has not personally hit. Not a code change and not a gate; both operational remedies are already in force and neither depends on the ruling (check state read by SHA, and landability has its own event).
Cost:      S — one corollary, plus citations already written on quince#62/#65/#67.
Note:      one framing difference between the two records, stated rather than reconciled silently. My first draft of this entry called quince#65 *"the same shape one level up"* and counted two older pipeline cases instead; devlog#27 counts quince#65 as **instance 1, the sharpest**, because that derivation was written down and justified — correct for every case anyone tried, silent about the one nobody did. **The architect's reading is the better one and it is adopted here**, including over their own stated preference for mine: a justification that survives review because its proxy always agreed *is* the pattern, not an analogue of it.
Ruling:    <Operator>

## P3 — a gate is proven RED by mutation, not by deletion   [proposed: quince#838, 2026-08-12] [status: proposed]
Problem:   "I removed the code and the test went red" is the standard proof that a gate is real, and in a TYPED codebase it usually proves nothing: deleting a guard leaves its inputs unread, so `tsc` fails with `TS6133` before the test runs — and keeping them referenced trips `no-constant-condition` in eslint. Both are BUILD failures. A session can record a red run, in good faith, as evidence for a test it never actually exercised. Measured on quince#869, twice, on the two guards in `BackLink`.
Sketch:    say it where the coverage rule already lives (`CLAUDE.md`, "Docs are part of the diff" → coverage) — a gate is measured red by MUTATING the code into the mistake someone would really make, not by deleting it; and record the mutation in the PR. `!==` → `===` and `> 0` → `>= 0` are the two that did the work here.
Value:     correctness of the gates themselves, which is upstream of every other claim this project makes about its own tests. It also gets a second result for free: an inverted comparison kills BOTH directions of a two-sided guard, so it distinguishes a test that notices a guard is absent from one that pins which way it points — the first would be satisfied by a guard that declines in the wrong situations.
Cost:      S — a paragraph in canon. No tooling; this is a habit, and the habit is cheaper than the mutation-testing framework it resembles.
Second:    a second independent instance, on a different file and by two seats within one afternoon — quince#895, 2026-08-13. The implementer hit `TS6133` then `no-constant-condition`, reported it as *"now a pattern rather than an accident"*, and the architect hit `TS6133` on its own first probe of the same file minutes after reading that sentence. So it is a property of the technique, not of a session's care, which is the claim the Sketch rests on.
Gap:       **the Sketch's remedy does not cover the case where the realistic mistake IS a deletion.** On quince#895 the defect was an unconditional clause and the fix was to make it conditional, so *"mutate the code into the mistake someone would really make"* and *"delete the guard"* are the same edit — which orphans the binding and stops the build. `void <symbol>;` is what makes such a probe runnable: it compiles, it lints, and it changes no behaviour. Worth naming in the ruling, because a reader following the Sketch literally has nothing to reach for here.
Read:      the discriminator is already printed and is not the exit code — a compile failure never emits a `Tests N failed | M passed` line. Reading for that line separates a reddened suite from a suite that never ran, completely and with no tooling. Same shape as `privacy-check`'s banner, and the same reason: an exit code is a summary, and a summary is where two different things become one.
Scope:     both instances are TypeScript. Whether the Go ladder collapses the two the same way is unmeasured; the ruling should not assume it either way.
Ruling:    <awaiting Operator>
