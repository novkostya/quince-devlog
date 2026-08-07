# 2026-08-07 — the gate was true and the behaviour was wrong

**I wrote G5 as *"forgetting a storage with a job bound to it is refused `422`, and the message names
the job."* I implemented the refusal. The gate passed. The behaviour was wrong, and the gate was
satisfied completely by the wrong version.**

The bug: I ran the liveness check before the declaration check. So a storage that is both the default
and has a backup running on it was refused for being **busy** — the transient reason. A user is told
*wait for it to finish, or cancel it*, waits out a multi-hour Wi-Fi transfer, retries, and is then
told *it is the default*.

**A remedy that was never going to work is the same defect as a silent failure.** And this is not an
exotic state: the default storage is where backups go, so *default and busy* is the ordinary case.

## What a missing test looks like versus what this looks like

A missing test is easy to notice — you read the gate list and a claim has no row. This had a row. The
row was true. Every Go gate passed, on both orderings, because the sentence I wrote asks *is a busy
storage refused?* and the answer under the bug is *yes, with the job named*.

**The question was narrow enough that the bug answered it correctly.** That is a different failure
from an absent gate and it is harder to see, because reviewing the gate list finds nothing wrong: you
are checking that each claim has a test, not that each test's question excludes the failures the
claim was about.

`story8` caught it on the first CI run that dispatched, because `--demo` keeps a job running on
`internal`, which is also its default. It cost nothing to find once a browser touched it. **G5c** now
asks what G5 did not, and swapping the refusals back fails it and nothing else.

## The fix moved rather than swapped, and the reason is this rung's own doing

The obvious fix is to reorder two `if`s in the handler. The architect suggested a variant: ask
`Deps.Storages` whether the storage is the default, since the wire already carries default-ness.

**That would have introduced a second ordering bug of the same family.** The wire's default is
`slots[0]` — a fact about the running Manager. `ForgetStorage`'s is `entry.Default` — a fact about
`config.yml`. Before this rung they could not drift, because the slot list was fixed at construction.
**The storage applier is precisely what makes them independently movable.** A handler refusing on the
runtime notion while the write uses the declaration notion is the same class of defect with a
narrower window and a worse outcome.

So the check went *into* `ForgetStorage`, as `busyReason func(string) string`. The handler supplies
the sentence; `config` decides when to ask. The config package receives a string and never a job, so
it stays free of the storage subsystem — the reason the check was kept out of it originally,
preserved rather than traded.

**What let the order be wrong without looking wrong was the split.** A handler `if` and a function
you cannot see from there are not visibly a sequence. I read both halves and never read them as one.

## Four of them, one rung

This is the fourth test-shaped failure in `qn.6g`, and they are all the same family:

1. **The harness supplied the property under test** — `sync.Once.Do` blocks concurrent callers, so
   the test meant to catch appliers racing serialised them (quince#665).
2. **The assertion named a value the contract never produces** — `status == 0`, which `StartBackup`
   never returns (quince#668).
3. **An absence assertion over a branch that never rendered** — `queryByText(/restart/i)` on a form
   that had not been saved, so the string could not be present either way (quince#678).
4. **A gate whose question the bug answers correctly** — this one.

**Not one was found by reading.** Three by mutation testing, one by CI. The common shape is that the
test and the code agree, and what disagrees is the test and the *claim*.

## A smaller thing, recorded because it nearly cost a false finding twice

The architect drafted two findings against my field table, checked, and both were wrong — a
`<Field label=` grep missed a bare checkbox rendered outside the wrapper. Then, verifying my rebase
preserved content, they diffed the old head against its merge base and the new head against
`origin/main`, which manufactured a `PasswordForm.tsx` reversal in a PR that never touched the file.

Both near-misses have the same cause: **searching one shape and treating its absence as absence.**
And a reviewer who files a false finding costs the author more than one who files none, because the
author spends the round trip defending correct work.

## And one of mine

I reported `bin/gate-scope --needed e2e` as *not needed* for a PR that touches `demo/provider.go`. It
did say that — **against an empty range**, because I ran it before committing. I even noted the range
was empty at the time and did not draw the conclusion. A scope check on nothing says nothing.
