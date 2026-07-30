# 2026-07-20 — (av) qn.2b lab finding — managed-muxer USB needs a LIVE `/dev/bus/usb`, not `devices:`

(av) **qn.2b lab finding — managed-muxer USB needs a LIVE `/dev/bus/usb`, not
`devices:`** (surfaced testing Rescan on staging with a real iPhone; "Rescan didn't work"). Not a
code defect — the supervisor + rescan behaved correctly. A static `devices:` mapping (runc
`--device`) SNAPSHOTS the device-node list at container start, so a device plugged/re-enumerated
later never appears in the container; usbmuxd restarted by Rescan then hits
`LIBUSB_ERROR_NO_DEVICE` (`/sys` live, `/dev` node missing) — restarting the muxer can't surface
it. Fix (deploy-only): bind `/dev/bus/usb` as a **volume** (live) + grant char-device access
(`device_cgroup_rules: ['c 189:* rmw']` on Docker; `privileged: true` on nerdctl/podman/unpriv-LXC
which lack device-cgroup-rules). Validated in a throwaway then deployed to staging — the
in-container usbmuxd connected to the iPhone. `deploy/compose.nas.yml` corrected; captured in the
qn.2b spec's Lab finding. The lab gate did its job: a real device found a deploy gap CI fakes
can't. Rescan's "re-detect a missed device" value now correctly depends on a live container `/dev`.
