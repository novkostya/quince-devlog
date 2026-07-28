# 0005 — `preflight` runs the gate's own validator rather than re-implementing the predicate

**Status:** live · **Ruled:** 2026-07-27 · **By:** unattributed (review-driven)
**Source:** `progress.md` 2026-07-27 entry · **Canon:** ABSENT

## The decision

Where `preflight` must decide whether the privacy gate is usable, it **invokes the gate's own
validator and takes its exit code** (`-ne 2`) rather than re-implementing the predicate.

## Why

**Two implementations of one predicate is how the two answers diverge.** A box would then have a
`preflight` that says the layer is fine and a gate that refuses to sweep — or, worse, the
reverse: a `preflight` that blocks a healthy box.

The generalisable form is that a predicate with two authors has no owner. Related in spirit to
the refusal to add a Makefile to `quince-devlog`, which would have been *"a second place for the
invocation to drift from the tool"*.

## Where it is enforced

**Nowhere as a rule.** Canon describes what `preflight` does (asserts the private layer is
reachable) and openly flags the known weakness that *reach is presence, not freshness*
(quince#121) — but states no requirement about how the predicate is computed.

**One tension worth naming rather than smoothing:** `CLAUDE.md` advises *"read the gate's own
banner rather than its exit code"*, which is the opposite instruction for a *human* reader. Both
are right — a program consuming a documented three-code contract should take the code; a session
claiming a sweep happened must read the coverage line. Whoever closes this gap should write both,
because the pair looks like a contradiction until the reader is distinguished.

**Owed:** a line in `program/quince.program.md`.
