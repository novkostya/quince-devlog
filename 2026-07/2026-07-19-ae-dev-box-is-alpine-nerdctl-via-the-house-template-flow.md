# 2026-07-19 — (ae) dev box is Alpine + nerdctl via the house template flow

(ae) **dev box is Alpine + nerdctl via the house template flow** (Operator
overruling the architect's Debian suggestion; the glibc-for-Playwright concern is
solved the Alpine way — containerized Playwright runner, or system chromium; qn.1
verifies and records). Template built by the Operator's template-factory script with
buildkit enabled (the existing template lacks it); the clone is **resized up front**
(cores/RAM/swap/rootfs) because template defaults will OOM/ENOSPC on builds — never
wait for the OOM to size a build box. `TMPDIR` moved off the small tmpfs `/tmp`.
Multi-arch images stay in GitHub Actions; local builds are amd64-only. Full sequence
with exact commands: `local/environment.md`.
