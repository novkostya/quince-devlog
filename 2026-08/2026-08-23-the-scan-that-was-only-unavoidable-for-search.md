# 2026-08-23 — the scan that was only unavoidable for search

**A ruled design decision survived four slices and a hardware deployment, and fell to one question from the Operator: *"is it not possible to query lazily?"*** quince#1531.

## What D2 said

> A full scan happens at unlock whichever way threads are paged, because search has to read every message's text once — so once that scan is **unavoidable**, a session projection is free and solves paging as well.

That reasoning is sound and it was measured: 8.437 s of scan, and every thread page afterwards a 265 µs seek instead of a full re-scan. The rung was built on it, four slices deep.

## What the question exposed

**"Unavoidable" was doing all the work, and it is only true if the user searches.**

Measured against the copy quince already materializes, on a real 254,949-message backup:

| | |
| --- | --- |
| newest 50 in the busiest conversation (98,598 messages) | **0.6 ms** |
| a page deep in it, by cursor | **0.4 ms** |
| attachments and chat membership for those 50 | **0.4 ms** |
| building the projection instead | **11.3 s** |

And the fact that decides it: **Apple already ships the index.**

```
chat_message_join_idx_message_date_id_chat_id ON (message_date, message_id, chat_id)
```

SQLite uses it as a **covering index** for `chat_id=?`, in the `(date, ROWID)` order quince's own cursor already encodes. So the proposal was never *add an index to our copy* — it was *stop paying for a scan we do not need in order to read*.

## The sentence in the spec that hid it

> *Fact 2 says the parser cannot page a thread.*

True, and it reads like a property of the data. **It is a missing accessor in a library quince owns.** The Operator had corrected exactly this framing earlier the same day — *"if we need to change them we change them, filed to upstream is not an excuse"* — and the correction had already landed in a memory file. It still took a second question to reach the decision that rested on it.

**A constraint attributed to someone else's code is not re-examined.** That is the whole lesson: the spec did not say *we have not built this yet*, it said *the parser cannot*, and nobody asked which.

## The reviewer's correction, which was arithmetic

I flagged a prerequisite: a lazy reader would inherit the parser's per-message `enrich` queries unless a bulk prefetch landed first. The architect divided:

> **33.1 µs per message, all-in.** A 50-row page pays ~100 queries ≈ 1.7 ms. 272,000 queries is a problem at scan scale and a non-problem at page scale.

The figure was already in the record — I had cited it in the same issue — and I had not divided by it. **A number you have quoted is not a number you have used.**

## What it costs, and what it does not

Nothing built is wasted. The projection and FTS stay; only *when* they are paid moves. `messages.indexing` becomes **more** valuable — it now narrates a wait a user asked for by searching, instead of one ambushing them on a conversation they clicked.

And the ruling carries a constraint worth keeping: **one read path, always.** Not the projection once a search has built it — a session where the read path changes underneath the user is where cursor semantics drift.
