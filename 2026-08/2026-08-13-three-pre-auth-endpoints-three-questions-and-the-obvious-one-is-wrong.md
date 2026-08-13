# 2026-08-13 — Three pre-auth endpoints, three questions, and the one that looks like the answer is the wrong one

**A first-run user on plain http cannot complete setup at all. Routing them out of that dead end needs a server fact, and quince already had three candidates — one of which is a trap: it disagrees with the one you want exactly on the deployment every contributor runs.** quince#908 slice 2, shipped as quince#923.

## The dead end

`refuseInsecureOrigin` runs BEFORE the credential is examined — before `SetPassword`, deliberately, so a refusal cannot leave a first-run user with their password silently in force. The consequence is that on plain http at a LAN address, **every password typed into the setup form answers 426**. The form works. It cannot succeed. Its only exits are editing YAML on the box or knowing about `localhost`.

## Three endpoints answer three different questions

The issue said neither `/api/health` nor `/api/auth/status` carried the fact. There is a **third** authExempt endpoint it did not mention, and checking it is what made the design certain rather than merely plausible:

| endpoint | asks |
| --- | --- |
| `/api/auth/status` | **who are you** — and it is frozen |
| `/api/onboarding/https` | **can you reach quince from your phone** |
| `/api/health` | *(now)* **can a credential be established over this connection** |

`detectHTTPS` reports `complete: false` on `http://localhost` **on purpose** — its own comment says the step "is not 'can you log in from this browser'". But a session cookie survives loopback perfectly well. So the two facts agree on almost every deployment and disagree precisely on the one a developer is sitting in front of.

**A client keying first-run routing on the onboarding fact would redirect every contributor on localhost to the HTTPS page** — the same misfire the issue warns about for `window.location.protocol`, reached through a server fact instead, which is the version nobody would think to question.

Measured on one process, distinguished only by the `Host` header:

```
loopback              /api/health → insecure_origin: false   POST /api/auth/setup → 200
Host: quince.example  /api/health → insecure_origin: true    POST /api/auth/setup → 426
same connection       /api/onboarding/https → {"complete": false}
```

## The field is the refusal's own predicate, not a copy of it

`handlers_auth.go` asks `d.Auth.CookieWillBeDiscarded(r)`; so does the health handler. Not two implementations that agree today — the same call. The test asserts the field against the **refusal itself** rather than against a re-derivation, so a change to what `refuseInsecureOrigin` gates on fails there instead of quietly leaving the field describing the old rule.

That shape is borrowed rather than invented. `RequireStorage` carries a paragraph about what two implementations of one predicate cost: the server decided whether to REFUSE, the client decided where to POINT, and a first run fell in the gap between them.

## A guard written, measured, and deleted

`Deps.Auth` is a pointer, so `if d.Auth != nil` looked prudent. The test case written for it returned **500 from the middleware** rather than 200 from the guard: `middleware.go` calls `d.Auth.Secure(r)` on every request including the authExempt ones, so a router with no auth service cannot serve this endpoint or any other. The guard was unreachable and its comment described a router that cannot exist.

**The measurement is what settled it.** Read alone, the guard is obviously correct; the only way to find out it is dead is to write the test that proves it and watch the wrong thing fail.

## What could not be shown, and where

The demo tier cannot exhibit the positive case at all — `--demo` forces `Secure` off, so `insecure_origin` is false there by construction. The `true` measurement came from a separate non-demo container. Worth stating rather than letting a green demo imply coverage it does not have.

## A dependency nobody declared, which happened to land the right way round

`OnboardingHTTPSPage` — the page this now redirects to — tells the user that setting `sessions.allow_insecure_transport` makes sign-in start working. **That sentence was false until the same evening**: the setting was restart-required until quince#905 moved it. The copy had been ahead of the implementation for weeks, and the gap closed hours before the redirect that makes the page load-bearing.

Nobody connected the two. It is the pleasant version of the failure this project files most — a document describing a reality that does not exist — and the only reason it reads as a coincidence rather than an incident is which way the gap closed.
