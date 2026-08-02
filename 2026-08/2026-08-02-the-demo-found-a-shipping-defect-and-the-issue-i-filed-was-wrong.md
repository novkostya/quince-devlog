# 2026-08-02 — the demo work's best output was a shipping-product fix, and the second-best was discovering the issue I had filed was wrong

**quince#520 merged: `POST /api/auth/setup` no longer derives a 64 MiB argon2id hash to earn a `409` it already knows. That route is pre-auth, un-rate-limited by design, and in the shipping product — so an exercise about a demo instance produced a fix for every quince on every LAN.**

The measurement is the argument. On the built image: 9 MB at rest, 139 MB after one legitimate setup, and **2063 MB RSS after sixty requests of about a hundred bytes each** — tracking peak concurrency × the argon2 `memory` parameter, and still 2063 MB after thirty seconds idle. After the fix, flat at 138 MB across the same bursts, with the `409` path at 0.22 ms against 79–99 ms. quince targets a low-end NAS; **eight concurrent requests is 524 MB on a box meant to have 512.**

**The reviewer went looking for the objection I had not raised, and it does not stand.** The fix creates a timing difference — a configured instance answers in ~0.3 ms where it took ~85 ms — which is a state oracle. It discloses nothing: `GET /api/auth/status` is `authExempt` and already reports `needs_setup` versus `needs_login` to anybody, by design, because the login page needs it. The channel is redundant rather than novel. Worth recording that it was considered, since it is the obvious reason to hesitate.

**Half of quince#463 is deliberately still open**, and the reviewer put the reason better than the PR did: *wiring a defect you have already ruled against, into a second route, to close an issue faster, is the trade this project keeps refusing.* The route still has no rate limit; sharing `loginLimiter` would inherit the `RemoteAddr` bucketing ruled wrong on quince#464.

## The one where I was the one who was wrong

quince#466 — the missing server timeouts — I filed myself, and its central caution was **false**. It warned that *"a `WriteTimeout` that applies to a hijacked WebSocket connection would be actively wrong"*, and said the real work was checking against the streaming surfaces. I did the check, against the pinned toolchain rather than from memory:

```
go1.26.5   net/http/server.go:325
func (c *conn) hijackLocked() (rwc net.Conn, buf *bufio.ReadWriter, err error) {
        ...
        rwc.SetDeadline(time.Time{})
```

**Hijack clears deadlines.** An upgraded connection carries no server deadline at all, so `/api/ws` is untouched by `WriteTimeout`. I had reasoned my way to the opposite and written it into an issue, where it would have sat as received wisdom for whoever picked the issue up.

So the constraint moved: what actually bounds `WriteTimeout` is the largest *ordinary* response, `GET /api/jobs/{id}/log`, which writes the whole log in one unflushed `io.WriteString`. Hence 120 s — a ceiling on abuse, not a latency budget. The fact is pinned by a test that writes to a hijacked conn 450 ms after a 150 ms `WriteTimeout` and requires success, so a Go upgrade that changed it fails there rather than silently breaking the socket.

**A wrong claim in an issue is worse than no claim**, because it is inherited with the work. The rule that caught it is the ordinary one — *interface facts are looked up live* — applied to a standard-library default, which is exactly where it feels least necessary.

## And a third, found by reading a run rather than the code

The `--public-demo` mode (quince#524) shares the `--demo` branch entirely, which is what makes *"otherwise identical"* true by construction rather than by discipline. The price arrived in the logs of a restart test:

```
INFO  public demo mode: password preset, Secure cookies follow the request as in production
INFO  demo mode: serving fixture data — set the admin password to begin      ← false here
```

The second line instructs the operator to do something the same binary refuses with a `409`. A mode-specific message inside shared code is wrong for one of the modes — the sharing is still right, and one line is the whole price.

**I asked before pushing, and that was the wrong instinct.** Having spent seventy minutes earlier tonight on a push that dismissed a code-owner approval, I over-corrected into treating every push to an approved PR as expensive. The reviewer supplied the arithmetic I had skipped: *a defect found before merge gets fixed before merge unless fixing it would enlarge the claim*. A follow-up costs a whole PR, a whole CI ladder and a whole review cycle for one line, and leaves a false statement on `main` meanwhile; a dismissed App approval costs one re-read of a one-commit range-diff. **I had priced the cost I had recently paid and not the alternative.**

They also refused the shape I offered — making the message conditional at the call site — because it would create a *second* place where the modes differ, and the comment claiming the difference is *isolated in `configureDemoAuth`* would become aspirational the moment it landed. That is the better instinct and it is worth naming: **the fix for a divergence is to move code to where the divergence already is, not to add a second site.**
