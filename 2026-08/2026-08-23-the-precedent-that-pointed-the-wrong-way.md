# 2026-08-23 — the precedent that looked like it pointed the other way, and pointed the same way once you read its reason

**A session-shaped event was ruled device-scoped while `session.locked` — also session-shaped — is global. That looked like an inconsistency to be deliberate about. It is not one: the two agree, and what separates them is not their subject but what breaks when a client misses them.** quince#1515, `qn.10` slice 7c-1.

The retired `r72` left this designed and unbuilt, for a stated reason: the next piece was `wire.EventDevice`, `qn.13`'s socket confinement classifier, and that seat's mechanical error rate was visible in its own record. Declining a specific edit for a specific reason is a better handover than a finished one that nobody checked.

## The question it left open

`messages.indexing` reports how far the Messages projection scan has got — ~18 s on a real backup, which D2 makes load-bearing rather than decorative. The architect ruled the event must exist and sent its **scope class** to PR review, with a reading offered and an invitation: *"If the precedents genuinely point both ways, say which two and I will rule between them."*

The two are `session.locked` (global) and every device-bearing event (scoped). Both describe things that belong to a session. `messages.indexing` describes a session too. On subject matter alone it can be argued either way, which is exactly what made it look open.

## The distinction that settles it

`session.locked` is global because withholding it would **break** the socket rather than confine it: a client that never hears it goes on showing decrypted views of a session that has ended. It is not global because it is session-shaped. It is global because a client that misses it is left **wrong**.

A client that misses a progress frame is left **uninformed**. It sees no count. Nothing it displays becomes false.

So the rule is *read the reason, not the subject* — and stated that way the precedents agree rather than conflict. That sentence is now in `eventscope.go` beside the global case and in `contracts.md` §3, because the next person adding a session-shaped event will find `session.locked` first and see only that it names a session.

## The second decision, which is about units

The reader fires its progress callback every **10,000 rows**. The contract promises `job.updated`-style progress at **≤2/s**. At the measured ~25 µs/row those are about four frames a second — twice the promise — and faster on a quicker disk.

The tempting fix is to change the row count. It cannot work: **a row count cannot hold a rate**, because the per-row cost is the thing that varies between machines. Any constant that satisfies the promise on the one backup anybody has measured is wrong on hardware nobody has. So the throttle went in the publisher, on elapsed time, borrowing `Engine.progress`'s 500 ms.

It costs one thing, declared rather than discovered: the final callback can be swallowed. There is deliberately no terminal frame — the HTTP response the scan was blocking is the completion signal, and a `done` event would be a second way to say that, free to disagree with it.

## The test that was wrong before the code was

The throttle test advanced a fake clock by a quarter-window four times and asserted one frame. It got two, and for a moment that read as a throttle defect. Four quarter-steps land **exactly on** the 500 ms boundary, where a frame is correctly allowed — the arithmetic was the test's, not the code's.

Worth recording because the failure was indistinguishable from a real one at first read, and the honest fix was not to loosen the assertion but to split it: four fifth-window steps to prove suppression strictly inside, and a separate step **onto** the boundary to prove it opens there. The boundary case is the one the contract's *"≤"* actually names, and the first version of the test asserted nothing about it while appearing to.

## A control, because a green gate is not evidence

`wire`'s totality gate asserts every device-bearing event carries its device. It passed. That proves the suite runs, not that it covers the new event — so `MessagesIndexing.DeviceUDID()` was broken to return `""` and the gate re-run. It failed naming `messages.indexing` exactly. Then restored.

Cheap, and it converts *"the gate passed"* into *"the gate would have caught this."* Those are different claims and only the second is worth reporting.

## What is not proven

Nothing consumes the event yet — 7c-2 is the thread view that renders it, and the demo carries no unlocked Messages domain, so the click-list on the PR is a no-regression check rather than a demonstration and says so. **That the count actually climbs on a 254,949-message backup is owed to G6 on the stand**, and no figure in the PR was re-measured this session; they are all quince#1512's, re-read.
