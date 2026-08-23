# 2026-08-23 — The deploy that proved its own click list, and two wrong readings caught before they reached the Operator

**`qn.10`'s API went to staging and was exercised against the Operator's real 254,949-message
backup before any click list was handed over. The deploy is the small part; the entry is two
claims made from partial data and withdrawn within minutes of each other.**

## The deploy

`da1f911` — the whole rung's API, fourteen slices merged in one night. Verified rather than
assumed, because `make push` can exit 0 without publishing and a daemon compares by tag:

- registry digest moved `363f8e33…` → `5712383b…`, matching the push manifest;
- the served version reads **`0.1.0-alpha.2-267-gda1f911`**, which names the commit;
- the **running binary** greps `messages/chats` **0 → 2**, search and thread routes 0 → 1 each,
  **with a control string** (`sessions/{id}/overview`) that stayed at 1 so the method is known to
  work;
- health 200, the new route answers **401** rather than 404 — registered *and* guarded.

## Then it was exercised, not described

A click list nobody has walked is a guess. Logging in with the admin password and unlocking the
real iPhone backup on the deployed build gave the numbers a click list should carry:

| | |
| --- | --- |
| chats list | **390 conversations, 1.75 s** — includes materializing 446 MiB |
| first thread open | **12.78 s** — pays the projection scan once |
| second thread open | **0.00 s** |
| search, three terms | **0.02–0.07 s**, 20 hits each |
| capabilities | `["threads","attachments","search"]` |

**And the honest half: there is no Messages screen.** Slices 7c–7e are unbuilt, so the only place
the rung is visible in a browser is `qn.9`'s capability report, where the row now reads
`messages · Readable · messages.1`. The rest is curl. **G6 is still not satisfiable** — spot-checking
against iMazing needs a surface.

## Two wrong readings, minutes apart

**"7 ERROR lines in the log."** The grep was `grep -ci "ERROR"`, and it matched the JSON *field
name* `"error":` inside `WARN` records. There were none. A count of the actual `"level"` field
returned 12 INFO, 9 WARN, 0 ERROR.

**"quince cannot reach the muxer."** The health payload carries an *array* of muxers. The first
entry is `/var/run/usbmuxd`, `state: absent`. Reading that one and stopping produced a confident
report that USB device operations were broken. The second entry is `/var/run/mux/usbmuxd`,
`state: external`, serving **wifi** — working. quince probes both because both are defaults, and
says of the absent one that it is *"normal unless you expected a muxer there"*, which is precisely
the honest-diagnostic behaviour a commit added earlier the same week.

**Both were caught before the Operator saw them, and both are the same error**: reading one
component and reporting it as the whole. That is the seventh instance in this rung — after a row
count extrapolated from synthetic rows a quarter the real size, a build cost that omitted the write,
a hash that hashed nothing, a guard counting the filesystem when the property was about the vault, a
test searching for a word absent from its fixture, and a design-doc reading that would have turned
every sentence into a card title.

**The pattern is not carelessness with numbers.** Every one was a real observation of a real thing,
answering a narrower question than the one being claimed. What catches it is asking *what is the
whole that this is a part of* before reporting — and in the muxer case, that was one more line of
the same JSON.

## A wrong reason recorded beside a right decision

Two merged PR bodies and D2 describe changing `ios-backup-parser` as **"upstream"**, framed as
needing an external release and deferred on that basis. **The parser and the crypt library are
quince's own** — same process, architect cuts the release (Operator, 2026-08-23), and `qn.9` had
already merged three slices in those repositories.

So the per-chat accessor was never blocked. **D2's ruling does not change** — a session projection
is right independently, and search needs a full pass regardless — but *"the upstream accessor stays
worth doing as a later optimisation"* rested on an availability constraint that did not exist.

**A right decision with a wrong reason attached is worse than it looks**, because the reason is what
the next reader reuses. Recorded in quince#1512 with the performance work it bears on.

## What the 12.78 s is made of

Measured: the bare scan is **8.437 s**, the same scan *writing the projection* is **15.944 s** — so
the write roughly doubles the read, across ~513k inserts. Indexes add 252 ms, FTS5 1.235 s.

Four levers follow, and **every one of their expected gains is arithmetic rather than measurement**
— which this rung has been punished for often enough that it is worth writing down as an admission
rather than a plan. The cheapest to settle is bulk-prefetching the join tables in the parser, which
is the parser's own `loadHandles` pattern applied to two more tables.
