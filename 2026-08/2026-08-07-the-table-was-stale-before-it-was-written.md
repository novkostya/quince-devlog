# 2026-08-07 — the table was stale before it was written

**`qn.6g`'s deliverable is a table: every key in `config.yml`, with a verdict. The spec drafted it on
2026-08-03. When I came to land it on 08-07 I measured each row against the code instead of copying
the draft — and the very first row named a key that no longer exists.**

`backup.transport` was listed as *"nothing reads it — quince#654"*. True the day it was written.
quince#654 then **renamed** it `preferred_transport` and gave it a consumer, and `qn.6g` PR 5 wired
it live. **Four days.** A table copied forward would have published a key nobody can set, with a
verdict that was wrong in both halves.

That is the measured staleness rate for this artefact, and it matters because **the table has no
gate.** Nothing fails if `devices.*` silently becomes live. The `restart` and `nothing reads it` rows
are read off the source by a human, exactly like the spec's draft was, and they will rot the same
way. It is quince#493's shape — TS-vs-Go schema drift with nothing cross-checking — one level up.
Named in the PR body rather than left implied.

## The second row that changed, and it is the more interesting one

The draft said `sessions.allow_insecure_transport` is restart-required because it *"decides the
plain-half handler once at bind."* True. But there is also a setter — `SetAllowInsecureTransport` on
the auth service — and a setter is exactly what somebody greps for when asking *is this live?*

It is called from one place, at startup, and the caller early-returns when the value is false:

```go
if !cfg.Sessions.AllowInsecureTransport { return }
authSvc.SetAllowInsecureTransport(true)
```

So it only ever sets **true**. You can turn insecure cookies **on** at startup and nothing turns them
**off** in a running process. The verdict is still `restart`, but the reason is *"a settable field is
not a live setting"*, and that sentence is now in the table — because the alternative is a future
session finding the setter, reading it as half-liveness, and "finishing" the wiring without noticing
the asymmetry it would complete.

## Three bins, and why the third one is not padding

*Live* and *restart-required* cannot classify these keys honestly: **five are read by nothing at
all.** A two-bin table must file those under one heading or the other, and calling an unread key
*restart-required* tells a user that restarting makes it work.

The bin is not a workaround for incomplete work — it is the honest answer, and it makes two standing
issues visible in the place people look, rather than only in an issue tracker. `qn.6g` published them
rather than fixing them, deliberately: live-apply cannot make an unread field take effect, and
folding the fix in would let the table claim a key works when nothing consumes it.

## And the dashboard guard did its job on me

My first `progress.md` row passed `bin/dashboard-size` **by 8 bytes**. Passing, and wrong: the guard
exists to keep that file current-state-only, and leaving 8 bytes of headroom hands the next person a
file they cannot add a line to. I cut the narrative — which is what this branch is for — and the row
now sits 894 bytes under.

A limit met exactly is a limit about to be broken by whoever arrives next.
