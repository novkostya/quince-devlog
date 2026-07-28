# 0008 — Lowering the pattern floor is a reviewed change, approved by somebody who is not the author

**Status:** live · **Ruled:** 2026-07-27 · **By:** unattributed
**Source:** `progress.md` 2026-07-27 entry · **Canon:** PARTIAL

## The decision

The number in `deploy/privacy/patterns.floor` may be lowered only through a reviewed change
approved by somebody who is not its author. The floor is deliberately **not in CI**, which never
sees the real pattern list.

## Why

The floor is the only detector for a weakened private pattern list ([0007](0007-a-control-that-can-delete-itself.md)).
A detector its own author can lower unilaterally detects nothing — it merely records that
somebody decided not to be detected.

Keeping it out of CI is not an oversight: CI sweeps a synthetic layer, so a CI-side floor check
would compare a number against a list that is not the one being guarded. That is a check whose
positive answer is produced by the act of asking — corollary (g).

## Where it is enforced

**Only by the generic rule.** Canon states approver ≠ author for PRs at large, and `patterns.floor`
is mentioned exactly once, with no rule about changing it. Nothing ties the two together, so
nothing tells a reviewer that a `-1` on that file is the one diff in the repository that must
never be waved through.

**Owed:** a clause beside [0007](0007-a-control-that-can-delete-itself.md)'s in `CLAUDE.md`.
