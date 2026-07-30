# 2026-07-24 — (dl) SPACE SCARE resolved — the reflink accounting trap's SECOND ambush, this time via the snapshot columns; no space is being wasted

(dl) **SPACE SCARE resolved — the reflink accounting trap's SECOND ambush, this time
via the snapshot columns; no space is being wasted.** The Operator saw `zfs list -o space` bill
~177 GB for the two lab devices (three iPhone snapshots at ~33.9 GB "unique" each, `USEDDS`
68.2 GB) and reasonably read it as a design failure. Pool ledger says otherwise: `bclonesaved
122G` / `bcloneused 37.0G` → **actual physical spend ≈ 55 GB** (one shared tree of blocks + real
per-generation deltas). **The signature, now canon (stack D5):** under the reclone-per-generation
lifecycle, the NEWEST snapshot bills ~0 unique (the head shares its block pointers) and EVERY
OLDER generation bills ~the full tree (the next seed's exchange replaced all pointers, making the
old snapshot sole referent of its pointer set while the physical blocks stay BRT-shared) — so
`USEDSNAP` grows ~full-size per generation *by construction*, and the listing looks like N full
copies. It is the (bf) trap wearing a new column. Diagnosis rule unchanged and re-vindicated:
pool ledger (`zpool get bcloneused,bclonesaved`), never `zfs list`/`du`. The lab listing's
newest-snapshot values (548K iPhone / 15.6M iPad) were the tell — real duplication cannot produce
a free newest snapshot. **Two real items extracted:** (1) the pre-qn.5b 07-22 snapshots (ruled
disposable in (cv)'s hardware-day list) are STILL alive — Operator to `zfs destroy`; (2) NEW,
previously unbanked: **`zfs send` does not preserve block cloning**, so a syncoid/replication
target pays every `@quince-*` snapshot at FULL rematerialized size — snapshot retention is a real
capacity knob on replicas (origin pool: ~free), and retention policy should be set before a
daily-soak year of generations meets an offsite pool. Routed: the retention/replication-cost note
lives in stack D5; a retention default is qn.7-or-freeze-exit material, not urgent (the origin
pool is unaffected; the Operator's syncoid replica is the only exposure and is his to watch until
then).
