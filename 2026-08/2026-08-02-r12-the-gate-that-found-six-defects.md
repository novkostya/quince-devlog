# 2026-08-02 — G9 ran, and the rung's own gate found six defects that fixtures never could

**`qn.6c`'s acceptance gate was owed for two days and read like ceremony: back a device up to two
storages, check the second is a full transfer.** It found six real defects before the second
transfer finished, and four of them were invisible to every gate in CI by construction.

## The gate

A real iPad, 3.7 GB, over Wi-Fi, to a **zfs** storage and an **ext4 USB disk whose `hardlink`
backend was PROBED, not declared**. `shuttle` took 94,027 files from an empty root with the
daemon's own marker reading `kind: "full"`; `local` kept 94,027 files and the same five
`@quince-*` snapshots. The retention leg followed: `shuttle` at 0/0/0, `local` at 10/30/12, one
fast zfs backup — and a commit to `local` **deleted a version on `shuttle` under `shuttle`'s
number** while `local` kept all seven under its own.

## What it found, and why CI could not have

| | |
| --- | --- |
| quince#514 | `probeNamespace` hardcoded `/backups` in **five** reason strings. Harmless with one storage; with two it named a *different, healthy disk* two lines above itself in the same log |
| quince#508 | the upgrade refusal said *"no `storage:` key"* to a config that has one — and it **is** the rung's own upgrade path |
| quince#518 | the `hardlink` tier is behaviourally identical to `copy`. Probed, recorded, shown, never used |
| quince#521 | **both Retry buttons sent a JOB id as the storage id**, and then, once fixed, retried onto the *default* instead of the storage they were retrying |
| quince#525 | Settings crashed: the TS `Config` was a schema behind the Go one |
| quince#505 | `story6`'s G8 assertion passes only because `story4`/`story5` run first |

**Three of the six were reported by the Operator looking at a screen**, not by any gate. A fourth
came from a one-line question — *"is it not possible to hardlink-seed?"* — which closed a chain no
test asks about: the seed is the only place a tree is duplicated, hardlink is banned at the seed, so
the tier does nothing.

## The shape worth keeping: green suites over absent cross-checks

Four of these shipped with **every gate green**, and in each case the gate could not have seen it:

- **quince#521** — `story4`'s e2e *exercises Retry*. It passed while Retry was broken, because the
  demo accepted any `storage_id` and ignored it. A demo that accepts what the daemon refuses is not
  a lighter daemon, it is a different one, and every gate driven against it inherits the difference.
- **quince#525** — `make gates-ui` was green. The TS type was **internally consistent** and simply
  described a schema the daemon no longer served. Nothing cross-checks TS against Go — which is
  quince#493, filed *before* this happened and describing it exactly.
- **quince#514** — no test asserts a reason's TEXT against a non-default root.
- **quince#505** — the assertion tests the opposite of what its comment says, and passes on a side
  effect of two earlier specs.

**The common factor is not weak tests. It is a missing comparison** — TS against Go, demo against
daemon, message against the path it names, spec against spec. A suite can only compare what it was
given two of.

## Four corrections to my own claims, all the same shape

Recorded because the rate is the number that says whether two-seat review is working, and it lives
nowhere else.

1. **The G9 scale clause.** The gate says *"tens of gigabytes"*; the run moved 3.7 GB. I wrote a
   five-item *did not prove* list and omitted the one thing the gate says literally — checked
   against what G9 is *for*, with the text open.
2. **The gate-hold claim.** I reported that a 27-minute seed survived. It had **failed 432 ms after
   the seed finished**, and the terminal state was already in the log I had just read.
3. **Its severity.** I then called that failure evidence of a hard iOS limit. The Operator ran
   another and it completed — so it is **intermittent**, which is harder to characterise, not
   easier.
4. **A privacy leak.** I used `gh issue comment --body "…"` with backticks in the prose. **`iostat`
   executed** and its output — a PVE host's device map — was published. I had filed that exact
   defect two hours earlier and written that the lesson was `--body-file`.

**Three were caught by the architect. One was caught by the Operator running a backup**, which is
not a review mechanism — it is luck that the next thing anybody did happened to test my claim.

## And a test that proved a fifth of what it claimed

quince#514's behavioural test **passed with the bug reintroduced.** `probeNamespace` branches on the
filesystem, so a temp dir only ever exercises one of three paths; four of the five instances were
unasserted by a test written to assert them. A source-level check — no path literal in a reason
string — catches all five and names the line.

**The mutation check is what found that, and an earlier mutation run the same hour was a FALSE
KILL**: exit 2, no test run, `"fmt" imported and not used`. Reading the failure line rather than the
exit code is the whole difference, and `r8` recorded six of those in one session.

Refs: quince#378, quince#505, quince#508, quince#514, quince#518, quince#521, quince#525, quince#533, quince#537.
