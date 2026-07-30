# 2026-07-19 — (ac) dev environment ruled

(ac) **dev environment ruled** (Operator, after the first qn.0 session
correctly stopped at the undocumented gap): the driving workstation is a thin client —
no toolchains or container runtime on it, ever; all gates/builds/pushes run in a
dedicated `quince-dev` LXC on the Operator's local PVE host (same LAN as the
test iPhone and the LAN registry); the remote big-iron host is NOT in the dev loop —
heavy repeatable CI is GitHub Actions. Concrete hosts/addresses/sizing live in
`local/environment.md` (gitignored Operator-local layer, created this day). Program
doc gained "Where work runs"; qn.0 gained story 0.
