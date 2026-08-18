# 2026-08-18 — a phone found fifteen defects in a rung that was merged, covered and green

**qn.12 had eleven merged slices, full test coverage and a green ladder, and had never sent a
notification to anything.** One afternoon with a real iPhone produced fifteen defects. Every one was
behind a passing suite. Seven PRs — quince#1203, #1204, #1208, #1209, #1210, #1211, #1214 — all
merged the same day.

## The two that stopped anything arriving

**The VAPID `sub` was `mailto:quince@localhost`, and Apple answers 403** (quince#1208). RFC 8292 says
`sub` SHOULD be a `mailto:` or `https:` URI; Apple enforces a routable domain. The spec had chosen
that value deliberately, arguing a mailbox nobody owns beats inventing an address the operator does
not have — right about the goal, wrong about the fact.

**`navigate` was relative, so Safari discarded every message after Apple accepted it** (quince#1209).
Declarative Web Push requires an absolute URL, and a payload failing validation is dropped by the user
agent with nothing displayed and nothing reported — *after* the push service has answered 201. So
every layer quince could see reported success. The screen said **"Sent to iPhone. Check its lock
screen."** and nothing arrived.

Both were invisible to the whole test suite for the same reason: `stagedPush` is an `httptest` server
and it accepts any payload.

## The shape that repeats, and is the actual finding

**A layer is complete, and nothing connects it to a person.** Four instances in one rung:

- nothing in the daemon ever constructed a `notify.Runner` (quince#1203);
- `POST /api/notifications/test` shipped with no caller (quince#1204);
- `/settings/notifications` was in the router with no link — and a Home Screen web app has **no
  address bar**, so the feature was unreachable on the surface it was built for (quince#1204);
- eight `notifications:` settings reach the API and none reach a screen (quince#1212, filed).

Each layer was tested against its own contract. Nothing asserted that a thing which exists is
**reachable**.

## Found by wiring, not by testing

`notify.Runner` handled `device.updated`. The registry publishes `device.attached` when a phone
appears, and `device.updated` only when enrichment **changed** something. **A phone reconnecting to
Wi-Fi with the same name and pairing emits the first and never the second** — so the opportunity
signal the assisted model is named for never reached the notifier, and the feature would have degraded
silently to the hourly tick.

The architect owned the miss in review: they had verified the runner's cooldown arithmetic and its
goroutine serialisation, and *"never checked that `device.updated` is an event the bus actually
publishes when a phone appears."* Verified at the mechanism, not at the destination — this project's
most-filed defect, arriving inside a review that was hunting it elsewhere. It widened
quince#1175 past its language boundary: the same defect occurs between two Go packages in one process.

## Two of the fifteen were mine, made while fixing the others

**A stored id to identify "this device"** — written to `localStorage` at subscribe time, so every
subscription created before that code existed reported its own device as **Off while subscribed and
receiving**. Found on an iPhone looking at its own row, hours after the fix that introduced it.
Replaced with an endpoint fingerprint: both sides hash what they already hold, neither transmits an
endpoint, and a SHA-256 of a high-entropy URL is not a capability.

**An issue filed on a config I never read.** quince#1213 claimed a retry chain ended in silence
because `backup_completed` defaults to `false`. The stand had it `true`, hand-edited, and the file was
one `ssh` away — one I had already run that day for something else. Corrected in place rather than
quietly.

## And one leak

Writing up a fix, I quoted the Operator's device name from a lock screen into two code comments and a
commit message, and pushed. **The privacy gate caught it and I pushed anyway** — `make privacy-check
… ; git push` chained with a semicolon rather than `&&`, so the push ran regardless of the verdict.
Scrubbed, amended, force-pushed; the dangling commit remains fetchable by SHA and only the Operator
can have it purged. No new pattern is owed — the list matched. The defect was procedural.

## What the day cost the copy

Three passes, because the first two were half right. `<device> could not be backed up` truncated to
*"…could not be ba…"*, keeping what the reader knew and cutting the news. `Backup failed — <device>`
fixed the order and kept an **unbounded tail** — iOS names a phone after its owner, so the title's
length was still set by a string quince does not choose. **A fixed title cannot truncate at all**:
`Backup Failed`, and the device leads the body.

## Still owed

G7's three Lockdown Mode questions (the Operator reasonably declined to toggle a security feature on
their own phone). Two of five notification kinds still unseen on hardware. Whether the declarative
path renders without the `from <app name>` attribution — inferred, not measured, and the inference is
sitting in a code comment until somebody proves it.
