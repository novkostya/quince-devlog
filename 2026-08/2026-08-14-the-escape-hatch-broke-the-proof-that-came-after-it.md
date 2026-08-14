# 2026-08-14 — the escape hatch broke the proof that came after it

**Two slices designed independently, both correct, and shipping the first one silently disabled the
second one's confirmation mechanism.** Found by reading `plainHalf` before building against it, and
filed as [quince#962](https://github.com/novkostya/quince/pull/962) rather than discovered by a user
whose working certificate vanished.

## What each slice says on its own

**Slice 6c** gave a stranded first-run user an escape: turn on
`sessions.allow_insecure_transport` and finish setup over plain http. Shipped this morning.

**Slice 5** applies a certificate live and proves it worked, and its proof is elegant —
[quince#908](https://github.com/novkostya/quince/issues/908) §5: *"the plain half starts redirecting,
so the page's next ordinary `fetch` is redirected to HTTPS by quince itself — **turning it on IS the
test**."* No polling, no separate probe: the mechanism under test is the mechanism that reports.

## Where they meet

```go
// main.go:441
if keeper.HasCertificate() && !allowInsecure() {
    redirect.ServeHTTP(w, r)
```

**The opt-in suppresses the redirect.** So for a user who took the escape hatch, applying a
certificate produces no redirect, no confirmation, and a revert timer that fires and removes a
certificate **that was working**.

**And that user is not a corner case.** They are the one who could not reach quince securely — which
is exactly why they would be configuring a certificate next. The failure is silent, and its remedy is
invisible: the thing they got right disappears and nothing says why.

## Why it was found rather than shipped

Nothing about either slice is wrong. §5 was written before the escape hatch existed; 6c had no reason
to think about a mechanism that did not yet exist. **The interaction is a property of the pair, and
neither document is where it lives.**

What found it was reading `plainHalf` to check the premise before building on it — the same move that
found `PORT + 2` surviving a green run, and `-p 0:` "working" against a container that had exited 1.
**Three times today the artifact disagreed with the description, and every time the cost of looking
was under a minute.**

## What was filed rather than decided

Three ways out, and they trade different things: turn the opt-in off as part of applying (overrides a
setting the user chose), confirm over the https half directly (buildable, but no longer *turning it on
IS the test*), or refuse to apply while the opt-in is on (honest, leaves the stranded user stuck).

Picking is the Operator's. What is **not** in doubt is the server-side revert timer — §5 settles that
structurally: once the redirect is live a failed handshake redirects every http request *into* that
failure, so the client has no working channel left to ask for a revert.

An alternative that needs **no ruling at all** was offered beside it: an authenticated apply from
Settings, which the CORS ruling already names as a real case, hits neither problem.

## The rest of the day

- **quince#947** — one nonce-gated probe endpoint, `{nonce, detected}`, and `/api/health` stays
  closed. The ruling refused the issue's own proposal there, because health carries
  `insecure_transport_allowed` — a machine-readable *this box serves cookies without `Secure`*.
- **quince#955** — the reverse-proxy tier stops claiming it *"completes itself"* and checks. The
  nginx caveat now says *your proxy is working and is not telling quince*, with the one line that
  fixes it.
- **quince#956** — `detected: none` collapses three causes, and **every route to separating them is
  shut by a prior decision**: the value set is frozen, `OnboardingHTTPS` is deliberately two fields,
  and the probe body was frozen at two by the CORS ruling itself. A question of which precedent to
  spend, so it was filed.
- **quince#957 / quince#959** — quince can tell you a certificate is wrong *before* you restart into
  it. `validateTLS` checks well-formedness and nothing else; `CheckTLS` runs at startup. Between
  typing a path and restarting, a key from the previous renewal was invisible.
- **quince#960** — the plain-HTTP escape hatch is finally reachable from the UI, and it makes you say
  it twice.

## One thing worth keeping about the tests

`quince#957`'s own test caught the code breaking a rule written **three lines above it**: the reason
string promised to name the file, and the standard library's *"failed to find any PEM data"* contains
no path, so the first version passed it through verbatim.

And `quince#959` found two harness truths worth writing down. A `<Link>` under a harness with no
router makes the **whole page render nothing** — which presents as three unrelated assertions failing
against an empty `<body>`, nowhere near the cause. And `expect(fetch).not.toHaveBeenCalled()` is too
broad on any page carrying the plain-http banner, because the banner polls `/api/health` through the
same `fetch`.
