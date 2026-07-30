# 2026-07-26 — pr.5 CODE LANDED — the runner exists, is provisioned, and reports honestly that it is waiting for the one thing no script can do

**pr.5 CODE LANDED — the runner exists, is provisioned, and reports honestly that it
is waiting for the one thing no script can do
([#21](https://github.com/novkostya/quince/pull/21) spec →
[#22](https://github.com/novkostya/quince/pull/22) preflight + service + provisioning →
[#23](https://github.com/novkostya/quince/pull/23) stand it up). The GATES ARE OWED:** G2/G3/G5/G6
all need a live Remote Control session, which needs the Operator's `claude auth login` — measured,
not assumed: a `setup-token`/`CLAUDE_CODE_OAUTH_TOKEN` credential **cannot establish Remote
Control at all** ("requires a full-scope login token"), so the interactive step is the only path
and there is no headless variant to find. **Re-checking R6 against the live docs before speccing
confirmed three facts and corrected three**, one of which would have shipped a runner unable to do
the only thing it exists for: `ANTHROPIC_BASE_URL` pointing anywhere but `api.anthropic.com`
disables Remote Control (so the structural guard needed a third assertion R6 never named); the
token-credential fact above; and a ~10-minute network outage **exits the process**, which makes
supervision a correctness requirement and means a restart registers a **new** session — agreeing
with rung-loop's fresh-session resume *by construction* rather than by reconciliation. **Two more
corrections came from the box rather than the docs:** Alpine ships **OpenRC with no systemd**, so
the spec's "systemd unit" would have been a file nothing on that host could run (`rc-service`
present, `systemctl` absent, `supervise-daemon` available); and Alpine is a supported platform
with a **signed apk repository**, so provisioning verifies the signing key against its published
checksum and refuses on mismatch instead of `curl | bash`, with `USE_BUILTIN_RIPGREP=0` set
because on musl the bundled ripgrep is unused and its absence surfaces later as search silently
returning nothing. **The rung's own defect class recurred twice more, both caught by running:**
`rc-service status` reported `started` while the supervised process crash-looped on *"You must be
logged in"* — true of the supervisor, false of the question anyone is asking — so the service now
overrides `status` (supervisor-up-but-NO-SESSION, exit 1; stopped, exit 3); and then the fix for
that **failed to reach the box it fixed**, because `provision` installs the service from the
launchpad clone, which tracks `main`. A fix on a branch cannot reach a box on `main`, so
`provision` now prints `service installed from <sha> (<branch>)` and warns when the installed file
predates the override. That second one was surfaced by an architect incident worth recording: the
runner was destroyed by testing its own destroy-guard **from `main`, where the guard does not
exist** — a mistake that produced a defect nobody would otherwise have found, because nobody
re-provisions an already-working box. Protocol fix owned by the architect: `/review-pr` must say
*run the head under review*. **Owed:** the ceremony (`claude auth login`, workspace trust, the two
`/config` push toggles), then G2 (session reachable from a phone), G3 (restart registers a new
session — **and count the picker entries before and after**, still unmeasured), G5 (`--force`
destroy, unexercised because the only instance is the real runner), and G6, which closes the rung:
an implementer loop run entirely **from** the runner, which is also the moment identity separation
stops being discipline and becomes the machine. Next: pr.6 (lockout), which now inherits a written
constraint — the root-capable path reaches the runner **only** as a forced-command wrapper, two
command shapes, pool-verified, never a general root key.
