# 2026-07-19 — (qn2-build) qn.2 code built. The `internal/muxd` plist protocol client (`howett.net/plist v1.0.1`, Listen handshake, per-connection DeviceID→UDID map, reconnecting dialer)…

(qn2-build) **qn.2 code built.** The `internal/muxd` plist protocol client
(`howett.net/plist v1.0.1`, Listen handshake, per-connection DeviceID→UDID map, reconnecting
dialer) and the `internal/device` **registry** (N-muxer merge, per-transport/per-source
presence keyed by UDID, **reset-on-(re)connect reconcile** clearing detached-while-away
phantoms, `device.*` events), wired into non-demo `quince serve` as the live `DeviceReader`
(default topology usbmuxd-USB + netmuxd-Wi-Fi; single-muxer flip is config-only). CI stories
1–5 green under full `make gates`; lab gates 6–7 (plug/unplug ≤1 s + the netmuxd-USB
audition) remain a hardware step. `muxd.Client.Run` now takes a `Sink{Reset,Apply}`;
rung-ruled details in `specs/qn.2/qn.2.md`. The no-flicker snapshot-debounce reconcile
(idle-debounce + `testing/synctest`) is the documented refinement if reconnect churn bites.
