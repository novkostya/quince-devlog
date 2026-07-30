# 2026-07-20 — (qn2-close) qn.2 closed

(qn2-close) **qn.2 closed; muxer-startup gap surfaced + documented.** qn.2's
deliverables (muxd client + `internal/device` registry + UI; `make gates`/image/e2e green) are
complete; a post-build review + UI polish (empty-state copy, state-driven device card — disabled
`Pair`/`Back up now` reflecting muxd-minimal presence) landed alongside. Its **lab gates 6–7 are
deferred** to a future hardware session (they need a real device AND the muxer-startup gap
resolved). During staging testing an architectural gap was surfaced — **nothing starts the
in-container muxer, breaking D12 for USB** — and captured as **open question 2** (`PROPOSED
(gap)`, for the Architect; not decided/built here). A staging stand was stood up on the PVE host
(CT 113, `quince:staging` from the private registry, HTTPS via the CT-102 Caddy) for manual
testing; its USB path uses a **temporary usbmuxd-in-CT + socket-bind workaround** (hotplug needs
the `/root/redetect.sh` helper), rebuilt onto the house template's `/root/compose.yml` autostart
convention (specifics in `local/environment.md`). Frontier → **qn.3**.
