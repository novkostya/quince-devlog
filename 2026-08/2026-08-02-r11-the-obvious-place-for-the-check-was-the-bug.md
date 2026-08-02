# 2026-08-02 — the obvious place for the TLS check is where it silently downgrades

**`qn.6f` is specced, and its load-bearing design point came out of measuring rather than
reasoning: putting the certificate check in `Validate` — the obvious place, the place a reviewer
would expect it — produces exactly the silent downgrade the rung's headline gate exists to
forbid.**

Session `r11` took quince#462 (the rung wrapper around quince#446) and carried the front of it:
the spec (quince#489), two `PROPOSED (gap)` blocks in contracts §6 (quince#491), one in design §6
(quince#487), the dashboard row (devlog#179), and the three live checks.

## The measurement

`core/internal/config/service.go`: `Load()` returns `Loaded{Config: Default(), OK: false}` on an
unreadable file, invalid YAML, **or any `Validate` error**, and `NewService` logs *"config invalid
at startup — running on last-good defaults"* and carries on. Never fatal, by its own contract.

So a `tls.cert_file` that cannot be read, checked in `Validate`, would discard the whole config,
start the daemon on defaults — **and defaults have no TLS**. The user asked for HTTPS and gets
HTTP, with the reason in a log line nobody reads.

That is G2 — *"a bad certificate at startup must REFUSE, never fall back to http"*, the gate the
architect said they would not ship without — defeated by putting the check where it looks like it
belongs. **The failure is in the direction where the user believes they are encrypted.**

**The right place already existed with a written argument attached.** `qn.6c`'s `CheckStorages` +
`StorageRequirement.Explain` run on the serve path, print a remedy to stderr, and exit non-zero.
Contracts §6 says why they are not `Validate` errors, and the sentence transfers verbatim: routing
them there *"would start a daemon that serves a healthy-looking UI and can back nothing up."* The
TLS refusal reuses that shape rather than inventing a second refusal idiom.

## The spike answered the question it was filed to answer, and then answered a better one

**Check 1 CONFIRMED.** Chromium hard-blocks service-worker registration on any certificate error,
read from shipping `main`: `SSLHostStateDelegate` — where the user's click-through decision is
stored — **does not appear in the predicate at all.** Not a bug; an absent code path. So
self-signed forecloses `qn.12` push, which is what the architect suspected on 2026-08-01 while
recording that the claim was unmeasured.

**A trap worth carrying forward:** W3C Secure Contexts is scheme-based and silent on certificate
errors, so a bypassed origin **is** a secure context and `isSecureContext` reads `true`. The block
is a fetch failure. Any reasoning starting from `isSecureContext` reaches the wrong answer.

**Check 2 is UNRESOLVED and was reported as unresolved.** Every iOS framework mechanism that could
persist a Safari exception is absent — `SecTrustSettings.h` is not in the iOS SDK, WebKit's
per-host allowlist was deleted in 2023 and its SPI is an empty stub — yet macOS Safari demonstrably
keeps its own record, and iOS 7 persisted. No post-2024 iOS report exists either way. Owed to G7.

**And the finding nobody asked for is the one that decides slice 3:** a Safari click-through
reportedly does not cover the **WebSocket** upgrade on iOS, and quince has exactly one WebSocket.
The page loads, the user believes they are in, the live connection silently does not come up —
against a hard rule that degraded modes are surfaced. Third-party source, cheap to falsify on the
hardware G7 already owes, and it should be the first thing that run checks.

## Two findings filed rather than fixed

**quince#488 — the private-layer clone on this box cannot fetch, and `git fetch` exits `0` while
saying so.** Its credential helper names `/tmp/tmp.KnGfDn/quince-bot.token` — a tempdir that no
longer exists, for an account that is suspended. quince#121's shape on the runner rather than the
arch box. **It was caught only because `privacy-check` prints its pattern source and says the
currency claim is bounded by a fetch it cannot verify** — quince#281 working exactly as designed.
Not fixed locally on purpose: it is provisioning, and a local fix would make this session's sweeps
trustworthy while leaving the class in place and removing the evidence.

**devlog#177 — `progress.md` says `qn.6c`'s four gaps are unruled and its code is blocked.** All
four are `RULED` in canon, two are `IMPLEMENTED`, and the code is on `main`. quince#408's defect in
the one file `bin/gap-heading-check` cannot see, because the gate scans the product repo and this
file is in the devlog. Not folded into devlog#179 — two claims, one diff — and *"just delete
questions 2–5"* is not obviously right, since quince#458 overruled half of gap 3 the same day.

## What was not proven

**G7 — a real phone — is owed to the Operator and no PR claims it.** Nothing in this session
touched hardware, and checks 1 and 2 cannot be settled from a session. The gate probes were the
one thing I refused to take on trust: `gap-heading-check` returns clean whether or not it
*recognises* a block, so each new block was probed by inserting a `RULED` line and confirming the
gate failed, by file and line, before the probe was reverted.

Refs: quince#462, quince#446, quince#487, quince#489, quince#491, quince#488, devlog#177, devlog#179.
