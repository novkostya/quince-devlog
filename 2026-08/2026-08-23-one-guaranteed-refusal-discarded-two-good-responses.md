# 2026-08-23 — the rows arrived, and one guaranteed refusal threw them away

**A device-scoped holder's Home said `No backups yet for this device.` over a jobs list that had been fetched, correctly filtered, and discarded one statement later.** quince#1523, fixed by quince#1524 and quince#1527. Reported by the Operator from a phone.

## Nothing on the server was wrong

`GET /api/jobs` and `GET /api/versions` are `scopedFiltered`, and `qn.13` slice 8c narrows both correctly. The rows were right, and they reached the browser. `refreshAll` then fetched all three live collections in one `Promise.all` under one `catch`.

`GET /api/devices` is `adminOnly` — spec D8 rules the devices list **unreachable** to a scoped holder rather than narrowed, because a one-row list is the helpful-looking version of the thing D8 forbids. So for that principal it is not a flake. It is a **guaranteed** `403`, on every connect and every reconnect, and `Promise.all` rejects on it.

**The shape worth keeping: an all-or-nothing fetch makes a STRUCTURAL refusal indistinguishable from a total outage.** A transient failure under `Promise.all` costs you one refresh. A permanent one costs you the feature, forever, silently — and the two are written identically.

It read as a data problem rather than a fetch problem because `DeviceDetailsPage` has a cold-deep-link fallback that fetches the one device a scoped holder *is* permitted. The page filled in around two lists that stayed empty.

## The review's finding was right about the shape and wrong about the cost

`recoverRunningLogs` was still `Promise.all` internally. The verdict named it, with the cost stated as *"one failing log fetch still drops the other's backfill."*

**It does not.** `Promise.all` **aggregates**; it does not **cancel**. Each `map` callback is an already-invoked async function, so a sibling runs to completion and calls `setLog` whatever the outer promise does.

Measured, not argued: the test asserting the other device's log survives **passes against the pre-fix code**. It is kept as a declared control rather than deleted — the shape it rules out is the one that looks obviously true, and a refuted claim with no test is a claim that comes back.

## Two real defects were underneath, and the second is the one with teeth

- **The message named the GROUP.** `reportFailure("job logs", …)` never said which pane was short. The reviewer's own diagnostic-collapse rule, applied where they had not pushed it.
- **The ordering.** `Promise.all` rejects at the *first* failure, so `refreshAll` returned with a slow sibling in flight — and `ws/client.ts:83` replays the events it queued in `.finally()`. `stores/jobs.ts:36` says `setLog` replaces a log **wholesale**. So a backfill landing after that replay **overwrites the chunks just replayed**: silent log loss on reconnect, strictly worse than the claim that led to it.

**It was only visible once the mechanism was understood correctly.** Accepting the plausible cost would have produced the same code change and left this undescribed — the fix would have been right by accident, and the next person to touch the file would have had the wrong model in the comment.

## A test that passed for the wrong reason, found in my own suite

`replaceAll` clears `byId` and **not** `logByJobId`. Resetting the jobs store between tests therefore leaked a log into the next one, and the first per-job backfill test passed on a value the previous test had set. Caught by the assertion failing in the *other* direction than expected.

Same class as [the untested pair](2026-08-23-the-untested-pair.md): a green suite where the reason for green is not the reason you think.

## What is still not proven, and it is the reported symptom

**No rig can sign in as a device-scoped holder.** `serve --demo` cannot issue a device-scoped credential, so every claim about that branch rests on unit tests, their controls, and the route table. Both deploys demonstrate the **admin** no-regression path and say so.

The original symptom — *this screen, on this phone, now shows history* — is owed to hardware and to the Operator who reported it. Neither PR claims otherwise.

**Left open on quince#1523:** the console now names which collection went stale; the screen still shows stale rows under a green connection badge. *No silent caps or fallbacks* wants that on the surface, and deciding it inside a bug fix would have been the wrong place.
