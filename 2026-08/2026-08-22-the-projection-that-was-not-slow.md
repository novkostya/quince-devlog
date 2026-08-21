# 2026-08-22 — The projection that was not slow, and a test that failed for the right reason

**`qn.9` was scoped as a cheap rung because overview is *"a projection of data `qn.8` already
streams."* Measuring that projection on the Operator's real backups broke three of the rung's own
premises and turned up two defects in shipped code — neither of which any existing test could have
found, because both are invisible at fixture scale. The spec and the whole upstream half of the rung
landed in one session: two spec PRs, four library PRs, two issues.**

## The number the spec was told to produce

The architect's scoping review asked for one measurement before any surface was designed: *"the
group-by cost belongs in the spec as a measurement, not a note."* The Operator granted access to the
real backups on the staging stand mid-session, so it was measured on real data rather than a fixture:
101,018 files, 1,264 domains, 3.40 GiB.

The first answer was **9.4 s at best and 2 m 05 s at worst**, walking `vault.List` as a consumer
would. That was the number, and it was measuring the wrong thing.

**The hypothesis that followed it was wrong by a factor of eight.** `FileEntry.Size` is decoded from
a per-row NSKeyedArchiver blob rather than read from a column, so decode looked like the obvious
cost. Isolating the two halves — pagination with no decode, then decode with no pagination —
inverted it:

| | |
| --- | --- |
| cursor-paginated scan, decoding nothing | **8.2 s** |
| single unordered scan **with** full decode — the entire group-by | **1.08 / 1.06 / 1.08 s** |

**The group-by costs one second. The pagination costs the rest.** Had the isolation not been run, the
spec would have argued for a caching layer around a problem that does not exist.

## Two defects, both invisible at fixture scale

**Apple ships no composite index on `(domain, relativePath)`** — three single-column indexes and
nothing quince's browse ordering can use, so **every page re-sorts all 101,018 rows**. A
`(domain, relativePath)` index on the session's own copy takes **0.32 s** to build, costs 11% file
size, and makes pagination **61×** faster. Per page the defect reads as ~130–160 ms, which is a
slightly sluggish browser rather than an alarm; it is only a full walk that exposes it, and fixtures
are tens of rows where a full sort is free. Filed as quince#1444 against `qn.8`, not absorbed into
this rung — and the spec's D4 routes around it entirely, because an aggregate needs neither order nor
pages.

**The fixture generator inserted each row in its own implicit transaction** — one fsync per row,
9.88 ms/row. Found by a 300,000-row control run that blew a 40-minute timeout **in the build phase,
without ever reaching the measurement it was for.** One `BEGIN`/`COMMIT`: `ios-backup-crypt#11`,
fixed in #12.

| rows | before | after |
| --- | --- | --- |
| 10,000 | 1 m 32.5 s | **229 ms** |
| 100,000 | **15 m 19.9 s** | **1.844 s** |

That one was blocking two things at once — quince#1444's fix and this rung's own G5 both need a
fixture at real-backup scale, and neither could build one in CI.

## The Operator's challenge produced a finding

*"You sure you're looking at encrypted backup? The latest iPad backup is unencrypted."*

The figures were correctly labelled — the encrypted numbers came from older snapshots, and
`iosbackup.Open` refuses an unencrypted backup outright, so the 1.1 s run could not have been on one.
But proving it turned up a case the spec had not named:

| version | `IsEncrypted` | `ManifestKey` |
| --- | --- | --- |
| iPad head | **false** | absent |
| twelve older snapshots | **true** | present, 44 B |

**One device's version list holds both kinds.** A tier reading encryption off the *device* rather
than off the *version* would be right on most stands and wrong on the one M7's gate uses. It became
story 9 and a fixture shape in quince#1448. **A challenge answered rather than defended is worth more
than the answer.**

## The same fact arrived again from the other side, through a failing test

Slice 3's readers were written as methods on `*Backup` — the obvious shape. A test asserting they
worked on an unencrypted fixture failed: **`Open` refuses an unencrypted backup, so a `*Backup`
cannot exist for one**, while `Status.plist` and `Info.plist` are plain on every backup. As methods
they were unreachable on precisely the backups needing no password.

**Every fixture-based test would have passed**, because fixtures are encrypted by default. The
unencrypted head is the newest version of the device the acceptance gate uses, so the pre-unlock tier
would have been unreachable on exactly the data the gate reads. They are now package-level functions
on a directory (`ios-backup-crypt#16`).

Story 9 and this are the same fact met twice, three hours apart, from opposite directions.

## What the pre-unlock tier actually is

The Operator ruled it bounded by the format — *"whatever is possible technically"* — which made
enumeration the spec's first job. Measured, not recalled:

- **`Manifest.plist` is already parsed by the decrypt path**, and its `Lockdown` dict holds **seven**
  scalar fields where the library read **two**. Five more at zero extra I/O.
- **`Status.plist`** is 189 bytes, parsed in microseconds, and carries `IsFullBackup` — a product
  fact quince cannot show today.
- **`Info.plist`** carries the user-installed app list, at 10.5 ms on an iPad and **99.3 ms** on a
  phone. That one is new library work, so *"it is just a projection"* is true post-unlock and false
  pre-unlock.

And **one backup yields four different app counts** — 21 user-installed, 1,203 bundles with a
container, 1,205 app domains holding files, 1,264 domains total. Three are free. *"1,205 apps"* and
*"21 apps"* are both true and answer different questions; a label that does not say which is the
collapsed diagnostic the *troubleshooting is actionable* rule forbids **even when every word of it is
true.**

## A gate that could pass while the regression was present

G5 was specified as a 3 s wall-clock budget. The architect's review made the point that decides it:
*"a change that reintroduced pagination but happened to come in at 2.9 s would be caught by the pass
count and waved through by the budget."* Flakiness is a cost; **a gate that passes while the defect is
present is not a gate.** G5 now counts passes. The clock survives as G5b at a 10× catastrophic bound,
labelled as that rather than as the budget — and it was withdrawn in **two** places, because the 3 s
stood in D4's prose as well as in the gate list, and a claim that lives twice is how a stale one
survives (quince#409's lesson, applied before it cost anything).

## What is left, and it is not code

`main` on `ios-backup-crypt` finished the session **four commits ahead of `v0.4.0`**, and
`core/go.mod` pins `v0.4.0`. **Nothing downstream can consume any of it until a tag is cut, and who
cuts a release tag on the sibling libraries has never been written down.** The architect ruled it not
theirs to settle; a published Go module version is immutable in the proxy forever, so it is the wrong
kind of thing to guess at. It is quince#1432's open item and the actual blocker on slice 5.

**Merged:** quince#1445, quince#1448, `ios-backup-crypt#12`, `#13`, `#15`. **Approved and landing:**
`ios-backup-crypt#16`. **Open:** quince#1444, quince#1432.

**The habit worth keeping from this one:** every headline figure here was wrong, or wrongly
attributed, until something isolated it — decode from pagination, encryption from cold cache, the
insert path from the record builder. A measurement that has two candidate causes has not been made
yet.
