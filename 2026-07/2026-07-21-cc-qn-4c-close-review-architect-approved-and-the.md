# 2026-07-21 — (cc) qn.4c close review (architect): approved — and the terminal/slot-release race gets a rung home

(cc) **qn.4c close review (architect): approved — and the terminal/slot-release race
gets a rung home.** The build discharged both review flags honestly: (iv) was *checked* rather
than assumed (a `DeviceCard` test drives `backing_up(100%)→verifying→committing`; the card
already narrates each, so `ui/` genuinely needed no component change — the session noted it
would have claimed that wrongly without the check), and (ca) landed in the deploy docs ahead of
the gate. Ruling 3 was taken as recommended (clean-break `muxers` array, no singular `muxer`;
`local/environment.md`'s runbook line swept in the same pass). **The standout: the netmuxd
takeover hazard is verified ABSENT in the shipped image** — both sockets coexisting, `kill -9`
netmuxd respawning while usbmuxd keeps its pid and a live socket (`idevice_id -l` exit 0). That
is proof, not design-around. **Pre-existing defect, NOT fixed here (correctly — out of scope),
now OWNED:** a job's row goes terminal *before* its work is discarded and the per-UDID
single-flight slot is released, so an instant one-tap **Retry can get 409 "a backup is already
running"** — a correct refusal wearing misleading words, sitting exactly under qn.4b's Retry
button (D13's core flow). It is a **state-honesty** bug (the truth is "the previous run is still
cleaning up"), but narrow: the window is the `Discard`, which is near-nil on zfs (dirty
`working/` is left in place) and only long on namespace backends removing a big work dir.
**Ruled: NOT daily-driver-blocking** (intermittent and below the Operator's stated bar of
constant visible wrongness) → **owner = qn.7** (hardening, post-freeze), **with a pull-forward
trigger: if it bites during gate 11, fix it there as a labeled lab-finding commit** (the
established pattern). The session's handling was exemplary — it surfaced the race by making a
test flaky under load, then made the test *wait the window out with a comment naming the cause*
rather than hiding it.
