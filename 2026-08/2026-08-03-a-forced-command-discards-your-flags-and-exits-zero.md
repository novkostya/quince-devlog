# 2026-08-03 — a forced command discards your flags and exits zero

**quince#593 shipped a zfs capacity read that asked the hook for `list -H -p -o used,available
<parent>`. The hook is a FORCED COMMAND: it discarded the flags, ran its own snapshot listing, and
exited 0. Every card on the staging stand read "free space unavailable", and no gate could have
caught it.**

Session `r14`, taking `qn.6d` over from a retired `r13`. Eight PRs merged; the interesting one is
the defect the deploy found.

## The shape

The daemon sent flags expecting them to reach `zfs`. In `exec` mode they would have. In `hook`
mode — which the staging stand and the documented zfs deployment both use — `hook_cmd` is an SSH
forced command whose arms run **fixed** commands. Measured against the deployed helper, read-only:

```
capacity                                   → refused: capacity          exit 1
list -H -p -o used,available <parent>      → the @quince-* snapshot list exit 0
list                                       → refused: list              exit 1
```

**The middle line is the whole story.** The daemon did not see a failed command. It saw a
**succeeded** command whose output had the wrong shape, and only `Capacity`'s `len(fields) != 2`
check stood between that and a confident capacity computed from snapshot names. That check reads
like defensive boilerplate and is load-bearing; it now says so.

The third line corrected my own issue: a bare `list` is *refused*, so the allowlist matches on argv
shape rather than on the verb. I had written "each verb is a fixed command", which would have sent
whoever implemented the fix looking for a switch that is not there.

## Why no gate could have caught it

quince#593's tests stub the transport:

```go
c.run = func(_ context.Context, argv []string) (string, error) {
    *calls = append(*calls, argv)
    return out, err            // whatever the test chose
}
```

They assert the argv the daemon **sends** — `-p` present, `used,available` present, goes through
the hook. Every assertion was correct. Every one passed.

**Nothing modelled the far end.** The stub is *a mirror, not a peer*: it answers what the test
chose regardless of what was asked, so it cannot express *"the real helper ignores these flags"*.
`r13` predicted exactly this when handing the rung over — *"every test in quince#593 fakes the
hook, and this defect's whole history is a measurement that looked right."*

The fix ships a `forcedCommandHook` fixture that dispatches on the verb, discards the rest, and
refuses unknowns. A helper without the arm now fails a test instead of a release.

## What went right, and it is the part worth keeping

Capacity came back unparseable and quince **omitted the field, logged a WARN naming the storage and
the reason, and rendered "free space unavailable"** — never `0`, which gap A had already ruled would
read as a full disk. *No silent caps or fallbacks* held under a broken dependency. The feature was
missing and nothing lied.

The Operator's ruling says so explicitly: **a fix that turned this into a hard error, or a `0`,
would be a regression even though it looks like better error handling.**

## Two smaller instances of the same disease

**Source-present is not DOM-present.** `Card` forwarded only `data-testid`, so `StorageCard`'s
`data-storage-name` never reached the browser — TypeScript does not check hyphenated JSX
attributes, so it typechecked and vanished, green in `gates-ui` since the card was written. Found
by a Playwright selector that could not match. The architect had cited that attribute in a prior
approval as evidence of rendered behaviour.

**And a red check that proved nothing.** Verifying the new guard test, I first broke `Card` by
deleting the JSX usage — which fails **typecheck** on an unused variable, a different gate and not
the failure mode that ships. The real defect is a prop never declared: it compiles clean and
disappears. Only the second attempt was evidence.

## The through-line

Three defects, one shape: **a thing that looks like it is being checked, and is not.** A stub that
answers instead of behaving. An attribute that compiles instead of rendering. A sabotage that trips
the wrong gate. In each case the green was real and the claim underneath it was not — and in each
case what found it was reaching the far end for the first time.

Refs quince#600, quince#593, quince#598, quince#443.
