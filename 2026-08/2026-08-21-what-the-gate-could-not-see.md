# 2026-08-21 — Two silent defects the gates could not see, and the deploy that found both

**qn.8's slice 4 shipped a silent truncation. Its fix shipped a false diagnostic. Both were merged,
both had a green `gates-go` behind them, and both were found within an hour by deploying to staging
and asking the running binary a question.**

## What was built

Slice 4 — the passwordless `vault.Vault` for unencrypted versions, and the selection on
`IsEncrypted` that reaches it — plus slice 7's steps 1 and 4: the unlock dialog and the session-TTL
control. Seventeen pull requests across `quince`, `ios-backup-crypt` and `ios-backup-parser`.

The rung gate now passes for the class D7 exists for: unlock with an **empty password** → 200, browse
→ real entries, download → bytes matching the recorded size, lock → 204, then 409. The route that
answered **422** in the morning serves the version by the afternoon.

## The first defect: a silent cap, argued for in a code comment

The unencrypted implementation bounds its read to the recorded size. That is correct —
`Content-Length` is the recorded size, and serving the on-disk length would destroy the short-read
detectability it is paired with.

**Bounding alone means nothing overruns.** So the HTTP layer sees an ordinary success, and a file
whose blob holds more bytes than its record produces a **200 with the header agreeing with the body**
and `curl` exit 0. The user gets a truncated file and every signal says it is fine.

Measured on the stand: **4,096 bytes delivered for a 118,784-byte blob.**

The comment justifying it read *"keeps this implementation's answer identical to the encrypted one,
which truncates its decrypt to the same number."* Both halves false. The encrypted path overruns and
`net/http` tears the response — visibly, `curl` exit 18. **The two backends behave oppositely, in the
slice whose comment claims to unify them.**

**How the wrong premise got in:** I had measured the long-file case in `httptest`, against a stub
that returned more bytes than the entry's size — which modelled the *encrypted* path. I generalised
it to "this condition", wrote it into an issue, saw it adopted into a ruling, and then built against
it. The measurement was real. The context it belonged to was not carried with it.

## The second defect: the fix reintroduced the message the fix before it removed

`ErrOverlongFile` reached `io.Copy` and fell into the handler's `default` arm — which is the
short-read message. So the log said *"file stream ended early — the backup holds **FEWER** bytes"*
about a file with too **many**: quince#1381's own defect arriving from the other side, inside the fix
for quince#1379.

The handler cannot tell them apart, deliberately: `httpapi` is consumer-defined and imports no vault
subsystem. It does not need to. **At the HTTP layer nothing failed** — the body is exactly
`Content-Length` — so the registry wrapper records the condition and returns `io.EOF`, and the fact
travels as the `overlong` field.

Found by doing the redeploy the previous PR had declared as owed.

## Why the gates could not have caught either

Both times the unit suite was green and each piece was individually correct. What was wrong was the
**composition**: a bounded reader that is right, meeting an HTTP layer that only notices failures; an
error sentinel that is right, crossing a package boundary that deliberately cannot see it.

**Fixtures prove the logic. Hardware proves the joins.** That is the entry's one transferable
sentence, and it cost two defects in merged code to earn.

## The corpus is a better test author than I am

Asking the real backup for awkward inputs beat inventing them, three times:

- **1,264 domains** on one device, 1,205 of them `AppDomain-*`, one holding 90% of the files. That
  killed a domain-picker design I had proposed: a 1,264-entry dropdown is a search problem wearing a
  control's clothes.
- **~110 files per version disagree with their own index**, in both directions, and the same file by
  the same amount across a month of versions — a property of iOS backups, not a transfer accident.
- **A Cyrillic filename arrived DECOMPOSED** — base letter plus U+0306 combining breve. The
  `Content-Disposition` encoder survives it because it works on bytes, which is correct for RFC 5987
  and would have been correct *by accident* if nobody had looked. A synthetic fixture would have used
  the precomposed form.

## Three smaller things worth keeping

**A stale read is not one mistake, it is a habit.** Three today: an issue's status repeated for 80
minutes after it closed, a canon claim about `latest/` on zfs taken from a document corrected that
morning, and the httptest generalisation above. Each was a fact established once and carried into a
context where it no longer held.

**TypeScript merges same-named interfaces rather than rejecting them.** A duplicated `Session`
compiled clean and would have kept compiling until the two copies drifted, at which point every
consumer silently gets the union of both field sets.

**An armed auto-merge on a `BEHIND` branch is a deadlock, and clearing it by hand is a race you can
lose.** Four times on one PR in an hour, with four unrelated merges landing meanwhile. `forge-watch`
already reports the `BEHIND`; what it cannot say is that nothing will advance it.
