# 2026-08-14 — the field that looked like it already answered was false exactly when it mattered

**A warning about plain http could not be driven by the field named `insecure_origin`, because with
the plain-http opt-in ON that field reads `false` — on precisely the install whose login form must
carry the warning. Two names one letter apart in meaning, inverses in the only case anybody cares
about.** Landed as [quince#932](https://github.com/novkostya/quince/pull/932); the banner that reads
it is [quince#933](https://github.com/novkostya/quince/pull/933).

## What was being built

[quince#908](https://github.com/novkostya/quince/issues/908) slice 6 — the plain-HTTP confirm. The
Operator ruled the pre-auth config write on 2026-08-14, answering all three questions the
`PROPOSED (gap)` block in `docs/contracts.md` §1 had left open: the route should exist, `Configured()`
is the guard, and it does **not** go under `/api/onboarding/`.

The ruling then added a requirement nobody had proposed: **the login page must carry a very noticeable
warning while the opt-in is on.** That is what makes the ruling safe rather than merely bounded —
the pre-auth write means the setting can be turned on by somebody who is not the owner, and the owner
then arrives at a login form about to type a password that crosses the network in clear.

## The finding, which the ruling named before anybody hit it

`GET /api/health` already carried `insecure_origin`, added a day earlier for first-run routing. It
answers *"would a session cookie earned on this connection be discarded?"* — and it is the obvious
thing to key a plain-http warning on.

It is wrong, and wrong in the silent direction. With `sessions.allow_insecure_transport` on, cookies
stop being marked `Secure`, so nothing is discarded, so the field reads `false`. A banner keyed on it
would be **silent on every install that needs it** and loud on installs that do not.

Measured on three containers, all asked with a LAN-style `Host` over plain http:

| container | `insecure_origin` | `insecure_transport_allowed` |
| --- | --- | --- |
| opt-in **off** — the dead end quince#908 is about | **`true`** | `false` |
| opt-in **on** — the install the banner is for | **`false`** | **`true`** |
| `--demo` | `false` | `false` |

The middle row is the whole of it.

## What was done about it

A second field, `insecure_transport_allowed`, named for the **setting** rather than for the symptom —
`insecure_transport` alone would have sat one letter from its neighbour in spelling as well as in
meaning. Read from `auth.Service`'s own atomic rather than from the config snapshot, so the warning
and the cookie flag it predicts cannot drift.

And a test that asserts the two fields **disagree** when the opt-in is on, so the "simplification"
onto the nearer-sounding field fails rather than shipping. The architect verified that test by making
the substitution on purpose and reporting that it went red in *both* directions — including the
silent one, which is the half a weaker suite would miss.

## What is worth keeping from this

**Two facts that sound alike are not one fact, and the way to tell is a table of the cases rather than
a careful sentence.** The prose distinction had been written twice already — at the field, and in
contracts §1 — and it was still the natural mistake to make. What settles it is four rows where two
columns disagree.

**The ruling naming the trap is what stopped it costing anything.** The Operator wrote *"`insecure_origin`
CANNOT drive this banner — it is FALSE exactly when the opt-in is ON"* into the ruling itself, rather
than leaving it to be discovered in review or on a soak. This is the second time in a week that a
ruling has carried its own implementation hazard: quince#908's earlier note that the `needs_setup`
bound must be enforced **by the server** is the same shape — *the failure arrives by implementing the
ruling carelessly rather than by disagreeing with it.*

## Also, small

`make demo` could not bind: twelve containers from other runners occupy 8968–8977 and it scans only
ten. Deployed on 8994 with `DEMO_PORT`. That is
[quince#913](https://github.com/novkostya/quince/issues/913)'s family — a fixed base with a short
scan — one script over.

`closing-refs-check` caught `Closes quince#539` in a commit message binding to nothing: GitHub
resolves `#N`, `GH-N` and `owner/repo#N`, and a repo shorthand without the owner is none of them. The
issue would have stayed open after its work merged, which reads as a stall and gets the work re-taken.
