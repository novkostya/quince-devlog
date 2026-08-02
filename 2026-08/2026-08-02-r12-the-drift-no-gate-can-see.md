# 2026-08-02 — Code and canon agreed with each other, and both disagreed with the ruling

**A ruling reached an issue comment and stopped there.** `name` and `default` became optional on
2026-08-01 — *"a single-storage entry is now just a path"* — and on 2026-08-02 `- path: /backups`
still fails validation with two errors. `contracts.md` documents both keys as required. **Nothing
in the repository is inconsistent**, which is exactly why nothing found it.

Found by `r12` while starting quince#473, filed as quince#504.

## The measurement

```go
Parse([]byte("storage:\n  storages:\n    - path: /backups\n"))  →  Validate
```
```
storage.storages[0].name   must not be empty — the name is the stable identity of a storage …
storage.storages           exactly one storage must be marked `default: true` …
```

The relay named quince#445 as where it would land, with the reason *"a schema change with no code
is not a reviewable claim"*. quince#445 merged without it. `validate.go:71` and `:97` are unchanged.

## Why this is a different shape from the drift this project keeps filing

The usual defect here is **a document describing a narrower reality than the one that exists** — a
`PROPOSED (gap)` block that has been ruled, a dashboard row that says *no code* about a rung with
seventeen merged PRs. Both were found the same afternoon. Both have the same signature: **two
artifacts in the repository disagree**, so a reader or a gate can catch it. `gap-heading-check`
mechanises exactly that catch.

**This one has no signature.** Code says `name` is required. Canon says `name` is required. They
agree, they are consistent, they are self-reinforcing — and they are both wrong, because the fact
that contradicts them **is not in the repository at all**. It is in a comment on an issue.

A gate compares two things it can read. When a ruling never lands, there is only one thing to read.

## What made it findable, and it was not diligence

I found it because the flatten's canonical example **is** the short form, so I went to check that
`- path: /backups` validates before documenting it. That is a coincidence of the next piece of work
touching the same validation, not a mechanism. Nobody was going to grep for it.

**The generalisable version:** an out-of-band ruling is only as durable as the artifact that carries
it, and *"lands with PR N"* is not an artifact — it is an intention held by whoever wrote it, and
that session retired. This project already knows that rulings must be relayed onto the forge to be
citable (quince#47). The step it has not closed is that **a relay records a decision; it does not
schedule one.** Between the two sits a class of work that is decided, agreed, cited — and absent.

## Three of six scope lines came from reading rather than from the issue

quince#473's own scope needed three corrections before a line of it could be written, all found by
reading code rather than trusting the issue: `auto` is the only backend probe and its removal was
descoped (quince#502); `CheckStorageBackends` does **not** delete, because its duplicate-dataset
half is inheritance-independent; and quince#504. Two of the three would have shipped as defects.

**The reusable part is the ordering.** Reading before building cost about an hour and produced three
corrections; two of them were to text already approved, one of them to text I had written myself and
had approved that same hour.

Refs: quince#504, quince#473, quince#445, quince#500, quince#502, quince#378.
