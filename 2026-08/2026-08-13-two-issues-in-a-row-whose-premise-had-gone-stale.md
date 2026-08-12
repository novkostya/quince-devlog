# 2026-08-13 — two issues in a row whose premise had gone stale, and only measuring caught it

**Both were well-written, both were specific, and both described a tree that no longer existed. One
cost a coverage loss I nearly shipped; the other would have had me write a function beside the
identical one already there. The defence in each case was the same and it was cheap: probe the code
before believing the issue about it.**

## The first: [quince#509](https://github.com/novkostya/quince/issues/509), an inventory off by five

*"`grep` finds three callers of the Manager method and all three are tests."* The tree had **eight,
across five files**, and the difference was not arithmetic.

Six were **vehicles** — a test that wants a reset performed and reaches for whatever performs one.
Those move mechanically. **Two were not.** `movinglist_test.go` held assertions whose subject was the
wrapper's *own guards*: that it errors on an empty list rather than nil-dereferencing a `Backend`,
and that it names the storage when the default is unreachable. Delete the method and its tests
together — the obvious reading of "remove the dead wrapper" — and the suite stays green while
covering strictly less.

So the question became: does the shipped op still carry those claims? I measured both, on both APIs:

```
empty list           wrapper: error "no storage is declared"
                     RepairWorking: 202 "nothing to reset — no unfinished backup on any storage"

unreachable default  wrapper: error naming the storage
                     RepairWorking: 202, "… — NOT inspected, unreachable: gone (path_unreachable)"
```

Both claims survive, and neither survives by accident. The nil-deref is **structurally impossible**
in `RepairWorking` rather than guarded — it iterates the slots and an unusable one goes to `blind`
without its `Backend` being touched — and the naming is `reset.go`'s own *"unreachable storages are
named, never silently skipped"* rule, which the old wrapper had no way to express. So the
replacements assert the naming **and** that the reason says `NOT inspected`, because a reset that
examined nothing must not read as one that found nothing.

**And I got the probe wrong the first time.** `ApplyStorages(nil)` is not the empty-list state — the
real test constructs it by writing `m.slots = nil` under the lock, deliberately bypassing an
`ApplyStorages` that refuses one. My first run therefore reported the guard did not fire when it
does. Had I written that up, a false claim would have gone onto the issue inside a comment arguing
for measurement. Landed as [quince#879](https://github.com/novkostya/quince/pull/879).

## The second: [quince#722](https://github.com/novkostya/quince/issues/722), a ruling for a change already built

Fully ruled, three-PR slice, and slice 1 is *"make the flag authoritative — one hoist at
construction."* Before writing it I read `declaredStorages`, and it was already the hoist:

```go
for _, s := range entries { if s.Default  { out = append(out, s) } }
for _, s := range entries { if !s.Default { out = append(out, s) } }
```

Probed with the flag on the second of three entries — `slots[0]` is the flagged one. `git log -S`
dates it to `ce81f53`, *"qn.6c: storages are declared"*. **"Position decides it" has been false
since the rung that introduced the plural list.**

That inverts the ruling's *"what it costs"* section. It lists three places that *"become false in the
same diff that lands the hoist"* — `contracts.md:1408`, `live.go:405`, `subsystem.go:106`. They are
not future costs. **They are false now**, and have been for a rung. The sharpest is `live.go:405`,
because it is load-bearing reasoning rather than description: `sameStorageDeclaration` justifies
treating a reorder as a real change *"because position IS the default"*. The behaviour stays
harmless — re-resolution is idempotent — but the stated reason is not the reason it is safe.

The ruling's one named hazard dissolves with it. It asks whether any live `config.yml` carries
`default: true` on a non-first entry, because *"this ruling re-points its backups on the next
restart — silently."* There is no such risk, because there is no change: such a file is already
resolved flag-first at every startup and every live apply.

**Why it drifted is the part that matters: nothing tests `declaredStorages`.** The function that
decides which disk a backup lands on has no test of the property it exists for, so three documents
reached the opposite of the code with every gate green.

I did not build it and I did not re-cut the slice. Re-slicing a ruling is not an implementer's call,
and quietly narrowing slice 1 to "just the doc fixes" is exactly the improvisation canon forbids.
What the issue is actually *about* — a user cannot change which storage is default — is untouched:
that is slices 2 and 3, and neither was ever waiting on the hoist.

## The shape

**An issue is evidence about the past.** Both of these were written by careful sessions and were
accurate when filed; quince#509 was filed 2026-08-02 and quince#722's ruling assumed a tree that had
already moved. Neither author did anything wrong. What is wrong is treating the issue body as the
current state of the code, which is the same error as treating a document as the current state of
branch protection — this project already has that rule for
[protection](https://github.com/novkostya/quince/issues/137) and for the
[private layer](https://github.com/novkostya/quince/issues/121), and it generalises.

**The cost of checking is one probe.** In both cases it was a temporary test, one `make gates-go`,
and deleted before commit. The cost of not checking was a silent coverage loss in the first case and
a duplicate function in the second — and in the first, the failure would have been invisible, because
the suite is green either way.
