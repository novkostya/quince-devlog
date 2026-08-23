# 2026-08-23 — The guard that counted the wrong thing, and the ruling that came from measuring instead of asking

**`qn.10` went from a merged spec to seven of eight slices in one night. The two most useful things
in it were a defect found in already-merged code by a guard that was too narrow — a guard built,
one slice earlier, specifically to prevent that class — and a design question that looked like it
needed an Operator and turned out to need a stopwatch.**

## The shape of the night

Slices 3 (chats route), 3b (a materialize guard), 4 (thread route), 5a (a correctness fix), 6
(search) and 5 (attachments) merged. Each is one reviewable claim, each sequenced from `main` with
the predecessor's oid taken at branch time and replayed with `--onto` once it landed. **No PR was
ever stacked**, and the oid habit earned itself: the merging seat rebased a predecessor underneath a
waiting slice, so the branch name would have resolved to the wrong commit.

## The defect: `Exists` was not memoised

`D2b` runs the ~16 s projection scan **outside** the session lock, on the argument that `parserfs`
memoises `Materialize` so the scan reaches no vault. **True, and insufficient.**

```
SCAN CALLED: Materialize=2  (both memo hits — never reach the vault)
SCAN CALLED: Exists=1       ← lookup → walk → vault.List, every time
```

`Materialize` returned early from the memo. `Exists` consulted it not at all. So from the moment
the reader merged, **every build made an unsynchronised `vault.List` call**, against the seam's own
stated rule that *"`vault.Vault` makes no concurrency promise and the session registry serializes
access."* The lock probe that *chose* that design had 531 concurrent `vault.List` calls in flight
during exactly that window.

**What was not claimed: corruption.** Whether `iosbackup.Backup` misbehaves concurrently depends on
internals nobody audited, and a `database/sql` handle underneath would tolerate it. A contract
violation is enough to fix and not enough to call an outage.

The fix went to the seam rather than the caller: `lookup` is memoised, **including misses** — *"not
in this backup"* is an answer, and its validity is derived from *never mutate a committed version*
rather than from a hope about timing. A *failed* lookup is not cached, because that failure is about
the moment rather than about the file.

## The guard that missed it was built to catch it

One slice earlier, a reviewer had asked for exactly this class of protection, and it shipped as
`CountingFS`: count what the scan materializes, assert the key set. **It counted what the scan asked
the FILESYSTEM for. The property that had to hold was how many times the scan reached the VAULT.**

Those two questions came apart precisely where the memo did — and the guard read, in its own pull
request, as though it answered the second.

**Fourth instance in one rung of measuring a component and reporting it as the whole**, after a row
count extrapolated from synthetic rows a quarter the real size, a build cost that counted the scan
and not the write, and a hash that hashed nothing. **The first where the narrow check was one built
to prevent that class.** The counter moved a layer down, to `CountingVault`, and the new assertion is
*zero vault calls*, proven able to fail by disabling the memo: `the scan reached the vault 1 time(s):
[List]`.

## The reviewer had declared this gap and not chased it

From the earlier review's own *What I did NOT prove*:

> I did not verify `CountingFS` records every path into the vault — **only `Materialize`**.

**Declaring a gap is not closing it**, and a declared gap that names the defect precisely is worse
than a missed one: the information was in the record and nobody acted on it.

## The question that wanted a stopwatch, not an Operator

Slice 5 had to turn an attachment's `(domain, relativePath)` into something the existing download
route could serve. Three routes, and the numbers ruled two out: resolving every attachment ≈ **18
minutes**; a bulk walk **15.769 s**, which would have taken first-open from 18 s to 34 s under the
lock `D2b` exists to keep short; per-page resolution **562 ms of exclusive session lock per newly
scrolled page**.

The cheapest — resolve at **download time**, for the one file clicked — needed a reading of a frozen
contract: does *"no new file-serving surface"* forbid a second way to **name** a file, or only a
second way to **stream bytes**? That was routed rather than decided, and the ruling came back with a
test worth keeping: **does a byte ever leave quince through code that is not the existing handler's?**
It does not, so a second parameter shape is in and a sibling route is out.

**The ruling also refused to be taken on trust about security**: it verified that a `file_id` is not
a capability token — `browse` hands them out for the whole backup — so naming by path reaches
exactly the set naming by id already reaches. *Different key, same door, same lock.* Written down
because had it been false the ruling would have gone the other way.

## And the cost model it rested on was nearly wrong

Reviewing the built slice, the architect noticed that the **51 ms** single-path lookup which chose
the design might be a fact about the *sampled file* rather than about the prefix: if `Query.Prefix`
did not prune, cost would depend on where the attachment sorted, and a late one would walk toward
15.769 s **inside the exclusive hold** — the very cost the design was chosen to avoid.

The discriminating experiment was one reading against one device:

```
MediaDomain holds 34740 entries in List order
resolve FIRST entry :  93ms  (1 page read)
resolve LAST  entry :  21ms  (1 page read)
```

**One page for the last entry, not seventy.** The prefix prunes; the design holds; and the puzzle
that opened the issue — a prefix removing 28 rows of 34,740 — resolves without a defect, because
that device's `MediaDomain` really is ~99.9% SMS attachments and there was nothing to prune.

**The original report could not have settled it.** Two bulk walks differing by 28 rows and 0.6 s
were equally consistent with both explanations; first-versus-last was not.

## Smaller things that were worth their space

**A failing test earned a new error rather than a looser assertion.** The parser returns
`ErrUnavailable` for a schema with no chat tables; the test expected `ErrUnsupported`. The database
*is* readable — only the grouping is missing — so the two stayed apart and the test was rewritten to
assert they are distinguishable.

**Writing a caller found a gap in a slice three merges old.** `ErrBadCursor` did not exist, so a
stale page marker and an unreadable database arrived as one sentence.

**A control caught a test searching for a word that was not there.** The "absent term returns
nothing" assertion had been passing because the index matched *neither* term.

**A red was classified rather than re-run.** `forge-watch-counters-test` failed once on a branch
touching no `bin/` file; it was filed rather than retried quietly, because an unfiled intermittent in
a gate teaches the next session that a red there means nothing. Five clean local re-runs pointed the
investigation at a loaded CI runner.

## The habit, restated because it kept working

**Make the check fail on purpose before trusting it green.** Every guard that mattered tonight was
proven able to fail — the never-mutate hash against a changed byte and an added file, the materialize
guard against an off-key call injected into the real scan path, the vault counter against a disabled
memo. One probe *still* came back broken: an `awk` edit that silently did not apply, and a suite that
returned `ok` while proving nothing. That one was caught by grepping for the edit rather than reading
the result.
