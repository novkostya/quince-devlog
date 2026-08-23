# 2026-08-23 — three defects, one shape: the untested pair

**Every blocking finding on `qn.10`'s last three slices was a case where each half was tested and the combination was not.** quince#1521, #1522 — attachments and search, and the reviews that stopped them.

## The shape

Not an untested branch. An untested **pair**:

- **7c-2b** — `sessionGone` watched the chats query. Every expiry assertion ran against the one query that could never report it, because no test opened a conversation *and then* let the session expire. Each half covered; the pair not.
- **7e, first round** — `searchable` reads the capability, not the row count. My assertions were *empty + capability → true* and *empty + no capability → false*. Both hold if you derive it from `items.length`. The discriminating pair — **hits present, capability absent** — was missing, so the test passed under either implementation.
- **7e, second round** — the zero-hits screen dropped the build's warnings. Warnings-with-hits was tested. Zero-hits was tested. **Zero hits *and* a warning** was not, and that is precisely where an incomplete index gets reported as a complete negative.

A missing branch shows up as a coverage hole. A missing *pair* shows up as nothing at all: the suite is green, the assertions read correctly, and each one is true.

## What actually finds them

**Breaking the code and watching which test fails.** Four controls across the day:

| what was broken | result |
| --- | --- |
| `DeviceUDID()` → `""` | gate failed naming `messages.indexing` |
| the session-keyed count → `Object.values(...)[0]` | one failure, the intended one |
| `sessionGone` → chats only | one failure, the intended one |
| `searchable` → `items.length \|\| capability` | **1028 passed** — the test was vacuous |

The fourth is the valuable one. It found a defect in a *test*, which is the harder direction: a wrong test looks exactly like a right one from the inside, and no amount of re-reading it helps. Only asking *what would have to break for this to fail?* does.

And a fifth control **misfired**: it died at `tsc` on a now-unused const before any test ran. Exit code 2 — which, read alone, is indistinguishable from *the control worked*. A control needs its own control, which in practice means reading the output rather than the exit code.

## The reviews were reasoning, not measurement — and that was the right division

The reviewing seat had no Node, no browser, no container runtime, and said so at the top of every verdict. It could not run one test. What it did instead:

> **`sessionGone` is derived from `chats.error` only.** This PR adds a second query that can be the one to discover the session is gone — and in the thread it is the *likely* one, because that is where the reader dwells and where the TTL runs out.

and, on 7d:

> **Your five-format allowlist is downstream of a question nobody has answered.** Serve a fixture with `Content-Type: application/octet-stream` and `nosniff`, point an `<img>` at it, and assert whether it decodes.

That second one was the best finding of the day. `handleSessionFile` serves every file as `octet-stream` with a download disposition and `nosniff`, so an `<img>` is asking a browser to decode a non-image type from a server that said *do not guess*. If browsers refused, the whole inline half was decorative — **and the `onError` fallback would have hidden it**, turning total failure into "every attachment is a link" with every unit test still green.

Measured across three engines, each with an `image/png` control: chromium, firefox and webkit all decode it. Kept as a gate rather than a number in a thread, because the failure mode is invisible.

## The rule that keeps being rediscovered

*Reporting one state as another* is `qn.10`'s recurring defect, and the last three slices each hit it from a different side: an expired session reported as a working screen, a missing index reported as no results, an incomplete index reported as a complete negative. The file headers name the rule. Naming it does not implement it — **the pair that separates the two states does**, and only a control proves the pair is there.
