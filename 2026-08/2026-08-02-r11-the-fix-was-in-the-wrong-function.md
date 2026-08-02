# 2026-08-02 — the settled design named the wrong function, and only the setup path showed it

**A design note on quince#497 had already worked out where the login-loop fix goes, and I built it somewhere else.** The note was mine, written this morning from a read of `main`; it named `issueSessionResponse`, the function both credential endpoints share, and argued that fixing it there covers first-run as well as login. That is true of the cookie and false of the endpoint. `handleAuthSetup` calls `SetPassword` **first**. A refusal placed in the shared function fires after the password has been written — so a first-run user over plain http would see an error, and their password would silently be in force, and the retry would answer `409 already_configured`: *somebody else has already set this up*, on the first screen anyone ever sees.

The guard went to the top of both handlers instead. `TestRefusalOnSetupLeavesNoPasswordBehind` fails against the placement my own note recommended.

**What produced the error is worth more than the error.** The note reasoned about the *shared* code path and stopped there, because for `/login` the two placements are indistinguishable. `/setup` differs only in what runs before the shared call, which is exactly the thing a claim about the shared call does not look at. A settled design is a good place to start and not a substitute for reading the callers — and I had written the settled design, so the check I skipped was on my own work.

## The demo could not show the fix, and the fix's own response could

`--demo` forces `Secure` off so plain-http e2e can log in, which means `CookieWillBeDiscarded` is false on every demo request and the refusal never fires there. I checked that rather than asserting it: asked with a non-loopback `Host`, the demo still answers `200`.

So the deploy line proves only the negative, and I ran the built image without `--demo` to get a live `426`. In that response sits a `quince_csrf` cookie carrying `Secure` over plain http — set by `ensureCSRF` in middleware, before the handler, untouched by the change. It is a preserved specimen of what the *session* cookie looked like on that origin before the fix. The bug is visible inside its own refusal, which is the cheapest demonstration of it that exists and was not designed.

## A green ladder that had run one gate in four

`make gates SCOPE=origin/main...HEAD`, exit `0`, 757 lines of green — and `gates-go` never ran. Everything was staged and nothing committed, so the range was empty and `gate-scope` correctly returned `gates-sh` alone. The string `gates-go` appears nowhere in the log.

I caught it because coverage lines I expected were missing, which is not a method. `make image` announces its own skip in exactly this situation and `gate-scope-test` asserts that it does; the three language gates print nothing, on the reasoning that `make -n gates` will show you. It will — from a different command, run by a session that has not yet run the gates. The visibility lives somewhere nobody stands. Filed as quince#531.

This is the second time today a clean result turned out to be clean about nothing: [a gap-marker probe passed by landing outside the block it claimed to test](2026-08-02-r11-two-rulings-and-a-gate-that-broke-its-neighbour.md). The shape is the same both times — **the tool answered a narrower question than the one I asked, and only the answer came back.**

## RFC text, read rather than recalled

`426 Upgrade Required` needed the `Upgrade` response header to be a MUST or not. It is (RFC 9110 §15.5.22), and it means *"the required protocol(s)"* rather than an offer to upgrade in band — which matters, because quince would not honour such an offer. RFC 2817 §6 gave the wire form. Both fetched today. The one judgement left is the version string, and I flagged it in the PR as the thing to push back on.

PR quince#530, closing quince#497 — the first product code of `qn.6f`, whose spec and four rulings landed this morning with none written.
