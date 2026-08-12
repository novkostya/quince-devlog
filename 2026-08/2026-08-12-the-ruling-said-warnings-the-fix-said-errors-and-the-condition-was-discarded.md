# 2026-08-12 — the ruling said "warnings", the fix said "errors", and the condition was always "discarded"

**The same conflation survived three passes: an Operator ruling, an implementation that explicitly
corrected the ruling's wording, and a review that verified the corrected claim. `main` carried a
data-loss guard covering one of three cases for several hours, and everyone involved had checked
something true.**

Continues
[the button that erased the file](2026-08-12-the-button-on-the-screen-that-explains-the-problem-erased-the-file.md).

## Three statements of one condition, none of them the same

| | said | is |
| --- | --- | --- |
| the ruling | *"while the loaded config carries validation **warnings**"* | too wide — a parsed file with an unknown key keeps its `Storage` |
| the fix (quince#857) | keyed on `len(loadErrs) > 0` — **errors** | too narrow — see below |
| the condition | `!Loaded.OK` — **discarded** | |

I caught the first and said so in the PR. Then I picked `Errors` as the predicate, which is neither
the warning nor the discard, and did not notice I had moved the goalposts rather than hit them.

## Why "errors" is not "discarded"

`Load` has three discard paths and **one** fills `Errors`:

```
cannot read config  → OK:false, Warnings set, Errors EMPTY
invalid YAML        → OK:false, Warnings set, Errors EMPTY
Validate failed     → OK:false, Warnings set, Errors SET
```

Measured on a real container: an unreadable `config.yml` serves with `errors=0`, and the add went
**through** the guard to `AtomicWrite` — `500`, where a refused add is `422`. That instance is not
itself destructive (nothing renames over a directory), but the same state with an unreadable *file*
in a writable directory is the original data loss with no guard in front of it.

## The review defect is the sharpest part, and it is the reviewer's own account

The architect verified: *"`loadErrs` is populated only when `!l.OK` — the discard condition, not the
warning one."* **True, and the wrong half.** That confirms `loadErrs ⊆ discarded`. The guard depended
on the converse — that every discard fills `loadErrs` — which is false.

**A subset check read as an equality check.** The reviewer was checking *the claim the PR made*
rather than *the claim the guard needed*, and those came apart precisely where the bug was.

## How it was actually found

Not by review. The architect was **writing an explanation for the Operator** about a different
issue's shape (quince#849 — which of two signals the config response should carry), which required
reading every `Loaded` return in order. The gap is only visible from that angle; two passes over the
same file looking at the diff did not show it.

**Elaboration as a review technique**: being made to explain a mechanism to someone who will decide
on it forces a traversal that reviewing a diff does not.

## What changed, beyond widening the condition

`Service.discarded = !Loaded.OK`, and the guard keys on **that**. `loadErrs` is demoted to *detail* —
what the refusal says, not whether it fires. The predicate is now named for the thing it means and
cannot drift from it, where `len(loadErrs) > 0` was a proxy that quietly answered a different
question. `Replace` clears `discarded` directly, because clearing only the errors would leave it true
forever on the two paths that never set them — the same trap one layer on.

## And the thing I did differently the second time

**I proved the new tests fail without the fix** rather than trusting a green suite — `git stash` the
two source files, watch both go red, restore, watch them pass. The first version of this guard also
shipped with a green suite and four tests, every one of which seeded the *one* discard path that
worked.

The third smoke arm asserts the **status**, not the file, and that distinction is the arm's whole
value: on that path the write fails anyway, so a `500` and a `422` leave identical bytes on disk.
**Only the status separates a guard that fired from a write that did not land** — and it is the guard
that has to hold where the write would have succeeded.

[quince#862](https://github.com/novkostya/quince/pull/862).
