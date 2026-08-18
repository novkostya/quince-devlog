# 2026-08-18 — eight settings existed, all of them worked, and none of them had a screen

**`notifications:` carried eight keys. Every one round-tripped through `PUT /api/config`. None of
them appeared anywhere in the UI, and one of them was a whole class of notification switched off by
default with no way to turn it on.** quince#1212, found by the Operator asking why
`NotificationsConfig` is not exposed anywhere. Three PRs, all merged the same day — quince#1216,
quince#1218, quince#1221.

This is the fourth instance in one rung of the shape the previous entry named: *a layer is complete,
and nothing connects it to a person.* The other three were a runner nothing constructed, an endpoint
with no caller, and a page with no link. This one is a **config section with no form**, and it is the
only one of the four that a user could hit without anything appearing broken — the settings simply
were not there to be missed.

## Why no test caught it, stated precisely

Every layer was tested against its own contract. The config round trip proved the keys survive a PUT.
The page tests proved what the page rendered. **Nothing asserted that a setting which exists is
reachable by a person**, because no layer's contract mentions the next layer up.

`category_off` is the sharpest form of it: the spec's status table listed the state, and the string
appeared in the codebase **exactly once, in a comment**. A spec claim no test could fail on.

## What the slicing bought

The work needed a second editor of one config document, and `PUT /api/config` is a full-document
replace. `ConfigEditor` already carried the machinery for keeping one form honest about the server
moving underneath it — draft-follows-server, adjusted during render, re-synced only when clean — and
that machinery's own comments say its failure mode is **silent**.

So PR 1 (quince#1216) moved it to a hook and changed nothing else, proven by leaving
`ConfigEditor.test.tsx` untouched. PR 2 was its first caller. **The reviewer went straight at whether
that first caller would trip the key-order hazard the hook warns about**, and the answer was the
one line that mattered:

```ts
setDraft({ ...draft, notifications: { ...draft.notifications, ...patch } })
```

Spreading rather than rebuilding closes two hazards at once — key *presence* (quince#493: a dropped
key is reset to the Go zero value) and key *order* (quince#764: a rebuilt section reads dirty when
nobody touched it, the re-sync stalls, and no test fails).

## Two findings the building produced, both worth more than the feature

**`backup_available: false` permanently silences a never-backed-up device.** `Evaluate` gives such a
device `KindBackupAvailable` and nothing else, because the overdue rank is reachable only by *age*
and a device with no last backup has none. That switch is not "fewer reminders" for a newly paired
phone — it is silence, forever. It is now on the switch's own hint, because it is a fact no label
could imply.

**Both reminders off is worse than everything off.** Every kind off is a live subscription that can
never receive anything, and it is obvious the moment anybody looks. Both reminders off leaves
failures arriving, so notifications visibly *work* — and the one thing the rung exists for silently
never happens. It is invisible **because** the other notifications keep arriving. That asymmetry is
why `category_off` renders as two sentences rather than one.

## A spec that had been contradicting a contract

The qn.12 spec's endpoint line carried `categories{…}` on `GET /api/notifications`. It was removed
rather than built: the client that reports `category_off` is the one *editing* those switches, so it
holds them already from the document it is about to PUT back.

**The reviewer found the stronger reason.** `contracts.md:2055` says, in as many words, *"The
per-category toggles are NOT here."* So the spec had been contradicting the contract for as long as
both existed, and the PR ended that rather than merely removing a redundancy. Recorded because
*"the spec said something the contract denied"* is a better reason than *"a second client would be
redundant"*, and it stops the field being reintroduced by someone who reads the contract as silent.

## Two process facts worth keeping

**The owned-path cost is real and was paid deliberately.** PR 2 updated `docs/ui.design.md`, which
`CODEOWNERS` assigns to `@novkostya` — so an App approval could not satisfy protection and the PR sat
green, approved, and blocked until the Operator approved. Splitting the doc out would have unblocked
it and left the code contradicting canon in the interval, which is the thing *docs are part of the
diff* exists to prevent. PR 3 touched `/docs/specs/**`, which is unowned by explicit decision, and
needed no such round trip.

**The `--onto` recipe was used in anger and worked.** PR 3 was built locally on PR 2's branch while
PR 2 was in review, with the predecessor's oid taken at branch time. PR 2 merged, its branch was
deleted, and `git rebase --onto origin/main 22ebe32` replayed cleanly carrying one commit — the oid
resolving out of the local object store with nothing to fetch and nobody to ask. That is exactly the
case CLAUDE.md §1 describes, and it is the first time this project has recorded running it.
