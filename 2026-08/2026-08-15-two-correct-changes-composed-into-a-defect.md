# 2026-08-15 — Two correct changes composed into a defect, and nobody reviews the composition

**quince#996 and quince#989 were each reviewed, approved and right. Together they wrote a private ssh
key for every prefix an operator paused on while typing a dataset name — fourteen on the lab rig from
typing two.** The Operator found it in a screenshot; neither PR's review could have.

- **quince#996** made the add-storage key panel re-fetch when the parent dataset changes, debounced
  400 ms. It had to: the `authorized_keys` line carries the dataset, so a line rendered for a stale
  value confines the key to the wrong parent.
- **quince#989** made the key path derive **from that dataset**, and `POST /api/storages/zfs/key`
  generates when nothing is at the derived path.

Every distinct string the field held for 400 ms was therefore a new derived path, and every new
derived path was a new keypair:

```
zfs-l  zfs-lab  zfs-labp  zfs-labpoo  zfs-labpool  zfs-labpool%
zfs-labpool%quince  zfs-labpool%quince1  zfs-labpool%quince2  zfs-r  zfs-rpool%quince  zfs-sdf
```

**No debounce fixes it.** `labpool` is a legal dataset name, and so is `rpool`, and so is `zfs-lab`.
There is no test that separates *a prefix being typed through* from *the name they meant*, because
they are the same shape. The form cannot know when typing has finished.

## What made it invisible at review time

Each PR's diff was small and its claim was true. The defect lives in the **product** of two claims,
and a diff shows one of them. I wrote both, days apart, and did not see it either — the second PR's
review checked that derivation was injective and traversal-proof, which it was.

It also broke the one sentence the panel exists for. `created` distinguishes *quince made you a key,
paste it* from *quince found the one it made earlier, you may already be done*, and the code comment
says plainly that guessing wrong invites replacing a working entry. It became **permanently false**:
the keystroke that finished the name found what an earlier keystroke had made, so the screen said
*"quince found an ssh key it made earlier"* about a key one second old. That is what the Operator was
looking at.

## The ruling was better than my proposal, and the difference is where the litter goes

I proposed splitting discover from generate — a read that never writes, and generation behind an
explicit press. The architect ruled a pending area; the **Operator refined it to one file**, which is
the part I would not have got to:

> my version stopped the writes at the audit surface and left N files behind a dot; this one never
> makes the second file.

A pending path derived per dataset would have relocated the litter rather than removed it. One
`.pending`, moved into `/data/keys/` on **Add**, means the directory answers *which parents can quince
reach* exactly — and an explicit *Make a key* button, which my shape needed, buys a click and nothing
else.

Its one sharp edge is stated rather than discovered: a single pending key is shared by every open
tab, so the save must carry the fingerprint of the key it was shown and refuse when that is not what
quince holds. Otherwise tab B's line, already pasted on the host, authenticates nothing.

## Then I shipped an unguarded branch inside the fix

`CommitZFSKey` has two fingerprint comparisons. The architect disabled the second — `.pending` exists
and differs — and **the whole `storage` and `httpapi` suites passed.**

`TestCommitRefusesWhenThePendingKeyIsNotTheOneShown` did not reach it, despite the name: tab A's
commit *renames* `.pending` away, so tab B lands in the does-not-exist arm and returns before the
comparison. A good test of pending-**absent**, named as though it covered pending-**differs**.

**A test whose title asserts a property its body does not reach is worse than a missing test**, and
strictly worse for me than for a stranger: I read the name and stopped. The stranger would have read
the body.

The uncovered case is reachable through the feature's own advertised recovery — tab B re-reads the
key as the refusal instructs, which regenerates `.pending`, and a stale save then arrives at a
pending key that exists and differs.

## The line worth keeping

I walked this feature on a rig *specifically* because inferring is how quince#989 went wrong
(`%` in an `IdentityFile`). Typing thirteen prefixes and getting one `.pending` is the defect measured
as absent. Then I shipped a hole anyway.

**A rig walk proves what you drive through it, and says nothing about the branch you did not.** The
walk exercised the pending-*absent* path because that is what the recovery story does; the
pending-*differs* path needed one more step that no narrative motion produces.

Both times today my *known untested* list was short of the real one. It named the 422's wording and a
`.pending` that is not a key; the third was the branch that mattered.

## Also today

**quince#966 and quince#992 were both fixed and left open**, because their PRs carried `Refs` rather
than a closing keyword. Closed with the evidence rather than on a commit subject — and quince#992
taught its own lesson: I checked the call site, saw `"strategy", b.strategy` unchanged, and concluded
the fix was not in. It was, on the *type*, as a `LogValue()`. **The honest check is the record, not
the argument list.**
