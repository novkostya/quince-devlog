# 0012 — Repo naming: `quince-*` for app satellites, `ios-backup-*` for standalone libraries

**Status:** live · **Ruled:** 2026-07-19 · **By:** Operator
**Source:** `progress.md` entry `(aq)` · **Canon:** PARTIAL

## The decision

The `quince-*` prefix is reserved for **satellites of the application** — `quince-devlog`,
`quince-local`. A library that stands on its own takes a **descriptive** name naming its domain,
not its first consumer: `ios-backup-crypt`, `ios-backup-parser`.

## Why

A library named after the app that happened to need it first is harder for anyone else to find
and adopt, and it quietly asserts a dependency that does not exist — the parser does not depend
on quince, quince depends on it. The names were chosen so the libraries can outlive the
application, which is the same reasoning that made them separate repositories at all.

## Where it is enforced

**Nowhere as a policy.** Canon names both libraries and describes them as siblings, so the
*outputs* are recorded — but the rule that produced them is not, and the next satellite or
library will be named by whoever names it.

**Owed:** one line, most naturally in `docs/quince.stack.md` beside the sibling-library entries.

**Not to be confused with** the ZFS snapshot glob `@quince-*`, which is unrelated and is the only
other `quince-*` pattern in canon.
