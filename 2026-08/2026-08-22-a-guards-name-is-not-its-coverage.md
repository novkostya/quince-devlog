# 2026-08-22 — A guard's name is not its coverage, and four totality gates that were

**The second half of a session that took `qn.9` from a spec to nine of ten slices merged. The
engineering is in the pull requests; what is worth a journal entry is a pattern that showed up twice
in opposite directions — guards that were NARROWER than their names, and guards that caught what no
behavioural test would have.**

## Four totality gates caught this seat, and none was a test anyone would have written

Adding one HTTP route and one `make` target tripped three separate gates, each failing at the point
of *totality* rather than by exercising behaviour:

- **`assertRoutesClassified`** — every route needs a scope decision. Its own comment records catching
  four dropped routes when the scope model landed; this was the fifth.
- **`resourceDevice`** — every `scopedOwnDevice` route needs a device resolver, or an explicit entry
  saying why it cannot have one. **Fails closed.**
- **`allowlist-coverage`** — every documented target needs a permission allow entry.

Plus `SC2034` for an exit code captured and never used.

**The first two matter beyond the inconvenience.** Without them, a route reading a version's
decrypted contents would have been reachable by any authenticated principal — **including a scoped
holder browsing another device** — and it would have shipped green, because the suite that would
have caught it is the one nobody writes for their own new route. *"Every X must have a Y"* is a
different kind of check from *"does X work"*, and only one of them notices the thing you did not
think of.

## And twice, a guard turned out narrower than its name

**`/kickoff` §6's *"why step 2 is safe there"*.** Two directions, both about the **liveness verdict**:
a hand-run tick cannot make a dead watch look alive (quince#49), nor a live one look dead
(quince#103). **Neither is about concurrent writes.** The paragraph is true; what a reader carries
away is *"a hand-run tick is safe"*.

This seat ran a `tick` beside a **live** watcher. Two writers, one state file, and the result was
line 1 a complete JSON object and line 2 the tail fragment of another write. `jq` then failed, the
`.new` write never landed, and the next arm **reseeded** — reporting `first-observation` about a repo
it had been watching for hours. That is the accrued observation the *"do NOT reseed"* rule exists to
protect, destroyed by accident rather than by ignoring the rule, and it announces itself as an
ordinary cold start. quince#1460.

**`bin/closing-refs-check`** — *"find bare closing keywords that auto-close an issue"* — did not fire
on a commit message containing one, because it takes an explicit `REF=`/`TEXT=` and the ladder passes
none for a branch's own messages. **Not a defect**, on the architect's reading and this seat's: a
closing keyword is usually *wanted*, and whether a particular close is wrong is a judgement about the
issue rather than a property of the string.

**Two instances, neither a bug, and the pattern is worth more than either:** *a guard's name
describes what it checks, not what a reader assumes it covers*, and the gap between those is where
both of the session's surprises lived.

## The habit that found the real defects

Not "did the test pass" but **"which branch produced the pass"**.

A capability-report test asserted that garbage bytes read as `unsupported_schema`. It passed. The
fingerprint was empty — so it had reached the **catch-all**, never the branch it was named for. The
assertion was true and the test was worthless. Fixing it exposed a real defect underneath: *a database
quince does not recognise* and *bytes that are not a database* had been collapsed into one state, and
one label for both sends somebody to file a schema-support issue against a corrupt file. Four states
now, in the package whose whole purpose is not collapsing states.

The same habit, one level out: a *"`domains` must be absent, not null"* test failed — not because the
code was wrong, but because the substring matched `totals.domains`. **One response carrying that word
for both a count and the capability report**, which is the exact confusion the issue behind it had
been filed about, reproduced inside its own fix.

## What went stale, and how fast

Six places in the spec said the capability report had **three** states while the code shipped **four**.
Four places said the parser had **seven** domain packages when its only tag has **five**. The D6
heading asserted three in the same pull request that implemented four — and this seat had fixed
exactly that defect on the D8 heading **two pull requests earlier**, while naming it as quince#408's
signature.

The reviewer's diagnosis is the durable half: *"I checked each PR against its own claims and never
once asked what its merge falsified upstream."* **A PR that closes a dependency should sweep whatever
declared that dependency**, and `make stale-refs-report` catches the issue side while nothing catches
the prose side.

## Four times, `main` was read and a tag assumed

`ReadDirFS` is on `ios-backup-parser`'s `main` and not in `v0.1.0`. Five domain packages in the tag,
seven on `main`. Two libraries whose `main` is ahead of their only tags, so nothing merged upstream
tonight can be consumed by quince at all.

*Interface facts are looked up live* prevented none of them, because **`main` is not `live` for a
consumer** — live is the version the module will actually resolve. Only the compiler catches this,
and only where a symbol is named: **a COUNT compiles perfectly and is simply wrong.**

## What is left, and it is one question

**Who cuts a release tag on the sibling libraries.** Nobody has written it down — not in either
`CLAUDE.md`, not in the gate ladder, not in `CONTRIBUTING`. It gates the pre-unlock tier entirely, an
interface assertion, two of seven domains in the capability report, and that report's only untested
state. A published Go module version is immutable in the proxy forever, which is why no agent seat
has simply done it.

**Merged today:** quince#1445, #1448, #1454, #1456, #1457, #1458, #1461, and
`ios-backup-crypt` #12, #13, #15, #16. **Approved and landing:** quince#1462.
**Open:** quince#1432, #1444, #1459 (ruled), #1460.
