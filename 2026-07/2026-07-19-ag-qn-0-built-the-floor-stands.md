# 2026-07-19 — (ag) qn.0 BUILT — the floor stands

(ag) **qn.0 BUILT — the floor stands.** Provisioned `quince-dev`
on the PVE host per the `local/environment.md` sequence verbatim (Alpine+nerdctl+buildkit
template → clone → sized → `<lan-ip>`); recorded the exact `pct` commands back into that
file. Scaffolded `core/` (Go: `serve`+`version`, `/api/health`, `go:embed` UI, slog,
race-tested), `vault/` (uv `quince-vault` with `selftest` importing
`iphone_backup_decrypt`), `ui/` (Vite+React+TS+Tailwind v4 sidebar shell, vitest), the
containerized `Makefile`, multi-stage `deploy/Dockerfile` (netmuxd built from source),
CI, compose examples, `deploy/dev.md`, transcript-README. **Proven in-container:** full
`make gates` green, `make image` green, and the image's runtime gates
(`version`/`health`/`selftest`/embedded-UI) all pass. Rung-ruled bootstrapping fixes
(in the qn.0 spec + `versions.env`): uv image `-alpine` tag, Tailwind `4.1.18` (4.0.0
crashes), Rust `1.88` (netmuxd needs edition 2024), pnpm `overrides.vite`, mypy
stub-override, vault venv built at its final path against the runtime python.
**`.gitignore` bug caught by testing**: trailing inline comments silently disabled the
private-file rules — rewritten with column-0 comments; private lab logs now verified
`!!` ignored. **Registry push proven**: `make push REGISTRY=<lan-registry>` pushed
`quince:local` to the LAN registry (endpoint in `local/environment.md`) and it pulls
back. Per (ak)'s follow-up the toolchain images were then migrated to a single
Alpine-3.24 line (Go 1.26.5 / Node 22.23.1 / Rust 1.97.1 / golangci-lint v2), re-proven
green; the `usbmuxd` daemon (Alpine 3.24 community) now ships in the runtime — so the
old D2 `PROPOSED` gap is closed, not open. Before any push, one privacy incident
(Operator infra in commit messages + an earlier version of this entry) was scrubbed by a
full `git` history rewrite — the origin of the "Privacy is a commit-time gate" hard
rule. Next frontier: **qn.1** (spec to be written).
