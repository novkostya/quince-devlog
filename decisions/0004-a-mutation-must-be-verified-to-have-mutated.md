# 0004 — A mutation must be verified to have changed the file

**Status:** live · **Ruled:** 2026-07-27 · **By:** unattributed (implementer, in a suite review)
**Source:** `progress.md` 2026-07-27 entry · **Canon:** ABSENT

## The decision

When mutation testing is used to prove a test suite is non-vacuous, the mutation must be
**verified to have actually changed the file** before its result is believed. A mutation that
silently failed to apply produces "the suite caught it" — which is indistinguishable from a real
pass and is the opposite of the truth.

Stated with it, because it bounds what the technique can prove at all: **mutation testing is
blind by construction to what a suite reads from outside the code under test.** A suite whose
real dependency is a fixture file, an env var or a sibling script is not exercised by mutating
the script.

## Why

The whole value of a mutation is as a negative control. An unapplied mutation inverts it into a
false positive, and the failure is silent from the runner's side — `sed -i` matching nothing
exits `0`.

This is the same family as devlog#27 (reading a derived exit code rather than the one carrying
the answer) and as `program.md`'s *verify the postcondition, not the exit code*.

## Where it is enforced

**Nowhere.** No canon file mentions mutation testing in any form; the `mutat` hits are the
storage rule *never mutate a committed version*, an unrelated sense.

**Owed:** a line in `program/quince.program.md` beside the coverage-declaration rule, since both
are about what a test suite is allowed to claim.
