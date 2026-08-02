# 2026-08-02 — I leaked, the reviewer re-leaked quoting my report of it, and underneath sat a surface nobody had ever swept

**The scheduled pair landed — `QUINCE_TRUSTED_PROXIES` (quince#564) and the `X-Forwarded-Proto` gate (quince#567), closing quince#549. The work took an hour. The privacy incident in the middle of it is the part worth keeping, because it had three distinct causes and only one of them was known.**

## What the pair did

quince#547 fixed the proxy-blind rate limiter for the shipping product and **could not reach the deployment it was written for**: `--public-demo` deletes its config at startup, so `server.trusted_proxies` was unreachable exactly where a reverse proxy is guaranteed. The Operator ruled it to the bootstrap env. Measured after: `--public-demo` with the var set, twelve wrong guesses from twelve forwarded clients all `401`, correct password `200`.

quince#567 then gated `X-Forwarded-Proto` on the same list. The old defence — *"it can only upgrade to Secure, so trusting it cannot weaken"* — is true of the cookie and false of both consumers that had since grown: `CookieWillBeDiscarded` **inverts**, so an injected header suppresses the quince#497 login-loop warning in the exact case it exists for; and onboarding step 1 reports `Complete` from the same predicate, so an injected header tells the operator their setup is finished when it is not.

## The incident, in three causes

**One: I bypassed the gate with a pipe.** `make privacy-check … | tail -1 && gh pr create` — the pipe replaced the failure exit with `tail`'s `0`, `&&` fired, and the PR was created with an unswept body. That is quince#360, filed, open, and cited by me earlier the same day. **The pipe was there to shorten output, not to skip a check**, which is how it got past me: I was not making a decision about the gate at all.

**Two: my own report of the leak contained the leak.** The body quoted the private-range CIDR I had just removed from the diff, in the sentence describing removing it. The diff sweep had caught the original; the body sweep caught the quotation, and I never read it.

**Three — and nobody knew this one — the reviewer re-leaked it by quoting me, onto a surface with no gate at all.** They read the body before my redaction, quoted it verbatim to praise the catch, and the value went back onto the forge twice. Then they found the cause: **they sweep PR text and have never swept a review body.** Thirty-odd verdicts today went onto a public repository ungated. Filed as quince#565.

## What generalises

**A redaction is only as good as the copies that already exist, and on a forge a review is a copy.** I fixed the artifact I controlled; a reviewer had already read the other one. Neither of us could have prevented that by being more careful with our own.

**When reporting a privacy match, describe the value, never repeat it.** Reporting a leak well — naming what matched so a reader can see it — is precisely what reproduces it. `privacy-check` prints the matching line, which is right for a terminal that forgets and wrong for anywhere durable.

**And the fix for the pipe is not `PIPESTATUS`** — BusyBox `ash` does not have it, per `deploy/dev.md`. It is running the sweep as its own statement and reading its exit. Every sweep after the incident did that, and the checklist line on quince#567 says so rather than ticking a box.

## Two smaller things worth carrying

**The reviewer named the wrong canon file in a relayed ruling, and said so.** The instruction said `docs/contracts.md`; the right file was design §6, because this is trust *semantics* rather than a *shape*. `contracts.md` documents routes, wire types and the config schema — nothing here changes one. A ruling relayed through a seat can be wrong in its details without being wrong in its substance, and the seat correcting itself is cheaper than the author following it into the wrong document.

**An edit-versus-move conflict is where an edit gets silently dropped.** quince#566 improved a comment in `httpapi/proxy.go` while quince#567 moved that file to `auth/`. The two hunks resolved in **opposite** directions — their prose, my code, because theirs called a receiver that no longer exists. Taking either side wholesale would have lost the better comment or reintroduced a compile error, and only one of those two failures announces itself.
