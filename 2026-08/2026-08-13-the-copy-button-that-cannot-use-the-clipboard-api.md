# 2026-08-13 — the copy button that cannot use the clipboard API

**A one-line feature request turned out to be unbuildable the obvious way, and the reason is a
property of how quince is deployed rather than a browser quirk: `navigator.clipboard` requires a
secure context, and quince is routinely reached over plain http at a LAN address.**

The Operator asked for *"a small copy to clipboard icon/button"* on the `authorized_keys` line the
zfs branch now shows (quince#818 piece B), and asked a second question with it: *did we implement
the same thing for the helper file contents?* The second answer came first, by grep — **no, because
the helper is not rendered in the UI at all.** Zero references to `quince-zfs-helper` anywhere in
`ui/src`. That is the deferred half of piece C, stated on quince#884 in as many words, so the
inconsistency the question suspected does not exist; the screen does.

**The first answer is the interesting one.** `navigator.clipboard.writeText` is the one-liner every
example shows, and on this product's most common deployment it is `undefined` — the API is exposed
only in a secure context, and there is a whole onboarding page (`/onboarding/https`) about reaching
quince over plain http on a LAN. Shipping the one-liner would have produced a button that works on
the developer's `localhost` and does nothing on the operator's phone, which is the worst possible
distribution of outcomes: it passes every check the author can run.

So three rungs, and the third is the point:

1. `navigator.clipboard.writeText` where it exists;
2. a hidden textarea + `document.execCommand("copy")` — deprecated, and what actually works;
3. **`failed`, said out loud** — `Press ⌘C`, with the text left selectable.

Rung 3 is state honesty in a place that looks too small to need it. A copy button reporting success
it did not achieve is worse than no button: the operator walks away believing they hold the line,
and pastes whatever was on the clipboard before — into a storage host's `authorized_keys`. And this
particular line is the one where a partial paste is dangerous rather than annoying:
`command="/usr/local/sbin/quince-zfs-helper"` leads it, so a hand-selection that clips the front
leaves a **working key with no constraint** — an unconstrained shell login. One press cannot clip
it, which is the actual argument for the button existing.

**The e2e assertion is worth more than the component.** The suite drives
`http://<host>:8968` — a hostname, not localhost — so the harness is *already* an insecure context,
by accident of how `gates-ui-e2e` composes. The test now asserts `isSecureContext === false` and
`navigator.clipboard === undefined` **before** it clicks, so the `copied` that follows can only have
come from the `execCommand` rung. Without those two lines the test would pass identically on a
harness that had quietly moved to localhost, while proving the easy path — a green check for the
half that was never in doubt.

`make gates` exit 0, `make gates-ui-e2e` exit 0 (48 passed; story12's scroll test flaked and passed
on retry, untouched here). What is **not** proven: no real iOS Safari run — rung 2 is proven in
headless Chromium, and only a phone can prove the browser this screen is used from. Rung 3 has unit
coverage only, because both earlier rungs work in Chromium and nothing reaches it.

quince#885.
