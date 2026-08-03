# 2026-08-03 — the router cleaned the path and the POST came back as a 404

**A storage quince has never reached has no id, so the Re-check button sent
`POST /api/storages//recheck`. Go's `ServeMux` path-cleaned that to a `307` — which PRESERVES THE
METHOD — and the re-sent POST matched no route. The user pressed the button on the one storage it
exists for and got a silent 404.**

Session `r14`. This was `qn.6d`'s open question 4, which had been carried as *"needs a credential no
agent seat holds"* for two sessions. That was wrong, and the way it was wrong is the entry.

## It was never credential-blocked

I had assumed the reproduction needed an authenticated session, because `/api/storages` answers
`401`. **The redirect happens in the router, before the auth guard** — so the whole thing was
measurable without a session, from the first minute. I never tried, because I only ever reached for
the authenticated path.

The Operator eventually put a cookie on the stand to unblock me. By then the answer was already
measured. **The credential is not what unblocked it; being asked to look again was.**

## What it takes to send the request

Nothing ordinary can:

- **`net/http` normalises a doubled slash out of the URL before the wire**, so no Go test using
  `http.Client` can express this request;
- **`curl` needs `--path-as-is`** for the same reason;
- forcing it with `URL.Opaque = "//api/…"` **looks like it works and does not** — a leading `//`
  makes Go parse the next segment as a **host**, so the server sees a different path. My first probe
  "reproduced" a 307 to `/storages/recheck`, missing the `/api` prefix, and I nearly believed it.

It takes a raw socket. **A test that could have been written conveniently would have been testing
something else** — which is exactly how this survived every gate.

## Three attempts before the measurement was sound

1. `URL.Opaque` — wrong path, plausible answer.
2. Raw socket, unauthenticated — correct, but I asserted the cleaned path returns `404`; it returns
   **`401`**, because the auth guard wraps the mux and answers before routing.
3. Against the running daemon with a session — `307 → 404 after 1 redirect`. The real thing.

The control mattered more than the probe: a real id returns `200`, so the route works and only the
empty segment does not.

## The fix was ruled in August and never built

quince#570: *"the API addresses a storage by its config `name`, not the marker UUID."* Forget shipped
that way. **The recheck route was left behind**, and `qn.6d`'s spec names the change and defers it.
So this was not a new decision — it was a ruling with no PR attached, sitting in canon under a
paragraph that said *"Ruled and NOT yet built"*.

Review caught that same paragraph still saying so **in the PR that built it**. That is quince#584's
defect one route later, four PRs after #584 corrected it.

## The general rule, which is what survives

**Never key a route on a value that can legitimately be empty.** The `307` is Go's own and is not
going away; what a route controls is whether a client can produce that URL at all.

## And one process failure worth more than the bug

My first *"full ladder, exit 0"* ran against an **empty diff** — the changes were uncommitted, so
`SCOPE=origin/main...HEAD` selected only the always-run shell suites and `gates-go` never executed.
Caught by noticing **320 `ok` lines with zero `github.com/novkostya` among them**.

Had I trusted the exit code, the PR would have claimed a green Go gate that never ran. The real run
then found three genuine failures, one of which was **my own wrong assertion that the fix would stop
the 307** — it does not, and was never meant to. It stops the client producing the URL.

*Exit 0 can be true and still wrong* is a note I already carry. It cost a cycle anyway.

Refs quince#610, quince#613, quince#570, quince#443.
