# 2026-07-20 — (au) qn.2b BUILT (CI) — the in-container muxer has a lifecycle

(au) **qn.2b BUILT (CI) — the in-container muxer has a lifecycle.** Cleared the
new pre-build spec-review gate ((as)): spec + Rule check → **architect APPROVED with four
amendments** (all folded in). Shipped: `internal/muxsup` supervisor (`exec.Command` usbmuxd
`-f -S <socket>` in its own process group, restart-w/-backoff 500 ms→×2→30 s, SIGTERM→grace→
SIGKILL on shutdown, **refuse-loudly** probe on an already-served socket, **crash-loop →
`/api/health` degraded** with the last exit reason); `POST /api/devices/rescan → 202|409`
reusing the muxd reconnect→`Reset()`→replay reconcile (no new device-table code), incl.
rescan-as-recovery from degraded (takeover once the socket frees); the `devices.manage_muxer`
config key (default true, first in `DevicesConfig`); `/api/health` `muxer:{managed,state,
detail}`; and a UI **Rescan** control (202 in-progress / 409-explains, never a dead button).
Wiring: managed → supervisor; external/`--demo` → `UnmanagedMuxer` (409). `make gates` +
`make image` + `make gates-ui-e2e` green; **supervisor additionally smoke-tested against the
REAL usbmuxd in the built image** — `/api/health` → `muxer:{managed:true,state:"running"}`,
`usbmuxd v1.1.1_git20250201 starting up`. **Amendment 1 (verify interface facts, not just
versions) paid off:** `usbmuxd --help` showed the daemon owns `-S/--socket` — so
`devices.usbmuxd_socket` is authoritative via the daemon's flag, NOT the client-side
`USBMUXD_SOCKET_ADDRESS` env the draft guessed. **Handoff review of qn.2** (four dimensions,
(at)): gates green; `internal/device` 97.2%, but `internal/muxd` was **44%** — the entire
`Client.Run` reconnect/backoff/dial loop and the `readPlist`/`listen` guards were untested,
exactly the seam qn.2b's rescan consumes. Landed as a `qn.2 review fix` (`muxd/client_test.go`,
real-socket reconnect-reconcile over unix+tcp + codec-guard cases) → muxd **85.7%**. **Coverage
declaration ((at)):** `muxsup` 82.7%, `httpapi` 70.6%; known-untested = the SIGTERM-grace→SIGKILL
escalation branch, the 30 s backoff-cap arithmetic, and the dial-timeout / ctx-cancel-mid-dial
paths (timing plumbing, low-risk). **Lab gates 7–8 (plug/unplug ≤ 1 s, netmuxd-USB audition)
remain the hardware session**, owned by this rung. `.gitignore` `local`-symlink hole surfaced
via the qn.2b Rule check and landed on `main` (`a057783`) — rebased in. Frontier → **qn.3**
(inherits "enrich muxd devices with lockdown identity").
