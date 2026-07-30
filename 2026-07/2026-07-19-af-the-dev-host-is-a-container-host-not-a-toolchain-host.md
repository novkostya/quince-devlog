# 2026-07-19 — (af) the dev host is a container host, not a toolchain host

(af) **the dev host is a container host, not a toolchain host** (Operator
ruling, superseding the apk-toolchain part of (ae)): no language toolchains install
on any host, ever — every gate target runs inside a pinned toolchain container
(nerdctl/docker autodetect in the Makefile), using the same base images as the
production Dockerfile stages; `versions.env` pins image references in exactly one
place; named cache volumes keep it fast; Playwright runs in its official image
(musl question mooted); CI runs the identical containerized `make gates`.
Contributor requirement collapses to `make` + a container runtime.
