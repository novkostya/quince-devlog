# 2026-07-26 — pr.4 LANDED — `dev-deploy`: a PR now carries a working demo URL and a walked click list without anyone asking, as three PRs

**pr.4 LANDED — `dev-deploy`: a PR now carries a working demo URL and a walked
click list without anyone asking, as three PRs
([#17](https://github.com/novkostya/quince/pull/17) spec →
[#18](https://github.com/novkostya/quince/pull/18) the `devct deploy` verb →
[#19](https://github.com/novkostya/quince/pull/19) `/report` by default, `/qa` replaced, the DoD
naming both non-URL outcomes).** `devct deploy` fetches a ref onto a disposable dev container,
builds **the production image** there (QA against a different artifact is QA of something nobody
ships), serves it in `--demo` mode replacing any previous deploy, and **polls `/api/health` until
it answers before printing anything**. Measured: **222 s** for a first deploy on a fresh container
(cold image build), **5 s** for a warm re-deploy. **The URL question was ruled before code
existed** — R5 wants the URL in the PR, privacy forbids an address in PR text — and the answer is
the convention name (`http://quince-dev-N:8080/`), which carries no site information and is
satisfied *by construction* rather than by a reviewer catching a leak. **Amended after the first
implementation (Operator):** the address the tool prints leads, because on the LAN it needs no
setup and **`ssh -L` is the one path that does not scale to parallel rungs** — every container has
its own `8080`, so N deploys are N addresses while N tunnels collide on the local port; the tunnel
is the address-free fallback for a reader who has the alias but not the LAN, never a requirement.
**Four defects found by running rather than reading, none of which review would have caught:**
`ssh -n` — the pr.2 fix for "ssh eats a loop's stdin" — applied to the two calls whose stdin *is*
the payload, so the remote shell got nothing, exited 0, and the image build silently never
happened; `localhost` resolving to `::1` past nerdctl's IPv4-only port proxy, which reported a
dead demo that was serving perfectly **and would have broken the ruled `ssh -L` command from the
other side**; Alpine's sshd shipping `AllowTcpForwarding no`, so the ruled click path was **broken
at the daemon on every container** (fixed in the template, and `devct create` retrofits containers
cloned from an older one, saying which it did); and `SC2087` — an unquoted ssh heredoc expands
every `$` client-side, which works by luck until the remote script wants a variable. **The rung's
own signature defect recurred and was promoted to canon:** a container resolver that returned
empty for both "none running" and "several running", so `deploy` printed *no running dev
container* while two were up and offered a fix that would have created a third. That is the sixth
instance across pr.2/pr.4 of **a message naming a condition nobody checked**, and it is now a
program-doc rule with its four earned corollaries and the test that makes it usable — *could this
message print unchanged in a situation where it is untrue?*
([devlog#5](https://github.com/novkostya/quince-devlog/pull/5)). **G3 made the rung prove itself:**
#19 carried a URL produced by the machinery, with every click-list line walked
(`needs_setup` → setup 200 → the demo device with its real model/OS → `POST /api/jobs` 202,
`auto` resolving to `usb` → job `backing_up` at 52%), and stated plainly that the demo behind it
is byte-identical to `main`'s because the PR changes no product code — the URL is evidence about
the *machinery*, not about a change to click. **Owed:** nobody has looked at rendered pixels (every
step went through the API over a tunnel); `--hosts` is unexercised; `deploy: unavailable —
<reason>` has never been emitted by a real `/report` run; and pr.2's four measurements still need
architect access (`--skip-keyctl`, `Pool.Allocate`, registry injection, the stamp-mismatch branch).
Next: pr.5 (runner host — where this loop stops depending on a laptop staying awake), then pr.6
(lockout).
