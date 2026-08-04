# 2026-08-04 — the defect existed only in the pair, so no single machine's log contained it

**The public demo's login failed intermittently, every server-side probe passed, and the Operator
read the logs and correctly reported nothing suspicious — because nothing was, in either machine.
The app had two, each with its own session database, and fly-proxy balanced between them.**

Reported as *"now I can't log in to public demo at all"*, with fly logs attached and nothing wrong in
them. Fixed by `fly scale count 1`; verified 5/5; filed as [quince#636](https://github.com/novkostya/quince/issues/636),
with the half that stops it returning as [quince#637](https://github.com/novkostya/quince/issues/637).

## Everything measurable said the server was healthy

Against the live instance, before understanding anything:

```
password "demo"                        200 {"state":"authenticated"}   3/3
login with NO csrf header              200      (deliberately exempt)
login with a STALE csrf token          200
GET /api/onboarding/https              {"complete":true,"detected":"forwarded_proto"}
   — on demo.quince.page AND quince-demo.fly.dev
rate limiter                           10/min per IP, resets on success
```

**Every one of those is a single request.** That is the whole reason they passed, and it took the
fly log to see it.

## A hypothesis, formed and disproved, recorded because it was nearly reported as the cause

quince#617 had just configured `QUINCE_TRUSTED_PROXIES`, which flips `SecureOrigin` from *believe
anyone* to *believe only peers in `172.16.0.0/16`*. If the custom domain routed through anything
else, `ClientIP` would fall back to the peer and put every visitor in one rate-limit bucket —
quince#464 returning through the back door. It fit the symptom exactly.

`GET /api/onboarding/https` reports that predicate directly, and it answered `forwarded_proto` on
**both** hostnames — meaning `TrustsPeer` passed and the trust list covers the real peer. The theory
was wrong, and one endpoint said so in a second.

## The line that actually contained the answer

```
10:03:43  App quince-demo has excess capacity, autostopping machine 781231db037578.
          1 out of 2 machines left running (region=fra, process group=app)
```

`fly.toml` declares no `[mounts]`; `deploy/demo.md` states the design — *"no volume, no persistence
— the rootfs is the state and it is thrown away."* Sessions are a SQLite database inside **each
machine's own rootfs**. So:

```
POST /api/auth/login  -> machine A    200, sets quince_session=X on A
GET  /api/devices     -> machine B    B never heard of X -> 401 -> back to Sign in
```

It succeeds whenever consecutive requests land on the same machine, which is why it healed by itself
and why retrying "fixed" it.

## Why the logs were clean, which is the part worth keeping

**The failure is not an error anywhere.** Machine A logs a successful login. Machine B logs a routine
401 for an unknown session — identical to what it logs for any expired cookie, and not worth a
warning. Neither machine is wrong.

**The bug existed only in the pair.** Reading one machine's log — the natural thing to do, and what
was done — cannot show it. The generalisation is the same one the probes above demonstrate from the
other side: *a defect that only exists across two requests is invisible to any number of
one-request checks, however many you run.*

## The fix is not in this repository, and that is the durable finding

`fly scale count 1`. **Machine count is not expressible in `fly.toml`** — verified against fly's
configuration reference, which has no count key; `min_machines_running`, `auto_stop_machines` and
`auto_start_machines` shape behaviour without capping the number. So no file here changes it and a
redeploy does not fix it.

Which means the constraint the demo's whole state model rests on — *exactly one machine* — is carried
by an app setting and an issue, and nothing enforces it. quince#637 asks `deploy/fly-deploy` to
refuse when the app has more than one, and flags the thing that could sink it: a deploy-scoped token
may not be able to list machines.

## Verified rather than assumed

Five independent login → navigate → navigate sequences after the scale, all clean, plus negative
controls so the 200s mean something — wrong password `401 bad_password`, no session `401`.

**Five and not one on purpose.** With two machines and round-robin, a single pass had roughly even
odds of landing both requests on the same machine and passing by luck. Five consecutive is what
separates *fixed* from *lucky*, and one green run would not have closed it.
