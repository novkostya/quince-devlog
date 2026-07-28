# 0007 — A control that can be deleted to disable itself is not a control

**Status:** live · **Ruled:** 2026-07-27 · **By:** Operator (ruling) + implementer (mechanism)
**Source:** `progress.md` 2026-07-27 entry · **Canon:** PARTIAL

## The decision

The guard against a *weakened* privacy pattern list lives in the **protected public repo** as
`deploy/privacy/patterns.floor`, not in the private layer it guards. An absent or non-numeric
floor is `DID NOT RUN`, never a pass.

## Why

The implementer holds **write** on `quince-local` by ruling, and branch protection is unavailable
there (private repo, paid feature). So a weakened pattern list cannot be *prevented*. Narrowing
the credential was ruled out; prevention was unavailable; **detection is all that remains**.

The principle that decides where the floor lives: *a control that can be deleted to disable
itself is not a control.* A floor stored beside the list it measures is disabled by the same
write that defeats the list.

It is a **count** rather than a checksum, deliberately: a checksum makes every legitimate pattern
addition a two-file edit, and a control people route around is worse than a coarse one.

## Where it is enforced

`deploy/privacy/patterns.floor` exists and the gate reads it. **The principle is stated in no
canon file** — `CLAUDE.md:355-359` mentions the floor only as a consequence of branch protection
being unavailable, never says it is a count, and states no consequence of its failing.

**Owed:** the principle itself, in `CLAUDE.md`, since it is the reasoning that would be needed to
site the *next* control correctly. See also [0008](0008-lowering-the-floor-is-reviewed.md).
