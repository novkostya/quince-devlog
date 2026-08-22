# 2026-08-22 — The privacy gate passed a real leak, and it was right to

**A test fixture carried a device name copied from a photograph of the Operator's real stand — a
household member's given name joined to a device type. `make privacy-check` swept the branch clean,
with a proven matcher and a correct pattern list. The gate was not broken. It answers *"is this a
string somebody has already recorded as private"*, and nobody records a name until after it has
leaked. The only thing between that value and `main` was a reviewer noticing that one fixture did
not look like its neighbours.**

## What happened

quince#1473 (`qn.13` slice 8e) added a test that mounts a device page and asserts which controls a
device-scoped holder sees. It seeded a device fixture. Every identifier in the file read as
invented — a synthetic udid, placeholder credential ids — except the device `name`, which had the
shape of a real household device.

The reviewer ran `make privacy-check REF=origin/main...HEAD` against the real pattern list — 14
case-insensitive + 1 case-sensitive at the time, canary ok, exit 0. **Clean.** `git grep` found the
string nowhere on `main`, so it was new rather than an established fixture whose provenance was
already settled.

Changes were requested on the basis that **neither the reviewer nor the gate could establish whether
it was invented**, which is a different finding from *this is a leak*. The author confirmed it was
real, and where it came from.

## Why the amend mattered more than the rename

The fix was required as an **amend, not a follow-up commit**. `CLAUDE.md` §6 merges with `--rebase`,
so the original commit lands on `main` carrying whatever it carried; a later "use an invented name"
commit would have left the first value in history permanently — the state canon calls an incident
requiring a rewrite.

Verified after the amend: one commit on the branch, and `git log -S` over `origin/main..HEAD` found
the original value in **no commit**. It reached `main` in no form.

## The generalisation the author wrote, which is better than the one asked for

The review asked for the sibling library's one-liner — *every identifier in this file is invented*.
The author wrote the **reason**:

> `privacy-check` answers *"is this a string somebody has already recorded as private"*; it cannot
> answer *"is this a real person"*, so a clean sweep is no evidence at all for a name nobody has
> flagged yet. The reviewer has to establish provenance by reading, and a file that does not state
> it costs them a sweep every time.

That generalises past the file, and it is the sentence someone adding a fixture elsewhere needs.

## The second half: the reviewer's own list was stale, and the banner said so

The pattern list gained an entry afterwards — the household name, added to the private layer so the
gate would catch a recurrence. Later the same day, verifying a count for quince#1481, the reviewer
found its own private-layer clone was **two commits behind**:

```
first read   pattern source 3c599b9 2026-08-20   lists 14 + 1
after fetch  pattern source e98ad12 2026-08-22   lists 15 + 1
```

So sweeps ran against 15 patterns after the list had grown to 16. **The gate had said so on every
run**, in a line printed above every result:

> *not behind as of this box's LAST FETCH, which may itself be old — this is not a live check*

Read roughly twenty-five times that session and treated as decoration each time. `preflight` asserts
the clone **can** fetch, deliberately not that it **has** (quince#675); the banner is the only thing
that reports the difference, and it only works if somebody acts on it.

## What this says about the control

Three properties, worth separating because they are usually collapsed:

- **The gate cannot find a first-instance leak.** Its list is a record of past ones. This is
  structural, not a gap to close.
- **A clean sweep is evidence about the list, not about the branch** — and the list has a commit
  date the reader can compare against the merge date, which is why quince#281 made
  `pattern source <commit> <date>` print at all.
- **The floor that guards the list against shrinking was sized for a list two-thirds its length** —
  `patterns.floor` read `9` against 16 usable patterns (quince#1481). Raising it buys a larger
  shrink guard and nothing against a same-count rewrite.

## What actually caught it

A reviewer reading a fixture and noticing that one value did not match its neighbours in character.
There is no tool for that, and this entry exists so nobody reads the clean exit code as the reason
nothing leaked.

**Refs:** quince#1473, quince#1481, quince#675, quince#281.
