# 2026-08-19 — the registry knew which muxer reported each device, and every consumer threw it away

**quince#1232 implements quince#1219 item D: device ops and backups now go to the muxer that
REPORTED the device, instead of one derived from the device's transport label. The fact was
already in the table — `Registry` keys presence by `(source, udid, transport)` and says so in its
own doc comment — and both `socketAddr` implementations discarded the source and re-guessed from
`usb`/`wifi`.**

Kicked off against quince#1226 and redirected by the Operator to quince#1219 within the first
minutes. That redirect was right and the reading behind it is worth keeping: **quince#1226 has no
buildable claim.** It is a `soak-finding` re-filed by the architect after the Operator corrected
its framing — the `bug` label, the *no silent caps* obligation and the troubleshooting obligation
are all explicitly withdrawn in the body. What survives is one sentence, *"this is evidence for
quince#1219"*, and four "Not established" items that every one need the Operator's hardware. A
session that took it at its title would have built nothing, or worse, built something against an
unsupported configuration.

## What the defect actually is

Routing by transport is correct only for one topology: one daemon per kind of connection. quince
was written against that topology and has never run any other, so nothing was observably broken.
It is wrong for two shapes the project already documents:

- **the hardened shape**, where one muxer serves both transports — `qn.6p` D4 exists precisely
  because pointing both config keys at one daemon is how an operator says that;
- **two muxers both serving USB**, which is legitimate and was misrouted outright.

The second is what quince#1219's list makes ordinary. So this is not a fix for a bug anybody has
hit; it is the correctness the `muxers:` list needs underneath it, which is why the ruling says it
lands **first and alone**.

## The latent path, closed by construction rather than by luck

quince#897 item 4 recorded that with no endpoint configured for a transport, `socketAddr` returned
`""` — and libusbmuxd only NULL-checks the variable:

```c
char *usbmuxd_socket_addr = getenv("USBMUXD_SOCKET_ADDRESS");
if (usbmuxd_socket_addr) { ... }
```

So set-but-empty is **used** rather than falling back to the compiled-in default. It was
unreachable only because an unconfigured transport never carried a device. A resolver that can
answer *"nothing reports this device"* makes refusing it the code's job rather than the topology's,
and the guard sentence the ruling asked to preserve — *"fixing item 4 is exactly what would make it
reachable"* — is now in the code beside the refusal, with tests for both the error and the
zero-endpoint case.

## Where the session stopped, and why

`make gates` exit 0, privacy clean, demo up, PR open. **PR 2 — the `muxers:` list itself (A+B+C) —
is branched locally and not written**, because its surface is the config schema, `validate`,
`CheckMuxerProfile`, `live.go`, `docs/contracts.md`, the README and three compose files, and a
half-built version of that is worse than none. The predecessor tip is recorded in full
(`be3dea6ab5e5b51107022fcac8afd15b9545046e`) so the rebase recipe in `CLAUDE.md` §1 works after
quince#1232 lands and its branch is deleted.

**One assumption is carried into PR 2 and is flagged on it rather than assumed silently.** The
Operator said mid-session *"I'm still the only user of quince so don't care about migration"*, so
`devices:` retires with no compatibility path. It does **not** retire silently: `yaml.Unmarshal`
drops unknown keys without a word — this repo has that incident on record — so a surviving
`devices:` section would take the operator's own `usbmuxd_socket` with it and boot on the default,
with every device vanishing and nothing saying why. A refusal that names the key is a diagnostic,
not a migration, and *no silent caps or fallbacks* is a hard rule rather than a preference.
