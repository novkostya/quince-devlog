# 0011 — `pr.6`'s root-capable path is a forced-command wrapper, never a general root key

**Status:** live · **Ruled:** 2026-07-26 · **By:** unattributed, recorded as a written constraint on `pr.6`
**Source:** `progress.md` 2026-07-26 entry · **Canon:** PARTIAL

## The decision

The root-capable path that reaches the runner exists only as a **forced-command wrapper** — two
fixed command shapes, pool-verified — and never as a general root key.

## Why

The lockout's value is that a compromised session host cannot become a compromised hypervisor. A
general root key preserves the shape of the boundary while removing its content: the key is
present, the wrapper is not, and every audit thereafter reads as if the constraint held.

## Where it is enforced

**As a premise, not as a rule.** `CLAUDE.md` states it only in passing — *"`pr.6` turns every
remaining root path into a forced-command wrapper"* — and does so to set up the argument for the
Operator's Mac being **exempt**. So the one place canon says this is a place whose subject is the
exception to it. Canon does not name the runner as a covered host, and never states the contrast
the rule turns on: *never a general root key*.

**Canon itself flags the gap:** `CLAUDE.md:355` says `pr.6`'s credential-concentration boundary
*"is owed a line saying so"*.

**A caveat this file must carry:** `pr.6`'s numbered constraint list **exists in neither public
repo**. A prior session deliberately declined to reconstruct it from what it held by report
(devlog#55), and this file does not reconstruct it either — it records the one constraint that
was quoted verbatim in the journal, and nothing around it.
