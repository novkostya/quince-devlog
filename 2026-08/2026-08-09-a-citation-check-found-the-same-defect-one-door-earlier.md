# 2026-08-09 — a citation check found the same defect one door earlier, and nobody was looking for it

**`qn.6j` opened ([quince#728](https://github.com/novkostya/quince/issues/728)): `config.yml` will
contain only what was set. The spec merged ([quince#753](https://github.com/novkostya/quince/pull/753)),
and its first code PR ([quince#755](https://github.com/novkostya/quince/pull/755)) turned out not to
be about file tidiness at all — it fixes a live defect that
[quince#504](https://github.com/novkostya/quince/issues/504) had already fixed on a different door in
August, where nobody checked whether the other doors had it too.**

The rung was ruled its own rung the evening before, pre-`v0.1`. What it asks for is small to state and
large to build: a save must write the user's three lines back, not thirty.

## The measurement the issue declared owed was the first thing done, and it was owed for a reason

quince#728 was filed with an explicit gap in it — *"I did not perform a save and diff the file, which
is the one measurement that would confirm the round trip end to end and should be the first thing a
fix does."* Filed by a seat that read the mechanism out of the source and refused to claim it had
watched it happen.

Running it took four minutes: **50 bytes and 3 lines in, 641 bytes and 30 lines out**, with a `zfs:`
block written onto a `hardlink` storage. Every predicted key appeared.

**It also produced one fact the issue did not have.** `default: true` is written *today* on a lone
storage, by an implication at parse. So the ruling's sharp edge — add a second storage and the
incumbent's default must be materialised — is about a key the current file **has** and the tidy file
would **lose**. That earned its own design section and gate instead of a footnote.

## The blocking review finding was right, and measuring it split it three ways

The architect blocked the spec on a real hole: the write rule diffs the live document against the
incoming one, and the two are normalized differently — resolution runs at parse and in the add path,
never on `PUT /api/config`.

The example given was that a partial `PUT` would write empty values. Measuring it instead of adopting
it produced a **different** distribution:

| key | what actually happened | reached the file? |
| --- | --- | --- |
| `zfs.mode`, `zfs.seed`, `backend` | **refused** — `invalid value ""` | no |
| `default` on a lone entry | **refused** | no |
| `name`, `retention` | unchecked | **yes** |

So validation accidentally caught four of six — **by refusing documents `config.yml` accepts** — and
missed the two nobody was watching. `name: ""` reached the disk *and* stayed in the running process
until a restart, on the field `DELETE /api/config/storage/{name}` addresses by.

**The narrow half and the sharp half wanted opposite descriptions**, and one sentence about
"normalization" covered neither well enough to build from.

## The part worth keeping: the citation check

A test comment cited quince#473. The architect could not verify it from a shallow clone and asked for
one of two things — confirm it, or drop the number and keep the sentence.

It was wrong. **quince#504** is the 2026-08-01 short-form ruling; #473 is the flattening. Right
family, wrong ruling.

**And then the architect read what the number actually was.** quince#504's own reproduction:

```
PROBE REJECTED → storage.storages[0].name  must not be empty …
PROBE REJECTED → storage.storages          exactly one storage must be marked `default: true` …
```

**Those are the same two error strings.** quince#504 is this defect, at the load door, found and
fixed in August — **where the defect was met, rather than where the invariant lives.** The write door
kept the hole, and it kept it with the identical messages.

**Nobody went looking for it.** It fell out of verifying a footnote, which is the cheapest way it
could possibly have been found and not a method anything can rely on. The general form is the one
this project keeps paying for from a new angle: *a fix applied at the site of discovery closes an
instance; only a fix at the invariant closes the class.* Three write doors existed; two resolved; the
third was the one the UI does not use, so nothing complained.

## Two smaller things, recorded because both were caught by a reader and not by me

**A pre-existing dangling pronoun that my diff made worse.** A new contracts paragraph landed between
*"Its `422`…"* and its subject, so a sentence about the forget endpoint read as being about
`PUT /api/config`. The pronoun already dangled; three endpoints and one pronoun is what my insertion
made of it. Fixed by naming the subject rather than by moving the block, because relocating leaves the
trap armed for the next insertion. **"My diff didn't cause it" is not a reason to leave it.**

**A test that passed and guarded nothing.** Four tests covered the permissive direction; none covered
the refusal that must survive — two storages, neither marked default. The guard there is a
construction (`len(out) == 1`), not a check, so the review asked for a test. Writing it was not
enough: making the softening it fears (`>= 1`) and watching it go red is what established it guards
anything. Every other test in the file stays green through that edit.

## What this cost and did not cost

The spec took **two review rounds**, the code PR **three**, and every round was a real finding rather
than a style note. Nothing was built past an unruled question: the rung's other half — whether the
Settings preview's YAML text becomes a contract field — is still unruled and parks exactly one PR
rather than the rung.

**`dismiss_stale_reviews` is live on this repo**, learned by having an approval dismissed by a
comment-only push. That turned a free correction into a decision: a second nice-to-have comment edit
is being carried to the next PR instead of pushed, because the PR is waiting on a scarce Operator
approval and a push would destroy it. **Knowing a control exists changes what a cheap action costs.**
