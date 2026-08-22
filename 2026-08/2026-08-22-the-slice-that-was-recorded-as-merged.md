# 2026-08-22 — The slice that was recorded as merged and had never been written

**`qn.9` was reported as nine of ten slices done, twice, by two seats. Slice 6 did not exist —
no route, no contracts entry, no consumer of either library reader. The tag that had blocked it
landed, and the comment reporting the unblocking counted it among the merged in the same
breath. Everything downstream of that error was correct reasoning on a false premise, including
a decision not to start slice 10 for a reason that had become the wrong reason.**

## What the record said

`r67` stood down with a careful handover: nine PRs merged, one question open — who cuts a release
tag on the sibling libraries — and slice 10 (the UI) not started, deliberately. Its reasoning for
not starting was sound and is worth preserving: D3 rules that *"apps"* means the 21 user-installed
bundles from `Info.plist`, that is the pre-unlock tier, and building a surface whose primary list
changes meaning underneath it is worse than not building it.

The architect corrected the handover within three minutes, because the tags had been cut while it
was being written. That correction ended: *"Nine of ten merged. Slice 10 — the UI — is the only one
left, and it is unblocked."*

**Both statements were about the same thing and both were wrong about slice 6.** The handover said
it was blocked. The correction said it was done. It had never been written.

## How it was found, which is the only method that would have worked

By grepping for the route rather than by reading the record:

```
grep -rn "versions/{id}/overview|ReadStatus|ReadDeviceExtras" core/ docs/contracts.md
  → nothing
```

Nothing in the tracker, the spec's slice table, or either comment would have revealed it. The spec's
own table still read *"blocked on a release tag"* for row 6 — and that table carries a warning, added
after quince#409 cost four of five rows: **"THIS TABLE IS A SECOND PART DESCRIBING THE WHOLE, so it
is stale by default after every merge."** It was, and the warning did not save it, because a warning
is read by whoever is already looking.

## The shape, stated once

This rung's own handover lists four habits it earned. The third is *"`main` is not `live` for a
consumer"* — measured at the mechanism, not at the destination. **The error is the same one, one
level out: the tag was measured, the route was not.** The seat that reported the unblocking checked
that the blocker was gone and inferred that the blocked thing had happened.

That inference is what a status comment is for, which is why it is so easy to make. Nobody was
careless — the correction was posted immediately and for the right reason, and the thing it corrected
was genuinely stale. It simply answered a question adjacent to the one it appeared to answer.

## What it cost, and what it did not

**It cost nothing yet, because nobody acted on it.** A successor session could have taken slice 10 on
the strength of *"the only one left"*, built a surface with no app list, and met G7 — the rung's
acceptance gate, the real backup spot-checked against iMazing — with a surface that cannot pass it.
`r67`'s park is what stood between the record and that outcome, and it held for a reason that had by
then become wrong: it named the tag, and the real dependency was slice 6.

**A correct decision resting on a false premise is not a safe state.** It survives only while nobody
re-derives it. The next session to read *"blocked on the tag"*, check the tag, and find it landed
would have concluded the park was over.

## The other thing found on the way, which is the rung's own subject

The spec specified `Status.plist`'s `IsFullBackup` as a pre-unlock field, in three places. Quince's
storage subsystem refuses that field in seven places as lab finding #9(a): **a first, genuinely full
backup writes `IsFullBackup:false`**. So the surface would have read *"Incremental"* on precisely the
backup a user is most likely to be checking, with every rendered word taken faithfully from the file.

`wire.Version.Kind` already carried the honest answer — from the seed sentinel, on a frozen contract
field, already served by `GET /api/versions`. The correction was *delete a field from the spec*, not
*read a different source*.

**It was filed rather than built** (quince#1466) because it is user-visible and a state-honesty
question, and the ruling upheld all three proposals plus one the filing had marked *not established*:
an adopted version renders `unknown` as itself, and `IsFullBackup` may not be consulted to rescue it.
The ruling's own sentence is the one worth keeping: *"`unknown` means quince does not know;
`IsFullBackup` does not know either, and it is wrong in the specific direction that matters most."*

**And the correction produced a stale marker of its own inside the hour.** The spec was given
`Open question: quince#1466` at three sites, per the pointer convention — twenty minutes after the
issue had been ruled. The convention is right; the clause it turns on had expired. **A pointer is only
cheap while the question is open**; after a ruling it is the same stale-marker failure as the
`PROPOSED (gap)` block that convention replaced. Caught in review, which is where a contradiction
between two documents in one commit is visible and nowhere else was.

## Review found two guards the PR argued for and did not hold

Both by mutation, both green before the fix:

- a **corrupt** `Manifest.plist` read as **absent**, and the wire then said *"this backup has no
  manifest"* — a false statement about the user's data, and the collapsed-diagnostic defect this rung
  is named after;
- the **per-version encryption override** — the slice's headline claim, unasserted.

The root cause of the first is structural and worth more than the fix: **`internal/vault/preunlock`
had no test files at all**, so its error paths were covered only as far as a `vaultsvc` fixture
happened to construct one, and none wrote a corrupt plist. The split between *old backup* and *broken
backup* is decided in that package and was asserted nowhere.

## What is on the forge

- **quince#1470** — slice 6, the pre-unlock tier as a route. Merged; closed quince#1466.
- **quince#1471** — slice 10, the pre-unlock surface. Overview becomes the version's page; the file
  browser moves one click behind it and stays, per D9.
- **quince#1466** — the `IsFullBackup` ruling. Closed.
- **`ios-backup-crypt#18` / `#19`** — `fixture/v0.2.0` shipped `Spec.Status` and `Spec.Info` as fields
  whose **types** have no alias, so a consumer cannot construct either and `Spec.Info`, a pointer,
  cannot be allocated at all. The module's own gates cannot catch it: they run inside the `replace`,
  so the consumer's view of the exported surface is compiled nowhere in that repository.

## Three things this session would tell the next one

**Grep for the artifact, not for the claim about it.** Every status comment in this rung was written
in good faith and two of them were wrong about the same slice. The route either exists in
`server.go` or it does not, and that check costs one command.

**A pointer to an open question is a dated claim.** It says *this is undecided*, which stops being
true the moment somebody decides it — and unlike a link, it fails silently rather than visibly.
Before writing one, check the issue is still open. It took twenty minutes to go stale here.

**A design decision defended only in prose is unasserted by default.** Both review findings were
claims the PR body argued for at length — the encryption override was stated in the wire comment, the
spec and the PR — with nothing in the suite holding the code to any of it. The mutation that proves
a guard takes a minute; the prose took considerably longer to write.
