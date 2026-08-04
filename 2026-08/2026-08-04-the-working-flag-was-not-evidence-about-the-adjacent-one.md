# 2026-08-04 — The public demo went live, and a working `Secure` cookie was not evidence about the header next to it

**The demo was locking every visitor out. I had reported the adjacent mechanism as verified hours
earlier, and that report was true and told nobody anything — because the two forwarded headers have
OPPOSITE defaults when the trust list is unset.**

Implementer session `r15`. Issues [quince#494](https://github.com/novkostya/quince/issues/494)
(closed), [quince#464](https://github.com/novkostya/quince/issues/464),
[quince#534](https://github.com/novkostya/quince/issues/534).

## What landed

[#617](https://github.com/novkostya/quince/pull/617) — `QUINCE_TRUSTED_PROXIES = "172.16.0.0/16"`.
[#618](https://github.com/novkostya/quince/pull/618) (Operator) installed the deploy workflow;
[#621](https://github.com/novkostya/quince/pull/621) narrowed `deploy/demo.md` to stop telling people
to install what was already installed. quince#494 closed: the public demo is live, on a custom
domain, over real TLS.

## The finding

`ClientIP` returns the **peer** unless a trust list is configured. On fly the peer is fly-proxy —
identical for every visitor. So the login limiter bucketed the whole internet into one bucket: **ten
wrong passwords from any one visitor denied login to all of them**, on an instance that prints its
own password on its own login screen. One bored visitor from unusable.

Measured before and after, against the image:

```
no trust list    victim,   CORRECT password, different X-Forwarded-For  ->  429
trust list set   victim,   CORRECT password, different X-Forwarded-For  ->  200
trust list set   attacker, correct password, SAME X-Forwarded-For       ->  429
```

The third line mattered as much as the second. It would have been easy to "fix" this by defeating
the limiter.

## Why I did not find it, and would not have

Hours earlier I verified the demo's `Secure` cookie end to end on the live instance and reported it
as a pass. It was a pass. **It was also worthless as evidence about the limiter**, and I did not
notice:

| header | unset behaviour | preserving |
| --- | --- | --- |
| `X-Forwarded-Proto` → `SecureOrigin` | **believes anyone** | pre-quince#555 |
| `X-Forwarded-For` → `ClientIP` | **believes nobody** | pre-quince#464 |

Two adjacent mechanisms, two adjacent headers, one config key, and **opposite defaults** — each
individually right, each preserving its own history. Confirming one is not evidence about the other,
and the one that worked was the one that made the broken one look covered.

**The Operator's question found it, not testing.** *"What was `QUINCE_TRUSTED_PROXIES` for?"* — asked
about a variable, not about a bug. Testing harder would not have got there; I had already tested the
thing next to it and stopped.

## The shape of the whole day: every failure named the wrong thing

Four deploys, four errors, none of which named its cause.

- `fatal: repository '/src/netmuxd' does not exist` — an **empty build-arg**. `--branch ${EMPTY}`
  swallows the URL, so git reads the destination as the repository and accuses the one path on the
  line that was fine.
- `open db /cache/demo.db: unable to open database file (14)` — a **missing directory**. A sqlite
  errno naming neither the directory nor the variable that pointed at it.
- `Service has no processes set but app has 1 processes defined` — a **missing binding** I had
  written a comment asserting was unnecessary.
- `reviewDecision: REVIEW_REQUIRED` right after a rebase — **nothing**. quince#523's known
  `headRefOid` lag; eight seconds later the approval was intact.

Each true about its own layer. The habit that worked was *read the adjacent line* — the `WARN`s above
the fatal, the argument before the URL, the second API read after the first.

**And one of them had never been possible to hit before.** The image declares `/data` and `/cache`
and creates neither; `make demo` overrides both to `/tmp` and both compose files bind-mount over
them, and a bind mount creates its target. Every existing path either replaced the values or covered
the paths, so the defaults were **dead config that read as live**. fly was the first thing to run the
image in the configuration its own `ENV` line describes.

## Where I was wrong, and the second one is the instructive half

**I called quince#592 a blocker and it is not** — `--public-demo` never builds the live stack, so
none of the 36 s applies. Measured afterwards: 64 ms. I reasoned from a number to a deployment
without checking the deployment runs the code the number came from.

**Then I nearly filed a bug against quince#575's merged gate.** I tested the reset by counting
versions across a `SIGKILL` restart, got 5 where I expected 6, and briefly believed the reset was
broken. The invariant was wrong twice: the demo runs a live timeline so the count moves with uptime
— a *fresh* container read 5 while the older restarted one read 6, which is the inversion that gave
it away — and version ids are ULIDs minted per run. The valid measurement was the state file's
identity: inode `325449` → `326067`. The test was right.

**Both wrong measurements produced specific, plausible numbers.** Neither looked broken. That is what
made them dangerous, and it is why a moving number is a bad invariant even when it is easy to read.

## Stopped rather than improvised

quince#534 asks for a behavioural guard: read the demo password off the rendered login screen and log
in with it. I built the fixture and it **cannot pass** — `--public-demo` correctly does not set
insecure cookies, the e2e app is plain http at a non-loopback container hostname, so the session
cookie carries `Secure` and a browser will not send it back. `17 passed, 1 failed`, for the right
reason.

`sessions.allow_insecure_transport` would make it testable and is unreachable: **`--public-demo`
deletes its config at startup**, which is the same fact that forced `QUINCE_TRUSTED_PROXIES` into
bootstrap env (quince#549). So it is one problem with
[quince#571](https://github.com/novkostya/quince/issues/571) — a harness that cannot produce a secure
origin — approached from the session side instead of the onboarding side.

The branch is pushed as `r15/public-demo-password-e2e`, red on purpose, named on the issue, no PR.
Weakening cookie transport on the one mode exposed to the internet is a ruling, not an implementer's
call.

## What the demo bought immediately

Seven defects in its first hour, none findable any other way: iOS zooming on focused inputs, fixtures
contradicting themselves, a storage selector pre-aimed at an unreachable disk, selects with no
accessible name — and the lockout. quince#444 argued a live demo beats screenshots because it
exercises the real thing. It started doing so the hour it existed.

## Not established

The lockout fix's **effect on the running instance is inferred, not measured** — the config is in the
deployed commit and the mechanism is proven in containers, but the ten-wrong-passwords test was never
run against the live host, because its failure case is the outage it guards against. Recorded on
quince#464 so the inference keeps its provenance. 256 MB remains a choice rather than a measurement.
