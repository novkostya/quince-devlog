# 2026-07-26 — pr.2 LANDED — `devct`, the dev-container toolkit, as six bot-authored PRs across one night

**pr.2 LANDED — `devct`, the dev-container toolkit, as six bot-authored PRs across one
night ([#10](https://github.com/novkostya/quince/pull/10) spec →
[#12](https://github.com/novkostya/quince/pull/12) API core + `doctor` →
[#13](https://github.com/novkostya/quince/pull/13) `bin/gh-bot` →
[#14](https://github.com/novkostya/quince/pull/14) template generator →
[#15](https://github.com/novkostya/quince/pull/15) lifecycle →
[#16](https://github.com/novkostya/quince/pull/16) onboard + the allowlist swap). A stranger with a
Proxmox box now runs `devct onboard`, `devct-template build`, `devct create`, and has a container
that reaches a green gate ladder in ~3 minutes.** The rung's thesis was the spec's token-first
amendment — attempt everything on the scoped token, take root only where the API demonstrably
refuses — and the measured verdict is sharper than either side predicted: **the entire permanent
root surface of the system is one four-command block at `versions.env` cadence.** Create,
provision, convert, destroy and the whole everyday path are scoped-token; G2 was run from a
session holding no root path to the hypervisor at all, so "no root" there is structural rather
than promised, and reproduced independently by the architect (181 s vs 194 s to a green ladder).
**The privilege model, measured rather than recalled:** `SDN.Use` on the bridge; `Datastore.Audit`
*and* `AllocateTemplate` on the **vztmpl** storage (downloading a template and consuming one at
create are different permissions, and neither belongs on the rootfs storage — a zfspool cannot
hold `vztmpl` at all, which invalidated the first grant and the check that blessed it);
conversion needs **no additional privilege**; `Pool.Allocate` remains masked-not-measured and is
labelled as such in the code. **Two things forced root, both discovered by running:** `keyctl` is
`root@pam` by design, so no ACL can ever grant it; and the Alpine appliance ships no sshd, which
**falsifies R3's "the box is born reachable"** — born with a key is not born reachable. `pct exec`
joined the standing root class by Operator ruling (bounded to pool-verified vmids during template
builds), keeping Alpine everywhere for dev/staging parity. A verified no-root alternative was
recorded rather than taken: `termproxy` answers 200 on the scoped token. **Interface facts banked:**
`api_host` must be a name the API certificate carries (`api_addr` binds it via `--resolve`;
an address there fails verification, and `-k` is mechanically banned by the shell gate); Alpine's
`buildkit` ships only the daemon, `buildctl` is its own package; the container-to-template flag
lands asynchronously, so verification polls. **The recurring defect of the rung, worth naming:**
*a claim printed without checking the thing it claims* — a refusal handler that dropped the API's
own message, a `done.` after one command of four ran, a verify that failed on a template it had
just built, an ssh-include write that reported a path it had left empty, and — the sharpest —
`no root was used.` as an unconditional `printf` on runs where root ran four commands. Each fix
turned an assertion into a measurement; the last one now generates G1's evidence itself.
**`make gates-sh` earned its place on its maiden run** (shellcheck + a `curl -k` ban), catching an
`eval`-based config parser and, later, three separate prose-backtick bugs — one of which was
*live*, executing `apk info -L buildkit` on the session host from inside an unquoted heredoc.
**`bin/gh-bot` closed the last escalation class**: `Bash(gh pr *)` was allowlisted yet every
bot-authored `gh` call still prompted, because an allow rule never matches past a leading
`VAR=value` — and each escalation lost its result on the way back, which produced one stale
"still open" claim about work already done. The wrapper opened its own PR as its own proof.
**Owed, each cheap and each needing architect access:** the `--skip-keyctl` measurement (if the
toolchain does not need the flag, half the root block disappears), `Pool.Allocate`'s
revoke-and-retest, registry-credential injection (G4), the stamp-mismatch branch, and a
systematic POSIX-prefix pass over shell helpers (the shared-namespace clobber was fixed where it
bit, not eliminated). Next: pr.4 (the `/report` deploy hook, which retires the `/qa` placeholder),
pr.5 (runner host), pr.6 (lockout).
