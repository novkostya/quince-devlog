# 2026-08-13 — Three things looked live, none of them were, and each hid behind a different shape

**Turning TLS on needed a restart, and the reason was a `nil` pointer at the bind. Underneath it were two more things that looked settable and were not: a setter that could only ever be called with `true`, and a freshness check that answered a different question from the one being asked. Each was invisible in a different way.** quince#900, shipped as quince#901, quince#905 and quince#916.

## What the issue asked for, and what was actually there

The ask was narrow and correct: `runHTTP` began with `if keeper == nil { plain http.Server }`, so an install that started without a certificate had **no TLS half at all** — and no amount of config writing could give it one. Bind the mux unconditionally and the socket stops being the obstacle.

The `nil` is the visible defect. The other two were found by pulling on it.

**A settable field is not a live setting.** `auth.Service.SetAllowInsecureTransport` has always accepted a `false`. Its only caller returned *before* reaching it when the opt-in was off, so nothing in a running process could ever lower the flag. `docs/contracts.md` already said so, in a sentence added because *"the setter's existence reads like half-liveness"* — the shape was documented and the consequence was not: the direction that could not be expressed is the last step of applying a certificate and keeping it.

**A freshness check can answer the wrong question and still be right.** `tlsx.Keeper.changed()` compares `(mtime, size)` per file, which answers *have these files been rewritten*. After a path change the question is *are we serving the pair the config names* — and after a **failed** path change the Keeper holds the old pair's stamps beside the new pair's paths, so a collision answers no to both. `cp -p`, `rsync -a` and a restored archive all preserve mtime, so the collision is something operators produce routinely. The daemon would serve a certificate the config had stopped naming, forever, with nothing logging why.

## What the three have in common

None of them is a bug in the sense of code that does not do what it says. Each is code doing exactly what it says while the **claim** has moved:

| | looks like | is |
| --- | --- | --- |
| `keeper == nil` | an optional feature | a decision frozen at process start |
| `SetAllowInsecureTransport(bool)` | a switch | a latch |
| `changed()` | freshness | freshness *of files*, asked where identity was meant |

The first was found by reading the issue. The second was found by the architect reading the contracts row that already described it. The third was found by the architect reading a **feature the PR was advertising** — the self-heal — and asking what would happen if the inference it rests on were wrong.

## The lockout that shaped the design

Once the plain half redirects and the handshake fails, **every** http request is redirected into that failure, so the client has no working channel left to ask for a revert. That is why the plain half decides on `HasCertificate()` — **loaded**, never merely *configured*. A config naming a certificate that does not parse leaves it serving rather than redirecting into a handshake nothing can complete.

The same reasoning decided the applier's shape. An `Applier` runs after the write and structurally cannot refuse it, so an unusable pair is **saved, warned, and not applied**: the daemon keeps the certificate it had, the `PUT` says so, and the new paths are kept so the next handshake picks them up when the files appear. Startup refuses where this warns, and the asymmetry is not a weakening — at startup there is no response to warn into.

## Measured on a container rather than argued

One process, one port, five steps: no certificate → apply → break the path → the files arrive → clear it. `grep -c "quince serving"` in the container log stayed at **1** throughout, and `openssl s_client` read the subject back at each stage — including step 4, where the awaited files appearing changed the served CN with no API call and no restart. That step is the third finding's payoff observed rather than asserted.

## What it cost, recorded because the process is the point

Two review rounds found four things, all real, none blocking. Both reviews mutation-tested rather than read: the reviewer disabled the fix and quoted the failing assertion. The one it *most* wanted red — redirecting with no certificate loaded — failed at three levels including the end-to-end listener test.

And three seats made the same class of error in one evening, which is worth more than any of the fixes: **reading a summary instead of the thing that answers.** A pipeline's `$?` reporting `tail` rather than `git push`; `auto-merge still armed` asserted from three API fields that do not contain it; an e2e count taken from a `grep` while the runner said otherwise. Different tools, same move.
