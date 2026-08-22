# 2026-08-23 — The rung that had already been half-built, and two costs measured too narrowly

**`qn.10` opened as *"the vault becomes a `backup.FS`, proved by a domain"*. That work merged at
`qn.9` eleven days of PRs earlier, and the scoping issue could not see it. What the rung actually
has is a scale problem, and the two times this session put a number on that problem before
measuring it, the number was wrong in the direction that flattered the design.**

## The scope had moved, and a stale checkout is what hid it

quince#1483 scoped the rung around one interface and listed three rulings owed before code. All
three were answered by merged code: `parserfs` implements `Materialize`, `Exists` and `ReadDirFS`
with the sidecar copy (quince#1456, `qn.9` slice 7), and `messages.Open` is already a wired prober
in `core/internal/vault/capability`. `qn.9`'s own D7 had claimed the seam explicitly.

**The session nearly built it a second time.** The checkout it started from was **195 commits
behind**, and every fact it needed was in those 195 commits. The fresh clone `/kickoff` §3 requires
is what surfaced it — not diligence, procedure.

The architect verified the claim independently on `main`, line by line, before approving:
`Materialize` at `:99`, `Exists` at `:84`, `sidecarSuffixes` at `:41`, the `ReadDirFS` assertion at
`:80`, the prober at `capability.go:132`.

## Measured, on real backups, by permission granted mid-session

The Operator supplied the backup password partway through, which turned an estimate into a
measurement. Device B, iOS 26.6, through quince's own path — `OpenEncrypted` → `Unlock` →
`parserfs` → `Materialize` → `messages.Open` — with the storage mounted **read-only**, so *never
mutate a committed version* was structural rather than careful:

| | |
| --- | --- |
| `Materialize` | 928 ms for 446.4 MiB — 481 MiB/s |
| `Chats()`, all | 10 ms, 390 chats |
| `Messages()`, all | **8.437 s, 254,949 messages** |
| capability | `missing=[]`, `BodyUndecoded` 0, row errors 0 |
| busiest single thread | **98,598 messages** |

The parser's read API is scan-only at v0.2.0 — no per-chat filter, no cursor, no by-id accessor —
so a thread page at the far end of a conversation costs the entire table. That is the rung.

## The first number measured too narrowly

Before the password arrived, the spec estimated the row count by extrapolating **bytes per row**
from a synthetic database: 0.5M–1.6M messages, 13–40 s per scan.

**Real rows are 1,836 B against the synthetic 254 B** — the real `message` table has **95 columns**,
not the 26 the fixture-derived generator wrote. The estimate was out by 7× on the quantity that
mattered, and the true count is a quarter of the low end of the range.

The spec keeps the withdrawn estimate rather than deleting it, as a guard: **do not size an iOS
table from a synthetic row.**

## The second number measured too narrowly, in the same session, after the lesson

D2 rules that one scan builds a session-scoped projection and every surface reads that. The spec
costed it at **~9.4 s** — `Materialize` plus the bare scan.

Measured afterwards on the real backup: **18.256 s**. The scan that *writes the projection* costs
15.944 s where the scan that merely reads costs 8.437 s. **The projection write roughly doubles it,
and the figure had simply not counted it.**

Twice, then, in one document: a cost stated from a measurement of something narrower than the thing
being claimed, and both times the omission flattered the design. The pattern is not carelessness
about arithmetic — both figures were real measurements of real things. It is **measuring the
component and reporting it as the whole**, which is this project's most-filed defect wearing a
numeric disguise.

## What the projection bought, which is the part that held

| query | through the parser | off the projection |
| --- | --- | --- |
| thread page, far end of a conversation | **8.437 s** | **265 µs** |
| thread page, newest 50 | — | 189 µs |
| search over 254,949 messages | not possible | 67–478 µs |

FTS5 over the whole corpus builds in 1.235 s and the projection occupies 63.1 MiB of session
scratch. The design holds; only its advertised price was wrong.

## The finding that came from review, not from measurement

D2 said *one scan at unlock*, three times, and **never weighed when the scan should run**. The
architect caught it: `qn.8`'s file browser is shipped and in use, and an unlock is not a request
for messages — so every unlock, including one that only wanted to download a single file, would
have paid the whole cost of a domain the user never opened.

The remedy was not a route through the data. It was *do the same work later*: the scan is now lazy,
on first read of a `messages` surface. **Nothing is lost, and that was checkable rather than
assertable** — `qn.9`'s capability prober already opens the domain without scanning, at 11 ms
against 8.437 s, so *does this backup have messages* is answered without it.

That finding landed against the 9.4 s figure. Against the true 18.3 s it is worth twice what it
looked like.

## Three corrections the real data forced

- **Real iOS ships the join indexes** — 82 of them. A synthetic run without them was **127× slower**
  (2707.7 µs/row against 21.3), because the parser issues one query per message. So the penalty is a
  **fixture hazard, not a runtime one**: the parser's own fixture carries no such index, and a quince
  fixture copying it would make CI glacial and mis-measure everything resting on it.
- **The attachment cache was accurate.** `enrich` gates `fillAttachments` on
  `message.cache_has_attachments`, and a synthetic control — five valid, non-dangling join rows with
  the column at its default — yields *1000 messages, 0 attachments*. On the Operator's data there is
  no shortfall: 21,777 join rows, 21,777 yielded. The spec keeps a one-`COUNT(*)` reconciliation as
  a **guard**, and says in those words that no defect was found in real data.
- **The third device tree is not a backup.** No `Manifest.db` at all. The spec had cited it as
  evidence that *no messages in this backup* is a real case. The real case is device A: unencrypted,
  valid `messages.1` schema, `supported=true`, and **0 messages** — which is the better witness,
  because it separates *you have no messages* from *quince cannot read them*.

## A merge that was deliberately not raced

The correction to the 9.4 s figure was found **after** the architect approved and armed auto-merge.
Pushing it would have re-triggered CI and then landed, unattended, a commit nobody had read — so it
was posted as a comment with the numbers and a request for the call, and the figure is owed to slice
2, which is the PR that builds the projection.

**Auto-merge changes what a push means.** With a human merging, a late push is a request for
attention; with auto-merge armed it is a merge.

## Where the rung stands

Slice 1 — the spec — merged as quince#1491. Slices 2–7 are the reader and projection, three routes,
attachments, search and the surface. `G6`'s sizing half is closed by the measurements above; its
correctness half is the Operator's spot-check against iMazing and ships with slice 7.
